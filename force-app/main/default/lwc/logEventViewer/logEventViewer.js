import { LightningElement, track, api } from "lwc";
import {
  subscribe,
  unsubscribe,
  onError,
  setDebugFlag,
  isEmpEnabled
} from "lightning/empApi";

export default class LogEventViewer extends LightningElement {
  @track
  channel = "/event/Log__e";

  @track
  showLogLines = false;

  @track
  logEvents = [];

  _subscription = {};

  onClearButtonClick() {
    this.logEvents = [];
    this.showLogLines = false;
  }

  onCopyToClipboardClick() {
    let inputElement = this.template.querySelector(".copyToClipboard");
    inputElement.disabled = false;
    inputElement.value = JSON.stringify(this.logEvents);
    inputElement.select();
    document.execCommand("copy");
    inputElement.disabled = true;
  }

  messageCallback = function(response) {
    let newEvent = response.data.payload;
    this.parseLogEventDetails(newEvent);
    this.logEvents.push(newEvent);
    this.showLogLines = this.logEvents.length > 0 ? true : false;
  };

  parseLogEventDetails(myEvent) {
    myEvent.details = JSON.parse(myEvent.LogEntriesJSON__c)[0];
  }

  createSubscription() {
    subscribe(this.channel, -1, this.messageCallback.bind(this)).then(
      response => {
        this._subscription = response;
      }
    );
  }

  cancelSubscription() {
    unsubscribe(this._subscription);
  }

  connectedCallback() {
    this.createSubscription();
  }

  disconnectedCallback() {
    this.cancelSubscription();
  }
}
