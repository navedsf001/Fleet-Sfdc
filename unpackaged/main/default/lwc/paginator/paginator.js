import {LightningElement, api} from 'lwc';

export default class Paginator extends LightningElement {
    @api pageSize;
    @api pageNumber;
    @api totalItemCount;

    get pageCount() {
        return Math.ceil(this.totalItemCount / this.pageSize);
    }

    get isFirstPage() {
        return this.pageNumber === 1;
    }

    get isLastPage() {
        return this.pageNumber >= this.pageCount;
    }

    get currentPageNumber() {
        return (this.totalItemCount === 0) ? 0 : this.pageNumber;
    }

    handleNext() {
        this.dispatchEvent(new CustomEvent('next'));
    }

    handlePrevious() {
        this.dispatchEvent(new CustomEvent('previous'));
    }
}