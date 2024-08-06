import { LightningElement, wire, track, api } from 'lwc';
import getInterviewers from '@salesforce/apex/JobApplicationController.getInterviewers';
import updateInterviewerAvailability from '@salesforce/apex/JobApplicationController.updateInterviewerAvailability';
import { refreshApex } from '@salesforce/apex';

export default class InterviewerList extends LightningElement {
    @track columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Available Slots', fieldName: 'Available_Slots__c' },
        { label: 'Interviewing Rounds', fieldName: 'Interviewing_Rounds__c' },
        /*
        { type: 'button', 
            typeAttributes: { 
                label: 'Remove Interviewer', name: 'toggleAvailability', variant: 'brand' , class: 'center-align' 
            }
        }*/

        /*{
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'Remove', iconName: 'utility:delete', name: 'delete' }
                ]
            }
        }*/

            {
                label: 'Actions',
                type: 'button-icon',
                fixedWidth: 100,
                typeAttributes: {
                    iconName: 'utility:delete',
                    alternativeText: 'Delete',
                    variant: 'bare',
                    name: 'delete',
                    iconClass: 'delete-icon'
                }
            }
    ];

    @track data;
    @track error;
    @track filter = '';
    wiredInterviewers;
    @api recordId;
    isLoading = false;

    @wire(getInterviewers, { hiringEventId: '$recordId' })
    wiredInterviewer(result) {
        this.wiredInterviewers = result;
        if (result.data) {
            this.data = result.data;
            this.error = undefined;
            console.log('this.data: '+JSON.stringify(this.data));
        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
            console.log('this.error: '+JSON.stringify(this.error));
        }
    }

    handleRowAction(event) {
        this.isLoading = true;
        let rowData = event.detail.row;
        console.log('rowData: '+JSON.stringify(rowData));
        updateInterviewerAvailability({ interviewerId: rowData.Id })
            .then(() => {
                this.isLoading = false;
                return refreshApex(this.wiredInterviewers);
            })
            .catch(error => {
                this.error = error;
            });
    }
}