import { LightningElement, wire } from "lwc";
import { subscribe, MessageContext } from "lightning/messageService";
import TOAST_SERVICE_CHANNEL from "@salesforce/messageChannel/ToastService__c";

const TIMEOUT = 3000;

export default class CustomToast extends LightningElement {
  title;
  message;
  variant;
  displayToast = false;

  @wire(MessageContext)
  messageContext;

  subscribeToMessageChannel() {
    this.subscription = subscribe(this.messageContext, TOAST_SERVICE_CHANNEL, (message) => this.handleMessage(message));
  }

  connectedCallback() {
    this.subscribeToMessageChannel();
  }

  handleMessage(message) {
    this.title = message.title;
    this.message = message.message;
    this.variant = message.variant;
    this.displayToast = true;
    this.closeToast();
  }

  closeToast() {
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      this.displayToast = false;
    }, TIMEOUT);
  }

  get iconName() {
    return this.variant === "success" ? "utility:success" : "utility:error";
  }

  get toastClass() {
    return `toast toast-${this.variant}`;
  }
}