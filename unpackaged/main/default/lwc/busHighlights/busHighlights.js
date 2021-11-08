import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {NavigationMixin} from 'lightning/navigation';

import {publish, subscribe, unsubscribe, MessageContext} from 'lightning/messageService';
import BUS_SELECTED_CHANNEL from '@salesforce/messageChannel/BusSelected__c';

import FIELD_NAME from '@salesforce/schema/Bus__c.Name';
import FIELD_GARAGE from '@salesforce/schema/Bus__c.Garage__c';
import FIELD_YEAR from '@salesforce/schema/Bus__c.Year__c';
import FIELD_CAPACITY from '@salesforce/schema/Bus__c.Maximum_Capacity__c';
import FIELD_HAS_AC from '@salesforce/schema/Bus__c.Has_Air_Conditioning__c';
import FIELD_STATUS from '@salesforce/schema/Bus__c.Current_Status__c';
import FIELD_ODOMETER from '@salesforce/schema/Bus__c.Odometer_Reading__c';
import FIELD_IMAGE_URL from '@salesforce/schema/Bus__c.Image_URL__c';

export default class BusHighlights extends NavigationMixin(LightningElement) {
    busId;
    busFieldArray = [FIELD_GARAGE, FIELD_YEAR, FIELD_CAPACITY, FIELD_HAS_AC, FIELD_STATUS, FIELD_ODOMETER];
    subscription = null;

    @wire(MessageContext) msgContext;
    @wire(getRecord, {recordId: '$busId', fields: [FIELD_NAME, FIELD_IMAGE_URL]}) bus;

    connectedCallback() {
        this.subscription = subscribe(this.msgContext, BUS_SELECTED_CHANNEL, (message) => {
            this.handleBusSelected(message);
        });
    }

    handleBusSelected(message) {
        this.busId = message.busId;
    }

    @api
    get recordId() {
        return this.busId;
    }

    set recordId(busId) {
        this.busId = busId;
    }

    get busName() {
        return getFieldValue(this.bus.data, FIELD_NAME);
    }

    get busImageURL() {
        return getFieldValue(this.bus.data, FIELD_IMAGE_URL);
    }

    handleRecordNaviagtion() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.busId,
                objectApiName: 'Bus__c',
                actionName: 'view'
            }
        });
    }

    handleSuccess(event) {
        console.log("handleSuccess");
        const message = {busId: event.detail.id, type: "update"};
        publish(this.msgContext, BUS_SELECTED_CHANNEL, message);
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
}