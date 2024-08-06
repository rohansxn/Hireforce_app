import { LightningElement,track } from 'lwc';
export default class JobsHome extends LightningElement {
        
    @track jobFilters=[];
    filterJobs = false;
    applyFilterOnData(event){
        this.jobFilters = event.detail;
        const childComponent = this.template.querySelector('c-job-records');
        if (childComponent) {
            // Call the child method and pass parameters
            childComponent.filterRecords(this.jobFilters);
        }
    }

    }