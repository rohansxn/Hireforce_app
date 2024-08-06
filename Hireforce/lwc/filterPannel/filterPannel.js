import { LightningElement,track,wire } from 'lwc';

import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import JOB_OBJECT from '@salesforce/schema/Job__c';
import JOB_STATE_PROVINCE_FIELD from '@salesforce/schema/Job__c.State_Province__c';
import getPickListValueWrapper from '@salesforce/apex/JobApplicationController.getPickListValueWrapper';

export default class FilterPannel extends LightningElement {

    filters;
    @track selectedCountries = [];
    @track selectedStates = [];
    @track selectedJobType = [];
    @track selectedDepartments = [];
    @track titleSearchText = '';
    @track countryOptions=[];
    @track stateProvinceOptions=[];
    @track jobTypeOptions = []; 
    @track departmentOptions =[];
    countryCodeToNumberMapping ={};
    dependentStateCodesWithCountryValues = {};

    @wire(getObjectInfo, { objectApiName: JOB_OBJECT })
    objectInfo;

    filterFields=['Job_Type__c', 'Department__c','Country__c'];

    connectedCallback(){
        getPickListValueWrapper({objectName:'Job__c',picklistFieldApiList:this.filterFields})
        .then(data => {
            this.jobTypeOptions = data.Job_Type__c.map(item => ({ label: item.label, value: item.value }));
            this.departmentOptions = data.Department__c.map(item => ({ label: item.label, value: item.value }));
            this.countryOptions = data.Country__c.map(item => ({ label: item.label, value: item.value }));
            this.template.querySelector('[role="country"]').setOptions(this.countryOptions);
        }).
        catch(error => {
            console.error('Error fetching picklist values:', error);
        });
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: JOB_STATE_PROVINCE_FIELD })
    wiredStateProvincePicklistValues({ error, data }) {
        if (data) {
            //data.controllerValues give the map of country code with the no. E.g., "AF": 0
            const validForNumberToCountryMapping = {};
            for (const key in data.controllerValues) {
                if (data.controllerValues.hasOwnProperty(key)) {
                    const value = data.controllerValues[key];
                    this.countryCodeToNumberMapping[key] = value;
                    validForNumberToCountryMapping[value] = key;
                }
            }

            this.dependentStateCodesWithCountryValues ={};
            for (let i = 0; i < data.values.length; i++) {
                const state = data.values[i];
                const countryNumericCode = validForNumberToCountryMapping[state.validFor[0]];
                if (!this.dependentStateCodesWithCountryValues[countryNumericCode]) {
                    this.dependentStateCodesWithCountryValues[countryNumericCode] = [];
                }
                this.dependentStateCodesWithCountryValues[countryNumericCode].push( {"label": state.label, "value": state.value} );
               
            }
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }

    handleJobTypeChange(event) {
        this.selectedJobType = event.detail.value;
    }

    handleDepartmentChange(event) {
        this.selectedDepartments = event.detail.value;
    }
    
    handleTitleSearchTextChange(event) {
        this.titleSearchText = event.target.value;
    }

    populateCountryList(event){
        console.log('@@country event: '+JSON.stringify(event.detail));
        this.selectedCountries=[];
        this.stateProvinceOptions=[];
        
        event.detail.forEach(element => {
            this.selectedCountries.push(element.value);
        });

        if(this.selectedCountries.length==0){
            this.selectedStates=[];
            if(this.template.querySelector('[role="state"]')){
                this.template.querySelector('[role="state"]').setOptions(this.stateProvinceOptions);
            }
        }
        else{    
            this.selectedCountries.forEach(element => {
                
                console.log('@@element: '+element);
                console.log('@@this.dependentStateCodesWithCountryValues[element]: '+JSON.stringify(this.dependentStateCodesWithCountryValues[element]));
    
                this.dependentStateCodesWithCountryValues[element].forEach(
                    (element) => {
                        console.log('@@@VALue: '+element.value);
                        //if(element.value!='-None-'){
                            this.stateProvinceOptions.push(element);
                        //}
                    }
                )
                //this.stateProvinceOptions.push(this.dependentStateCodesWithCountryValues[element]);
                }
            )
            console.log('@@this.stateProvinceOptions: '+JSON.stringify(this.stateProvinceOptions));
            if(this.template.querySelector('[role="state"]')){
                this.template.querySelector('[role="state"]').setOptions(this.stateProvinceOptions);
            }
        }
    }

    populateStateList(event){
        this.selectedStates=[];
        event.detail.forEach(element => {
            this.selectedStates.push(element.value);
        });
    }

    applyFilters() {
       this.selectedCountries=this.template.querySelector('[role="country"]').getSelectedList()=='' || this.template.querySelector('[role="country"]').getSelectedList()==null ?[]: this.template.querySelector('[role="country"]').getSelectedList().split(";");
            
       this.filters = {
                countries: this.selectedCountries,
                states: this.selectedStates,
                jobType: this.selectedJobType=='None' ? [] : this.selectedJobType,
                departments: this.selectedDepartments=='None' ? [] : this.selectedDepartments,
                jobTitle: this.titleSearchText
            };
            console.log('@@filters: '+JSON.stringify(this.filters));
            const filterEvent = new CustomEvent('applyfilters', { detail: this.filters });
            this.dispatchEvent(filterEvent);
    }

    clearFilters(){
        this.selectedCountries=[];
        this.selectedStates = [];
        this.selectedDepartments = [];
        this.selectedJobType = [];
        this.titleSearchText='';
        this.template.querySelector('[role="country"]').removeSelected();
        this.filters = {
            countries: [],
            states:[],
            jobType: '',
            departments: [],
            jobTitle: ''
        };
        const filterEvent = new CustomEvent('applyfilters', { detail: this.filters });
        this.dispatchEvent(filterEvent);
    }
}