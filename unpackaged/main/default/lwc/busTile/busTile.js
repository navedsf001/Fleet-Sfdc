import {LightningElement, api} from 'lwc';

export default class BusTile extends LightningElement {
    @api bus;

    handleBusSelected() {
        const selectedEvent = new CustomEvent('selected', {
            detail: this.bus.Id
        });
        this.dispatchEvent(selectedEvent);
    }

    get backgroundImageStyle() {
        return `background-image:url(${this.bus.Image_URL__c})`;
    }

    get hasAirConditioning() {
        return this.bus.Has_Air_Conditioning__c ? 'Yes' : 'No';
    }
}