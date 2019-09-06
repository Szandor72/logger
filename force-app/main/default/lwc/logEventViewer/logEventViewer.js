import { LightningElement, track, api } from "lwc";
import {
  subscribe,
  unsubscribe,
  onError,
  setDebugFlag,
  isEmpEnabled
} from "lightning/empApi";

export default class App extends LightningElement {
  /**
   * @track indicates that if this object changes,
   * the UI should update to reflect those changes.
   * cannot be accessed from parent,
   * private reactive
   */
  @track
  title = "Log Lines";

  @track
  channel = "/event/Log__e";

  @track
  showLogLines = false;

  @track
  logEvents = [];

  subscription = {};

  messageCallback = function(response) {
    let newEvent = response.data.payload;
    this.parseLogEventDetails(newEvent);
    this.logEvents.push(newEvent);
    this.showLogLines = this.logEvents.length > 0 ? true : false;
    console.log(this.logEvents.length);
  };

  parseLogEventDetails(myEvent) {
    myEvent.details = JSON.parse(myEvent.LogEntriesJSON__c)[0];
  }

  createSubscription() {
    subscribe(this.channel, -1, this.messageCallback.bind(this)).then(
      response => {
        console.log(
          "Successfully subscribed to : ",
          JSON.stringify(response.channel)
        );
        this.subscription = response;
      }
    );
  }

  cancelSubscription() {
    unsubscribe(this.subscription, response => {
      console.log("unsubscribe() response: ", JSON.stringify(response));
      // Response is true for successful unsubscribe
    });
  }

  connectedCallback() {
    this.createSubscription();
  }

  disconnectedCallback() {
    this.cancelSubscription();
  }
}
