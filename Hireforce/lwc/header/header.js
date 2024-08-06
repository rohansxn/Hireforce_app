import { LightningElement,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
const FIELDS = [
    'User.Name'
];
export default class Header extends NavigationMixin(LightningElement) {
    showLoggOffButton=false;
    userName;
    @wire(getRecord, { recordId: USER_ID, fields: FIELDS })
    userRecord({ error, data }) {
        if (data) {
            this.userName = data.fields.Name.value;
        } else if (error) {
            console.error('Error fetching user data:', error);
        }
    }
    handleshowloggOffButton(event){
        this.showLoggOffButton= !this.showLoggOffButton;
    }
    handleLogout(event){
        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: {
                actionName: 'logout'
            }
        });
    }
}