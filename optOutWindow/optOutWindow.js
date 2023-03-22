import { LightningElement, api, wire } from 'lwc';
import getContactEmail from '@salesforce/apex/OptOutController.getEmailByCid';
import optOut from '@salesforce/apex/OptOutController.optOut';
import optIn from '@salesforce/apex/OptOutController.optIn';
import { CurrentPageReference } from 'lightning/navigation';

export default class OptOutWindow extends LightningElement {
    @api cid;
    @api contactEmail = '';
    @api showThankYouMessage = false;
    @api showSpinner = false;
    @api inputLength = 25;
    @api ip = null;
    @api device = encodeURI(navigator.platform);
    @api language = encodeURI(navigator.language);
    

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        const Http = new XMLHttpRequest();
        const url = 'https://api.ipify.org/';
        Http.open("GET", url);
        Http.send();
        let alreadyDone = false;
        Http.onreadystatechange=(e)=>{
            this.ip = Http.responseText;
            if (currentPageReference && this.ip) {

                if(alreadyDone == true){
                    return;
                }else{
                    alreadyDone = true;
                }

                this.cid = currentPageReference.state?.cid;
                this.cid = decodeURIComponent(this.cid);
                getContactEmail({cid: this.cid, ip: this.ip, device: this.device, language: this.language})
                    .then((result) => {
                        this.contactEmail = result;
                        this.inputLength = Math.max(25, result.length - 5);
                    })
                    .catch((error) =>{
                        console.log(error);
                    })
            }
        }
    }

    handleOptOutClick() {
        if(!this.cid){
            return;
        }
        this.showSpinner = true;


        optOut({ cid: this.cid, ip: this.ip, device: this.device, language: this.language})
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


        optIn({ cid: this.cid, ip: this.ip, device: this.device, language: this.language})
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
