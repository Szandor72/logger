({
  onInit : function(component, event, helper) {
    var entry = component.get("v.debugEntry")
    if($A.util.isUndefinedOrNull(entry)) {
      return;
    }
    var json = entry.logEntryJSON__c;
    var logEntries = JSON.parse(json);
    var items = helper.convertToTree(logEntries, true);
    component.set('v.items', items);
  },

  expandTree : function(component, event, helper) {
    var entry = component.get("v.debugEntry")
    if($A.util.isUndefinedOrNull(entry)) {
      return;
    }
    var json = entry.logEntryJSON__c;
    var logEntries = JSON.parse(json);
    var expanded = component.get("v.expanded");
    logEntries.forEach(function (item){
      item.expanded = expanded; 
    });
    var items = helper.convertToTree(logEntries, false);
    component.set('v.items', items);
    component.set("v.expanded", !expanded);
  }
})