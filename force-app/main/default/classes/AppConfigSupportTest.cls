@isTest
private class AppConfigSupportTest {
    private static void testConfigurationVariables() {
        system.assertNotEquals(null, AppConfigSupport.enableLogging, 'enableLogging must not be null');
    }
}

