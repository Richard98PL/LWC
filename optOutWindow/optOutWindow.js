import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getContactEmail from '@salesforce/apex/OptOutController.getEmailByCid';
import optOut from '@salesforce/apex/OptOutController.optOut';
import optIn from '@salesforce/apex/OptOutController.optIn';
import { CurrentPageReference } from 'lightning/navigation';

export default class OptOutWindow extends LightningElement {
    @api cid;
    @api contactEmail = '';
    @api showThankYouMessage = false;
    @api showSpinner = false;
    @api inputLength = 15;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.cid = currentPageReference.state?.cid;

            console.log(this.cid);
            getContactEmail({cid: this.cid})
                .then((result) => {
                    this.contactEmail = result;
                    this.inputLength = Math.max(15, result.length - 5);
                })
                .catch((error) =>{
                    console.log(error);
                })
        }
    }

    handleOptOutClick() {
        if(!this.cid){
            return;
        }
        this.showSpinner = true;
        optOut({ cid: this.cid })
            .then(() => {
                this.showThankYouMessage = true;
            })
            .catch(error => {
                // Handle opt-out error
            })
            .finally(()=>{
                this.showSpinner = false;
            });
    }

    handleOptInClick() {
        if(!this.cid){
            return;
        }
        this.showSpinner = true;
        optIn({ cid: this.cid })
            .then(() => {
                this.showThankYouMessage = true;
            })
            .catch(error => {
                // Handle opt-out error
            })
            .finally(()=>{
                this.showSpinner = false;
            });
    }
}
