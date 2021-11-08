import { LightningElement, wire } from 'lwc';
import {publish, subscribe, unsubscribe, MessageContext} from 'lightning/messageService';
import BUS_SELECTED_CHANNEL from '@salesforce/messageChannel/BusSelected__c';
import {refreshApex} from '@salesforce/apex';
import getBusPageResultWrapper from '@salesforce/apex/CTRL_BusTileList.getBusPageResultWrapper';

const PAGE_SIZE = 12;

export default class BusTileList extends LightningElement {
    pageNumber = 1;
    pageSize = PAGE_SIZE;
    subscription = null;

    @wire(MessageContext) msgContext;
    @wire(getBusPageResultWrapper, {pageSize: '$pageSize', pageNumber: '$pageNumber'}) busPageResultWrapper;

    connectedCallback() {
        this.subscription = subscribe(this.msgContext, BUS_SELECTED_CHANNEL, (message) => {
            this.handleBusUpdated(message);
        });
    }

    handleBusUpdated(message) {
        if(message.type === "update") {
            refreshApex(this.busPageResultWrapper);
        }
    }
    
    handleBusSelected(event) {
        const message = {busId: event.detail, type: "select"};
        publish(this.msgContext, BUS_SELECTED_CHANNEL, message);
    }

    handlePreviousPage() {
        this.pageNumber = this.pageNumber - 1;
    }

    handleNextPage() {
        this.pageNumber = this.pageNumber + 1;
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
}