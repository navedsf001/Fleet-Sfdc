import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {NavigationMixin} from 'lightning/navigation';

import {subscribe, unsubscribe, MessageContext} from 'lightning/messageService';
import BUS_SELECTED_CHANNEL from '@salesforce/messageChannel/BusSelected__c';

import FIELD_NAME from '@salesforce/schema/Bus__c.Name';
import FIELD_LAST_LOCATION from '@salesforce/schema/Bus__c.Last_Location__c';
import FIELD_LAST_MAINTENANCE_DATE from '@salesforce/schema/Bus__c.Last_Maintenance_Date__c';
import FIELD_ELIGIBLE_FOR_MAINTENANCE from '@salesforce/schema/Bus__c.Eligible_For_Maintenance__c';
import FIELD_RESALE_VALUE from '@salesforce/schema/Bus__c.Resale_Value__c';

export default class BusReadonlyDetails extends LightningElement {
    busId;
    busFieldArray = [FIELD_LAST_LOCATION, FIELD_LAST_MAINTENANCE_DATE, FIELD_ELIGIBLE_FOR_MAINTENANCE, FIELD_RESALE_VALUE];
    subscription = null;

    @wire(MessageContext) msgContext;
    @wire(getRecord, {recordId: '$busId', fields: [FIELD_NAME]}) bus;

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

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
}