import {LightningElement, api} from 'lwc';
import {reduceErrors} from 'c/ldsUtils';

export default class ErrorPanel extends LightningElement {
    @api errors;
    @api friendlyMessage = 'Error retrieving data';

    viewDetails = false;

    get errorMessages() {
        return reduceErrors(this.errors);
    }

    handleShowDetailsClick() {
        this.viewDetails = !this.viewDetails;
    }
}