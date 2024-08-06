import { LightningElement, api, track } from 'lwc';

export default class MultiSelectPicklist extends LightningElement {
    
    placeholder = '';
    showDD=false;
    init = false; 
    isExpanded = false;
    isSelectAll = false;
    //disableInput=true;


    @api options=[];    
    @api label;
    @api required=false;
    @api showpills;
    //optionValue;
/*

    @track countryOptions=[];
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: COUNTRY_CODE
    })
    wiredCountires({ data }) {
        if(data){
            console.log('@@ data?.values: '+JSON.stringify(data?.values));
            this.countryOptions = data?.values;
            this.options = Object.assign(this.options,this.countryOptions);
        }
    }
*/


    @track selectedCountryValue;
    @track selectedStateValue;

    connectedCallback(){
        if(this.label=='Country'){
            this.placeholder='Select Country';
            this.disableInput = false;
        }
        /*
        else if(this.label=='State'){
            this.placeholder='Select State/Province';
        }*/
    }

    renderedCallback() {
        if(!this.init) {
            this.template.querySelector('.cmpl-input').addEventListener('click', (event) => {
                if(this.showDD) {
                    this.showDD = !this.showDD;
                } else {
                    let opts = this.options ? this.options.filter((element) => element.show).length : 0;
                    this.showDD = opts > 0;
                }
                event.stopPropagation();
            });
            this.template.addEventListener('click', (event) => {
                event.stopPropagation();
            });
            document.addEventListener('click', () => {
                this.showDD = false;
            });
            this.init=true;
        }
        /*
        if(this.label=='State'){
            this.disableInput = this.options && this.options.length>0 ? false : true;
        }
        */
    }

    onSearch(event) {
        //this.optionValue = event.detail.value;
        this.options.forEach(option => {
            option.show = option.label.toLowerCase().startsWith(event.detail.value.toLowerCase());
        });
        let filteredopts = this.options.filter((element) => element.show);
        this.showDD = false;
        if(filteredopts.length > 0) {
            this.showDD = true;
        }      
    }

    onSelect(event) {
        if(event.target.value == 'SelectAll') {
            this.options.forEach(option => {
                option.checked = event.target.checked;
            });
        } else {
            this.options.find(option => option.label === event.target.value).checked = event.target.checked;
        } 
        //console.log('@@event.target.checked: '+event.target.checked);
        /*
        console.log('@@LABEL: '+this.label);
        if(this.label=='Country'){
            this.selectedCountryValue = this.options.filter(option=> option.checked == event.target.checked);
        }
        if(this.label=='State'){
            this.selectedStateValue = this.options.filter(option=> option.checked == event.target.checked);
        }
        */
        //console.log('@@checkedVal: '+JSON.stringify(this.selectedCountryValue));
        this.postSelect();
    }

    onRemove(event) {
        this.options.find(option => option.label === event.detail.name).checked = false;
        /*
        if(this.label=='Country'){
            console.log('remove2');
            let index = this.selectedCountryValue.findIndex(option => option.label === event.detail.name);
            if (index !== -1) {
                console.log('remove3');
                this.selectedCountryValue.splice(index, 1);
            }
            console.log('remove4');
        }
        else if(this.label=='State'){
            let index = this.selectedStateValue.findIndex(option => option.label === event.detail.name);
            if (index !== -1) {
                this.selectedStateValue.splice(index, 1);
            }
        }
        */
        this.postSelect();        
    }

    postSelect() {
        let count = this.options.filter((element) => element.checked).length;
        this.placeholder = count > 0 ? count+ ' Item(s) Selected' : '';
        this.isSelectAll = (count == this.options.length);
        if(this.showpills) {
            let evnt = setInterval(() => {
                if(count > 1){
                    if(this.template.querySelector('[role="listbox"]').getBoundingClientRect().height > 
                        (this.template.querySelectorAll('[role="pill"]')[0].getBoundingClientRect().height+10)) {
                        this.template.querySelector('[role="more"]').classList.remove('slds-hide');
                    } else {
                        this.template.querySelector('[role="more"]').classList.add('slds-hide');
                    }
                }
                clearInterval(evnt);
            }, 200);
        }
        /*
        if(this.required) {
            if(count == 0) {
                this.template.querySelector('.cmpl-input').setCustomValidity('Please select item(s)');
            } else {
                this.template.querySelector('.cmpl-input').setCustomValidity('');
            }            
            this.template.querySelector('.cmpl-input').reportValidity();
        }
        */
        /*
        if(this.label=='Country'){
            this.dispatchEvent(new CustomEvent('selectedcountry', { detail: this.selectedCountryValue }));
        }
        if(this.label=='State'){
            this.dispatchEvent(new CustomEvent('selectedstate', { detail: this.selectedStateValue }));
        }
        */
       
    }

    get showPillView() {
        if(this.showpills) {
            let count = this.options ? this.options.filter((element) => element.checked).length : 0;
            return this.showpills && count > 0;
        }
        return false;
    }

    showMore() {
        this.template.querySelector('.slds-listbox_selection-group').classList.add('slds-listbox_expanded');
        this.template.querySelector('[role="more"]').classList.add('slds-hide');
        this.template.querySelector('[role="less"]').classList.remove('slds-hide');
    }

    showLess() {
        this.template.querySelector('.slds-listbox_selection-group').classList.remove('slds-listbox_expanded');
        this.template.querySelector('[role="less"]').classList.add('slds-hide');
        this.template.querySelector('[role="more"]').classList.remove('slds-hide');
    }

    @api
    getSelectedList() {
        //return this.options.filter((element) => element.checked).map((element) => element.label).join(';');
        return this.options.filter((element) => element.checked).map((element) => element.value).join(';');
    }

    @api
    setSelectedList(selected) {
        selected?.split(';').forEach(name => {
            this.options.find(option => option.label === name).checked = true;
        });
        this.postSelect();
    }
    
    @api
    setOptions(opts) {
        //if(!(this.selectedCountryValue!=null && this.selectedCountryValue.length>0)){
            //this.options = JSON.parse(JSON.stringify(opts));
            this.options = opts.map(opt => {return {"label": opt.label, "value": opt.value, "show": true, "checked":false}});
            
            /*
            if(this.label=='State'){
                console.log('@@this.options: '+this.options);
                console.log('@@this.options!=null: '+this.options!=null);
                console.log('@@this.options!=: '+this.options!='');
                console.log('@@this.options.length: '+this.options.length);
                //console.log('@@this.options[0].value: '+this.options[0].value);
                if(this.options=='' || (this.options!=null &&  this.options.length==1 && this.options[0].value=='-None-')){
                    console.log('INSIDE');
                    this.placeholder ='Select State/Province';
                    this.disableInput = true;
                }
                else{
                    this.disableInput = false;
                }
            }
            */

        //}
    }
    

    @api
    isValid() {
        if(this.required) {
            let count = this.options ? this.options.filter((element) => element.checked).length : 0;
            if(count == 0) {
                //this.template.querySelector('.cmpl-input').setCustomValidity('Please select item(s)');
                //this.template.querySelector('.cmpl-input').reportValidity();
                //return false;
            }            
        }
        return true;
    }

    @api
    removeSelected(event) {
        this.options.forEach(option => {
            option.checked = false;
        });
        console.log('this.label: '+this.label);
        if(this.label=='Country'){
            console.log('enter');
            this.placeholder ='Select Country';
        }
        this.postSelect();
    }    
    
    /*
    @api
    removeCountry(){
        if(this.label=='Country'){
            this.optionValue = '';
            this.placeholder ='Select Country';
            this.options.forEach(option => {
                option.checked = false;
            });
        }
    }

    @api
    removeState(){
        if(this.label=='State'){
            this.optionValue = '';
            this.placeholder ='Select State/Province';
            this.disableInput = true;
            this.options=[];
        }
    }
    */
}