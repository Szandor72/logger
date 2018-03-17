({
  onInit : function(component, event, helper) {
    var entry = component.get("v.debugEntry")
    if($A.util.isUndefinedOrNull(entry)) {
      return;
    }
    var json = entry.logEntryJSON__c;
    var logEntries = JSON.parse(json);
    var items = helper.convertToTree(logEntries);
    component.set('v.items', items);
  }
})