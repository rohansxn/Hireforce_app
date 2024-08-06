import { LightningElement, track, wire } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import APPLICATION_OBJECT from '@salesforce/schema/Application__c';
import NAME_FIELD from '@salesforce/schema/Application__c.Name';
import EMAIL_FIELD from '@salesforce/schema/Application__c.Applicant_Email__c';
import PHONE_FIELD from '@salesforce/schema/Application__c.Phone_Number__c';
import DATE_FIELD from '@salesforce/schema/Application__c.Application_Date__c';
import JOB_FIELD from '@salesforce/schema/Application__c.Job__c';
import STATUS_FIELD from '@salesforce/schema/Application__c.Status__c';
import APPLICATION_CONTACT_FIELD from '@salesforce/schema/Application__c.Contact__c';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';

import { MessageContext, publish } from "lightning/messageService";
import TOAST_SERVICE_CHANNEL from "@salesforce/messageChannel/ToastService__c";
import uploadFileAndLinkToRecord from '@salesforce/apex/JobApplicationController.uploadFileAndLinkToRecord';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import getApplicationsByUserEmail from '@salesforce/apex/JobApplicationController.getApplicationsByUserEmail';
import getJobRecords from "@salesforce/apex/JobApplicationController.getJobRecords";

import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import USER_NAME from '@salesforce/schema/User.Name';
import USER_EMAIL_FIELD from '@salesforce/schema/User.Email';

export default class ApplicationForm extends NavigationMixin(LightningElement) {
    @track name = '';
    @track applicantEmail = '';
    @track phoneNumber = '';
    @track recordId;
    @track fileName = '';
    @track showToastBoolean = false;
    @track toastMessage = '';
    uploadedFiles = [];
    jobRecordId;
    @track isLoading = false;
    applications=[];
    disableSubmitForm = true;
    recordCreated = false;
    @track jobDetails={};
    contactRecord;

    @wire(getRecord, { recordId: USER_ID, fields: [USER_NAME,USER_EMAIL_FIELD,CONTACT_FIELD] })
    user;

    @wire(MessageContext)
    messageContext;

    pageReferenceState;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        if (currentPageReference) {
            this.jobRecordId = currentPageReference.state.id;
            console.log('this.jobRecordId from app form: '+this.jobRecordId);
        }
    }

    @wire(getApplicationsByUserEmail, { userEmail: '$user.data.fields.Email.value', jobId: '$jobRecordId'})
    wiredApplications({ error, data }) {
        if (data) {
            console.log('this.jobRecordId in app: '+this.jobRecordId);
            this.recordCreated = data.length==0 ? false : true;
            console.log('@@applications: '+JSON.stringify(data));
            console.log('@@this.recordCreated: '+this.recordCreated);
        } else if (error) {
            this.recordCreated = false;
        }
    }

    @wire(getJobRecords,{jobId: '$jobRecordId'})
    getjobRecord({data,error})
    {
        if(data)
        {
            this.jobDetails=data;
            console.log('@@this.jobDetails in form: '+JSON.stringify(this.jobDetails));
        }
        if(error){
            console.log('error:'+JSON.stringify(error));
        }
    }

    handleNameChange(event) {
        this.name = event.target.value;
    }

    handleEmailChange(event) {
        this.applicantEmail = event.target.value;
    }

    handlePhoneChange(event) {
        this.phoneNumber = event.target.value;
    }

    handleSuccess(event) {
        this.recordId = event.detail.id;
        this.fileName = ''; // Clear file name after successful record creation
        if (this.uploadedFiles.length > 0) {
            this.uploadFiles();
        }
    }

    handleError(event) {
        this.showToastMethod('Error', 'There was an error creating the application1111.', 'error');
    }

    handleFileChange(event) {
        const files = event.target.files;
        this.uploadedFiles = [];
        if (files.length > 0) {
            this.uploadedFiles = files;
            this.fileName = files[0].name;
        }
    }

    get isSubmitDisabled() {
        // Check if any of the fields are empty or if the file is not selected
        return !this.phoneNumber || !this.uploadedFiles || this.uploadedFiles.length==0;

    }

    handleSubmit(event) {
        event.preventDefault(); // Prevent default form submission
        this.isLoading = true; // Show spinner

        // Validate phone number
        const phoneNumberPattern = /^\d{10}$/;
        if (!phoneNumberPattern.test(this.phoneNumber)) {
            this.isLoading = false; // Hide spinner
            this.showToastMethod('Error', 'Phone number must be a 10-digit number.', 'error');
            return;
        }

        // Validate file input
        if (!this.uploadedFiles) {
            this.isLoading = false; // Hide spinner
            this.showToastMethod('Error', 'Resume is required.', 'error');
            return;
        }

        const fields = {};
        fields[NAME_FIELD.fieldApiName] = this.user.data.fields.Name.value;
        fields[EMAIL_FIELD.fieldApiName] = this.user.data.fields.Email.value;

        fields[PHONE_FIELD.fieldApiName] = this.phoneNumber;
        fields[DATE_FIELD.fieldApiName] = new Date().toISOString();
        fields[JOB_FIELD.fieldApiName] = this.jobRecordId;
        fields[STATUS_FIELD.fieldApiName] = 'Applied';
        fields[APPLICATION_CONTACT_FIELD.fieldApiName] = this.user.data.fields.ContactId.value;

        const recordInput = { apiName: APPLICATION_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then((record) => {
                this.recordId = record.id;
                if (this.uploadedFiles.length > 0) {
                    this.uploadFiles();
                }else{
                    this.showToastMethod('Success', 'Application created successfully!', 'success');
                    this.isLoading = false; // Hide spinner
                }
            })
            .catch((error) => {
                this.isLoading = false; // Hide spinner
                console.log('ERROR: '+JSON.stringify(error));
                this.showToastMethod('Error', 'There was an error creating the application.', 'error');
            });
    }

    uploadFiles() {
        const promises = Array.from(this.uploadedFiles).map(file => {
            return this.readFile(file)
                .then(fileContent => {
                    return uploadFileAndLinkToRecord({
                        recordId: this.recordId,
                        fileName: file.name,
                        base64Data: fileContent,
                        contentType: file.type
                    });
                });
        });

        Promise.all(promises)
            .then(() => {
                this.isLoading = false; // Hide spinner
                this.recordCreated = true;
                this.showToastMethod('Success', 'Applied successfully!', 'success');
            })
            .catch(error => {
                console.log('ERROR IN FILE: '+JSON.stringify(error));
                this.isLoading = false; // Hide spinner
                this.showToastMethod('Error', 'There was an error uploading the files.', 'error');
            });
    }

    readFile(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => resolve(reader.result.split(',')[1]);
            reader.onerror = error => reject(error);
            reader.readAsDataURL(file);
        });
    }

    handleExploreMore() {

        let objPageParams = {
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        };
        this[NavigationMixin.GenerateUrl](objPageParams)
            .then(url => {
                window.open(url, "_self");
            })
            .catch(error => {
                console.error('Error generating URL:', error);
                // Handle the error accordingly
            });
    }

    cancelApplication(){
        let objPageParams = {
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        };
        this[NavigationMixin.GenerateUrl](objPageParams)
            .then(url => {
                window.open(url, "_self");
            })
            .catch(error => {
                console.error('Error generating URL:', error);
                // Handle the error accordingly
            });

    }

    showToastMethod(title, message, variant) {
        console.log('message:'+message);
        publish(this.messageContext, TOAST_SERVICE_CHANNEL, {
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.toastMessage = `${title}: ${message}`;
    }
}