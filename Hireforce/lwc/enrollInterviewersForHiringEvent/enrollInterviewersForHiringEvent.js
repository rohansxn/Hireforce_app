import { LightningElement, track, wire, api} from 'lwc';
import retrieveInterviewers from '@salesforce/apex/EntrollmentIntrviewerCntrl.retrieveInterviewers';
import getInterviewersEnrolled from '@salesforce/apex/EntrollmentIntrviewerCntrl.getInterviewersEnrolled';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Interviewing Rounds', fieldName: 'Interviewing_Rounds__c' },
    { label: 'Hiring Manager', fieldName: 'Hiring_Manager__c',type: 'url',
    typeAttributes: {
      label: { fieldName: 'HrManagrName' }, 
      target: '_blank'
    }},       
];
export default class EnrollInterviewersForHiringEvent extends LightningElement {
    @track srchtxt;
    @api recordId;
    @track data;
    @track intvrs;
    @track columns = columns;
    @track error;

    async connectedCallback() {
        this.fetchRecords();
    }

    valueChange(event){
        this.srchtxt = event.target.value;
    }

    fetchRecords()
    {
        retrieveInterviewers({ serchtxt: this.srchtxt, hringEvtId: this.recordId})
        .then(result => {
            this.data = result;
            if(this.data){
                this.intvrs = this.data.map(row => {
                    const Id = row.Id;
                    const Name = row.Name;
                    const Interviewing_Rounds__c = row.Interviewing_Rounds__c;
                    const Hiring_Manager__c = `/lightning/r/${row.Hiring_Manager__c}/view`;
                    const HrManagrName = row.Hiring_Manager__r.Name;
                    const conId = row.Employee__c; 
                    return {...row , Id, Name, Interviewing_Rounds__c, Hiring_Manager__c, HrManagrName, conId};
                  })
            }
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.data = undefined;
        });
    }

    getSelectedRec() {
        var selRecss = [];
        var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        if(selectedRecords.length > 0){
            console.log('selectedRecords are ', selectedRecords);
            let ids = '';
            selectedRecords.forEach(currentItem => {
                ids = ids + ',' + currentItem.Id;
                selRecss.push(currentItem.Id+'@@'+currentItem.conId);
            });
            this.selectedIds = ids.replace(/^,/, '');
            this.lstSelectedRecords = selectedRecords;
        }
        getInterviewersEnrolled({ selIds: selRecss, hringEvtId: this.recordId})
        .then(result => {
            this.data = result;
            this.error = undefined;
            this.fetchRecords();
            this.showNotification();
        })
        .catch(error => {
            this.error = 'An error occurred while processing your request. Please contact admin';
            this.data = undefined;
        });   
    }

    showNotification() {
        const evt = new ShowToastEvent({
          title: 'success',
          message: 'Interviewers Added successfully',
          variant: 'success',
        });
        this.dispatchEvent(evt);
    }
}