@isTest
private class UtilityTest {
    @isTest
    private static void testIdUniquenessSingleCall() {
        system.assertNotEquals(Utility.getUniqueId(),Utility.getUniqueId(),'consecutive calls must produce distinct Ids');
    }

    @isTest
    private static void testIdUniquenessMultipleCalls  () {
        Set<String> ids = new Set<string>();
        for(Integer i = 0; i < 10000; i++) {
            ids.add(Utility.getUniqueId());
        }
        system.assertEquals(10000,ids.size(),'consecutive calls must produce distinct Ids');
    }
}
