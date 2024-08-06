import { LightningElement, track, wire } from 'lwc';
import getApplicationsByUserEmail from '@salesforce/apex/JobApplicationController.getApplicationsByUserEmail';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import { refreshApex } from '@salesforce/apex';

import { subscribe, MessageContext } from "lightning/messageService";
import TOAST_SERVICE_CHANNEL from "@salesforce/messageChannel/ToastService__c";

export default class JobApplications extends LightningElement {
    @track applications;
    @track error;
    @track isLoading = true;
    @track wireResult=[];

    @track selectedApplicationId;
    @track showJobDetails = false;
    selectedJobId;

    @wire(MessageContext)
    messageContext;

    @wire(getRecord, { recordId: USER_ID, fields: [EMAIL_FIELD] })
    user;

    @wire(getApplicationsByUserEmail, { userEmail: '$user.data.fields.Email.value', jobId:null })
    wiredApplications(result) {
        this.wireResult = result;
        this.isLoading = false;
        if (result.data) {
            this.applications = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error.body.message;
            this.applications = undefined;
        }
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(this.messageContext, TOAST_SERVICE_CHANNEL, (message) => this.handleMessage(message));
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    renderedCallback(){
        console.log('JOb applied');
    }

    handleMessage(method){
        refreshApex(this.wireResult);
    }

    handleRecordClick(event){
        this.selectedApplicationId = event.currentTarget.dataset.id;
        this.showJobDetails = true; 
        if(this.wireResult && this.wireResult.data){
            let application = this.wireResult.data.filter( item => item.Id==this.selectedApplicationId);
            this.selectedJobId = application[0].Job__c;

        }
    }

    handleCloseModal() {
        this.showJobDetails = false;
        this.selectedApplicationId = false;
    }
}