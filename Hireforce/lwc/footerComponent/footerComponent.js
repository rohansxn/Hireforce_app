import { LightningElement } from 'lwc';

export default class FooterComponent extends LightningElement {
    isVisible = false;

    connectedCallback() {
        // Set a timer to show the component after 3 seconds
        setTimeout(() => {
            this.isVisible = true;
        }, 3000); // 3000 milliseconds = 3 seconds
    }
}