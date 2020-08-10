@istest
private class LoggerTest {
    private final static String CLASSNAME = 'LoggerTest';

    @istest
    private static void log_MessageGiven_Success() {
        LoggerConfig.enableLoggingOverride = true;
        String testString = 'Test Running';
        Test.startTest();
        Logger.log(testString);
        Test.stopTest();
        System.AssertEquals(testString, Logger.logEntries[0].description, 'Description must match testString');
    }

    @isTest
    private static void LogEntry_Constructor_Success() {
        Exception e;
        try {
            new Logger.LogEntry('EntryDescription');
        } catch (exception ex) {
            e = ex;
        }
        System.assert(e == null, 'No Exception on Log Entry Constructor');
    }

    @istest
    private static void log_setMethodName_Success() {
        LoggerConfig.enableLoggingOverride = true;
        Test.startTest();
        System.assertEquals(0, Logger.currentLoggingLevel, 'Loglevel = 0');
        Logger.log('Test message');
        Test.stopTest();
        System.assertEquals('log_setMethodName_Success', Logger.logEntries[0].methodName, 'methodName must match');
    }

    @istest
    private static void log_setLogEntryAttributes_Success() {
        LoggerConfig.enableLoggingOverride = true;
        Test.startTest();
        System.assertEquals(0, Logger.currentLoggingLevel, 'Loglevel = 0');
        Logger.log('Test message');
        Test.stopTest();
        System.assertNotEquals(null, Logger.logEntries[0].line, 'Line is filled');
        System.assertNotEquals(null, Logger.logEntries[0].column, 'Column is filled');
        System.assertEquals(CLASSNAME, Logger.logEntries[0].className, 'level must match');
        System.assertNotEquals(null, Logger.logEntries[0].transactionUUID, 'transactionUUID is filled');
        System.assertEquals(36, Logger.logEntries[0].transactionUUID.length(), 'transctionUUID length mismatch');
    }

    @istest
    private static void push_IncrementsLogLevel_Success() {
        LoggerConfig.enableLoggingOverride = true;
        Test.startTest();
        System.assertEquals(0, Logger.currentLoggingLevel, 'Loglevel = 0');
        Logger.push();
        Test.stopTest();
        System.assertEquals(1, Logger.currentLoggingLevel, 'Loglevel = 1');
    }

    @istest
    private static void push_setMethodName_Success() {
        LoggerConfig.enableLoggingOverride = true;
        Test.startTest();
        System.assertEquals(0, Logger.currentLoggingLevel, 'Loglevel = 0');
        Logger.push();
        Test.stopTest();
        System.assertEquals('push_setMethodName_Success', Logger.logEntries[0].methodName, 'methodName must match');
        System.assert(Logger.stackTrace.contains('push_setMethodName_Success'), 'StackTrace has been updated');
    }

    @istest
    private static void printLog_Success() {
        LoggerConfig.enableLoggingOverride = true;
        Test.startTest();
        Logger.push();
        Test.stopTest();
        System.assertEquals(false, String.isBlank(Logger.printlog()), 'Log returns successfully');
        System.assertEquals(true, Logger.printLog().contains('printLog_Success'), 'methodName appears in log');
    }

    @isTest
    private static void sendLog_Fail_EnableLoggingBeatsSaveAllLogs() {
        //set internal values, sendLog is a private method that is tested here
        Logger.currentClassName = 'Class';
        Logger.logEntries = new List<Logger.LogEntry>{ new Logger.LogEntry('test message') };
        Logger.cpuTimeStart = 300;
        Logger.cpuTimeEnd = 400;
        Logger.cpuTimeUsage = 100;
        LoggerConfig.enableLoggingOverride = false;
        LoggerConfig.saveExceptionLogsOverride = false;
        LoggerConfig.saveAllLogsOverride = true;
        Test.startTest();
        Database.SaveResult result = Logger.sendLog();
        Test.stopTest();
        System.assertEquals(true, result.isSuccess(), 'Event must save successfully');
        System.assertEquals(0, [SELECT COUNT() FROM DebugEntry__c], 'No Entry saved, logging deactivated');
    }

    @isTest
    private static void sendLog_Fail_InvalidTrace() {
        Logger.currentClassName = 'Class';
        Logger.cpuTimeStart = 300;
        Logger.cpuTimeEnd = 400;
        Logger.cpuTimeUsage = 100;
        Logger.logEntries = new List<Logger.LogEntry>{ new Logger.LogEntry('test message') };
        LoggerConfig.enableLoggingOverride = true;
        LoggerConfig.saveAllLogsOverride = true;
        Test.startTest();
        Database.SaveResult result = Logger.sendLog();
        Test.stopTest();
        System.assertEquals(true, result.isSuccess(), 'Event must save successfully');
        System.assertEquals(
            0,
            [SELECT COUNT() FROM DebugEntry__c],
            'No Entry saved, Logger lacks trace information. Only Classname given.'
        );
    }

    @isTest
    private static void sendLog_Success() {
        LoggerConfig.enableLoggingOverride = true;
        LoggerConfig.saveAllLogsOverride = true;
        Test.startTest();
        Logger.log('test message');
        Database.SaveResult result = Logger.sendLog();
        Test.stopTest();
        System.assertEquals(true, result.isSuccess(), 'Event must save successfully');
        List<debugEntry__c> entries = [SELECT Id, LogEntryJSON__c, cpuTimeUsage__c FROM DebugEntry__c LIMIT 10];
        System.assertEquals(1, entries.size(), 'One Entry saved');
        System.assertNotEquals(true, String.isBlank(entries[0].logEntryJSON__c), 'JSON is filled');
        System.assertNotEquals(null, entries[0].cpuTimeUsage__c, 'CPU Time is filled');
    }

    @isTest
    private static void sendLog_UserBasedLogging_Success() {
        LoggerConfig.enableLoggingOverride = true;
        LoggerConfig.saveUserLogsOverride = true;
        DebugEntryService.userHasCustomPermissionOverride = true;
        Test.startTest();
        Logger.log('test message');
        Database.SaveResult result = Logger.sendLog();
        Test.stopTest();
        System.assertEquals(true, result.isSuccess(), 'Event must save successfully');
        List<debugEntry__c> entries = [SELECT Id, LogEntryJSON__c, cpuTimeUsage__c FROM DebugEntry__c LIMIT 10];
        System.assertEquals(1, entries.size(), 'One Entry saved');
        System.assertNotEquals(true, String.isBlank(entries[0].logEntryJSON__c), 'JSON is filled');
        System.assertNotEquals(null, entries[0].cpuTimeUsage__c, 'CPU Time is filled');
    }

    @isTest
    private static void handleJSONLength_Success() {
        LoggerConfig.enableLoggingOverride = true;
        Logger.log('test message');
        Logger.log('test message with some more characters than the last one');
        Test.startTest();
        String longJSON = Logger.createJSON(Logger.logEntries);
        Logger.JSONCharLimit = 5;
        String shortJSON = Logger.createJSON(Logger.logEntries);
        System.assert(shortJSON.length() < longJSON.length(), 'Non prettified must be shorter than prettified JSON');
        System.assert(
            shortJSON.containsIgnoreCase('!!! Log size exceeded !!!'),
            'JSONs that are too long and get truncated are marked'
        );
    }

    @isTest
    private static void getLogJSON_Success() {
        LoggerConfig.enableLoggingOverride = true;
        Logger.log('test message');
        Logger.log('test message with some more characters than the last one');
        Test.startTest();
        String json = Logger.getLogJSON();
        Test.stopTest();
        system.assert(!String.isBlank(json), 'A non-empty string is returned');
    }

    @isTest
    private static void pop_DecrementsLogLevel_Success() {
        LoggerConfig.enableLoggingOverride = true;
        Test.startTest();
        Logger.push();
        Logger.push();
        System.assertEquals(2, Logger.currentLoggingLevel, 'Loglevel = 2');
        Logger.pop();
        Test.stopTest();
        System.assertEquals(1, Logger.currentLoggingLevel, 'Loglevel = 1');
    }

    @isTest
    private static void logTrigger_AllVariations_Success() {
        LoggerConfig.enableLoggingOverride = true;
        Test.startTest();
        Logger.logTrigger();
        System.assert(Logger.logEntries.size() > 0, 'At first we got entries');
        Logger.logTrigger();
        Test.stopTest();
        System.assertEquals(0, Logger.logEntries.size(), 'LogEntries empty after log Trigger completion');
    }

    @isTest
    private static void logException_Success() {
        LoggerConfig.enableLoggingOverride = true;
        Test.startTest();
        try {
            throw new DmlException();
        } catch (exception ex) {
            Logger.logException(ex);
        }
        Test.stopTest();
        System.assertEquals('logException_Success', Logger.logEntries[0].methodName, 'methodName must match');
        System.assert(Logger.exceptionTrace.contains('Script-thrown exception'), 'ExceptionTrace has been updated');
    }

    @isTest
    private static void popAll_DecrementsLogLevel_Success() {
        LoggerConfig.enableLoggingOverride = true;
        Test.startTest();
        Logger.push();
        Logger.push();
        System.assertEquals(2, Logger.currentLoggingLevel, 'Loglevel = 2');
        Logger.popAll();
        Test.stopTest();
        System.assertEquals(0, Logger.currentLoggingLevel, 'Loglevel = 0');
    }

    @isTest
    private static void disabledLogging() {
        LoggerConfig.enableLoggingOverride = false;
        Test.startTest();
        Logger.push();
        Logger.log('message');
        Logger.popAll();
        Logger.push();
        Test.stopTest();
        System.assertEquals(null, Logger.logEntries, 'No Entries Log initialised');
        System.assertEquals(0, Logger.currentLoggingLevel, 'Logging Level untouched');
        System.assertEquals(null, Logger.currentClassName, 'No traceStack parsed');
        System.AssertEquals(true, String.isBlank(Logger.printLog()), 'Print Log is empty');
    }
}
