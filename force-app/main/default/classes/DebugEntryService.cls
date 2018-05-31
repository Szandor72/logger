public with sharing class DebugEntryService {
    
    public static void saveLogs(List<Log__e> logs) {
        //
        List<DebugEntry__c> newDebugEntries = new List<DebugEntry__c>();
        List<DebugEntry__c> debugEntriesToInsert = new List<DebugEntry__c>();
        List<Log__e> clusteredLogs = new List<Log__e>();
        // no clusterId
        // clusterId 	
        For (Log__e log: logs) {
            if(!isValid(log.Trace__c.split(':'))) {
                return;
            }
            if(log.clusterId__c == null) {
                newDebugEntries.add(convertLogToDebugEntry(log));
            } else {
                clusteredLogs.add(log);
            }
            
            if (AppConfigSupport.saveAllLogs) {
                debugEntriesToInsert.addAll(newDebugEntries);
            } else if (AppConfigSupport.saveExceptionLogs) {
                for (DebugEntry__c entry : newDebugEntries) {
                    if (entry.isException__c) {
                        debugEntriesToInsert.add(entry);
                    }
                }    
            }
            
        }
        
        insert debugEntriesToInsert;
    }
    
    @testvisible
    private static Boolean isValid(List<String> traceInfo) {
        return traceInfo != null && traceInfo.size()==6;
    }
    
    private static DebugEntry__c convertLogToDebugEntry(Log__e log) {
        List<String> traceInfo = log.Trace__c.split(':');
        DebugEntry__c entry = new DebugEntry__c(className__c = traceInfo[0],
                                                methodName__c = traceInfo[1],
                                                Line__c = Integer.ValueOf(traceInfo[2]),
                                                Column__c = Integer.ValueOf(traceInfo[3]),
                                                cpuTimeUsage__c = Integer.ValueOf(traceInfo[4]),
                                                runningUser__c = traceInfo[5],
                                                startDateTime__c = log.startDateTime__c,
                                                logEntryJSON__c = log.LogEntriesJSON__c,
                                                isException__c = log.isException__c
                                               );
        return entry; 
    }
    
    @testvisible
    private static void convertLogClusterToDebugEntry(List<Log__e> logClusters) {
        
    }
    
    @testvisible
    private static Map<String,List<Log__e>> getClustersMap(List<Log__e> logClusters) {
        Map<String,List<Log__e>> clustersMap = new Map<String,List<Log__e>>();
        return clustersMap;
    }
    
    
}