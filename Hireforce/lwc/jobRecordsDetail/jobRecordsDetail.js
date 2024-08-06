import { LightningElement,wire,track, api } from 'lwc';
import getJobRecords from "@salesforce/apex/JobApplicationController.getJobRecords";
import { CurrentPageReference } from 'lightning/navigation';
import {NavigationMixin} from 'lightning/navigation';
import { MessageContext, publish } from "lightning/messageService";
import TOAST_SERVICE_CHANNEL from "@salesforce/messageChannel/ToastService__c";

import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import USER_NAME from '@salesforce/schema/User.Name';
import USER_EMAIL_FIELD from '@salesforce/schema/User.Email';

export default class JobRecordsDetail extends NavigationMixin(LightningElement){
    jobRecord;
    recordid;
    @api recordidfromcomponent;
    error;
    htmlContent;
    @track skillNames=[];
    displaySkills = false;
    displayfooter = true;

    pageReferenceState;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        if (currentPageReference) {
            this.recordid = currentPageReference.state.id;
        }
    }

    @wire(MessageContext)
    messageContext;

    @wire(getJobRecords,{jobId: '$recordid'})
    getjobRecord({data,error})
    {
        if(data)
        {
            this.jobRecord=data;
            //console.log('JOB RECORD: '+JSON.stringify(this.jobRecord));
            //this.skillNames =  this.jobRecord!=null && this.jobRecord.Required_Skills__r!=null ? this.jobRecord.Required_Skills__r.map(skill => skill.Skill__r.Name) : [];
            this.skillNames = this.jobRecord.Required_Skills__r!=null && this.jobRecord.Required_Skills__r!=undefined ?  this.jobRecord.Required_Skills__r.map(skill => skill.Skill__r.Name) : [];
            /*
            this.skillNames = this.jobRecord!=null && this.jobRecord.Required_Skills__r!=null ? this.jobRecord.Required_Skills__r.map(skill => ({
                name: skill.Skill__r.Name,
                firstChar: skill.Skill__r.Name.charAt(0)
            })) : [];
            */
            this.displaySkills = this.skillNames && this.skillNames.length>0 ? true : false;
            this.htmlContent = this.jobRecord.Role_And_Responsibilities__c;
            //console.log('this.jobRecord->'+JSON.stringify(this.jobRecord.Role_And_Responsibilities__c));
        }
        if(error){
            console.log('error:'+JSON.stringify(error));
        }
    }

    @wire(getRecord, { recordId: USER_ID, fields: [USER_NAME,USER_EMAIL_FIELD] })
    user;

    connectedCallback(){
        if(this.recordidfromcomponent!= null && this.recordidfromcomponent!=undefined){
            this.recordid = this.recordidfromcomponent;
            this.displayfooter = false;
        }
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

    handleApply(event) {
        let jobId = this. recordid;
        
        let objPageParams = {
            type: 'comm__namedPage',
            attributes: {
                name: 'ApplyPage__c'
            },
            state: {
                id: jobId
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
}