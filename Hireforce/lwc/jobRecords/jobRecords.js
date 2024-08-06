import { LightningElement,wire,api } from 'lwc';
import getJobDetails from "@salesforce/apex/JobApplicationController.getJobDetails";
import {NavigationMixin} from 'lightning/navigation';
export default class JobRecords extends NavigationMixin(LightningElement) {
    jobRecords;
    filterJobRecords=[];
    
    @wire(getJobDetails)
    getjobRecords({data,error})
    {
        if(data)
        {
            this.jobRecords=data;
            this.filterJobRecords = data;
        }
        if(error){
            console.log('error: '+JSON.stringify(error));
        }
    }

    @api
    filterRecords(jobFilters) {
        if(jobFilters==null || (jobFilters.jobTitle=='' && jobFilters.countries.length==0 && jobFilters.states.length==0 && jobFilters.jobType.length==0 && jobFilters.departments.length==0)){
            this.filterJobRecords = this.jobRecords;
        }else{
            this.filterJobRecords = this.jobRecords.filter(item =>
                (!jobFilters.jobTitle ||  jobFilters.jobTitle=='' || item.Name?.toLowerCase().includes(jobFilters.jobTitle.toLowerCase())) &&
                (!jobFilters.countries ||  jobFilters.countries.length==0 || jobFilters.countries.includes(item.Country__c)) &&
                (!jobFilters.states || jobFilters.states.length==0 || jobFilters.states.includes(item.State_Province__c)) &&
                (!jobFilters.jobType || jobFilters.jobType.length==0 || jobFilters.jobType.includes(item.Job_Type__c)) &&
                (!jobFilters.departments || jobFilters.departments.length==0 || jobFilters.departments.includes(item.Department__c))
            );   
        }
    }

    handleRecordClick(event) {
        let jobId = event.currentTarget.getAttribute('data-id');
        let objPageParams = {
            type: 'comm__namedPage',
            attributes: {
                name: 'detail__c'
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