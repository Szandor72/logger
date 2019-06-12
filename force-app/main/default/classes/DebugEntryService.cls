public with sharing class DebugEntryService {

	public static void saveLogs(List<Log__e> logs) {
		LoggerConfig config = LoggerConfig.getConfig();
		List<DebugEntry__c> newDebugEntries = new List<DebugEntry__c>();

		For (Log__e log: logs) {
			Boolean processDebugEntry = false;

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

			if (config.saveAllLogs) {

				processDebugEntry = true;
			} else if (config.saveExceptionLogs
			           && log.isException__c) {

				processDebugEntry = true;

			} else if (config.saveUserLogs
			           && FeatureManagement.checkPermission('EnableLogging')) {

				processDebugEntry = true;
			} else if (!String.isNotBlank(config.classNamesToLog)
			           && config.classNamesToLog.contains(entry.className__c)) {

				processDebugEntry = true;
			}

			if (processDebugEntry) {
				newDebugEntries.add(entry);
			}
		}
		insert newDebugEntries;
	}

	private static Boolean isValid(List<String> traceInfo) {
		return traceInfo != null && traceInfo.size()==6;
	}


}