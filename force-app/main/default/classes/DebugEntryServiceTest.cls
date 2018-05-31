@isTest
private class DebugEntryServiceTest {
    
    private static List<Log__e> getLogs() {
        List<Log__e> logs = new List<Log__e>();
        logs.add(getLog('firstCluster',0,'{},'));
        logs.add(getLog('secondCluster',4,'{},'));
        logs.add(getLog('firstCluster',1,'{},'));
        logs.add(getLog('firstCluster',2,'{},'));
        logs.add(getLog('secondCluster',0,'{},'));
        logs.add(getLog('firstCluster',4,'{},'));
        logs.add(getLog('secondCluster',2,'{},'));
        logs.add(getLog('secondCluster',1,'{},'));
        return logs;
    }
    
    private static Log__e getLog(String clusterId, Integer clusterSequence, String json) {
        Log__e logEvent = new Log__e(Trace__c = 'DebugEntryServiceTest.getLog()',
                                     clusterId__c = clusterId,
                                     clusterSequence__c = clusterSequence,
                                     LogEntriesJSON__c = json,
                                     startDateTime__c = system.now()
                                    );
        return logEvent;
    }
    
    @isTest
    private static void getClustersMap_Success() {
    	List<Log__e> logs = getLogs();
        System.assert(DebugEntryService.getClustersMap(logs)!=null,'valid return expected');
        System.assertEquals(2,DebugEntryService.getClustersMap(logs).keySet().size(),'2 clusters expected');
	}
    // for several logs ONE debug entry must be created if clusterId present !!
    // create a test case with two clusterIds, each id having 4 log entries in non linear sequence
    // assert only two debugentries are created, attachment name = clusterId, store attachmentId on debugEntry__c
    // //todo below needs to be refactored after debugentry service adaption
    //    List<debugEntry__c> entries = [SELECT LogEntryJSON__c, 
    //                                          cpuTimeUsage__c,
    //                                  		  clusterId__c
    //                                          FROM DebugEntry__c Limit 1000];
    //    System.assertEquals(1, entries.size(),'More than one debug entry inserted');
    //    System.assertNotEquals(null, entries[0].clusterId__c,'Cluster Id needs to be present');
}