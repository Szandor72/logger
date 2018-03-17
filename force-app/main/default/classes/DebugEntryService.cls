public with sharing class DebugEntryService {

	public static void saveLogs(List<Log__e> logs) {
		List<DebugEntry__c> newDebugEntries = new List<DebugEntry__c>();

		For (Log__e log: logs) {

			List<String> traceInfo = log.Trace__c.split(':');
			if (!isValid(traceInfo)) {
				return;
			}
			DebugEntry__c entry = new DebugEntry__c();
			entry.className__c = traceInfo[0];
			entry.methodName__c = traceInfo[1];
			entry.Line__c = Integer.ValueOf(traceInfo[2]);
			entry.Column__c = Integer.ValueOf(traceInfo[3]);
			entry.cpuTimeUsage__c = Integer.ValueOf(traceInfo[4]);
			entry.runningUser__c = traceInfo[5];
			entry.startDateTime__c = log.startDateTime__c;
			entry.logEntryJSON__c = log.LogEntriesJSON__c;

			if (AppConfigSupport.saveAllLogs) {
				newDebugEntries.add(entry);
			} else if (AppConfigSupport.saveExceptionLogs) {
				if (log.isException__c) {
					newDebugEntries.add(entry);
				}
			}
		}
		insert newDebugEntries;
	}

	private static Boolean isValid(List<String> traceInfo) {
		return traceInfo != null && traceInfo.size()==6;
	}


}