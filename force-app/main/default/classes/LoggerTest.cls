@istest
private class LoggerTest {
    
    private final static String CLASSNAME = 'LoggerTest';

    @istest
    private static void log_MessageGiven_Success() {
        String testString = 'Test Running';
        Test.startTest();
        Logger.log(testString);
        Test.stopTest();
        System.AssertEquals(testString, Logger.logEntries[0].description, 'Description must match testString');
    }

    @istest
    private static void log_setMethodName_Success() {
        Test.startTest();
        System.assertEquals(0, Logger.currentLoggingLevel,'Loglevel = 0');
        Logger.log('Test message');
        Test.stopTest();
        System.assertEquals('log_setMethodName_Success', Logger.logEntries[0].methodName, 'methodName must match');
    }

    @istest
    private static void log_setLogEntryAttributes_Success() {
        Test.startTest();
        System.assertEquals(0, Logger.currentLoggingLevel,'Loglevel = 0');
        Logger.log('Test message');
        Test.stopTest();
        System.assertNotEquals(null, Logger.logEntries[0].line, 'Line is filled');
        System.assertNotEquals(null, Logger.logEntries[0].column, 'Column is filled');
        System.assertEquals(CLASSNAME, Logger.logEntries[0].className, 'level must match');
    }

    @istest
    private static void push_IncrementsLogLevel_Success() {
        Test.startTest();
        System.assertEquals(0, Logger.currentLoggingLevel,'Loglevel = 0');
        Logger.push();
        Test.stopTest();
        System.assertEquals(1, Logger.currentLoggingLevel,'Loglevel = 1');
    }

    @istest
    private static void push_setMethodName_Success() {
        Test.startTest();
        System.assertEquals(0, Logger.currentLoggingLevel,'Loglevel = 0');
        Logger.push();
        Test.stopTest();
        System.assertEquals('push_setMethodName_Success', Logger.logEntries[0].methodName, 'methodName must match');
        System.assert(Logger.stackTrace.contains('push_setMethodName_Success'),'StackTrace has been updated');
    }

    @istest
    private static void printLog_Success() {
        Test.startTest();
        Logger.push();
        Test.stopTest();
        System.assertEquals(false, String.isBlank(Logger.printlog()),
                             'Log returns successfully');
        System.assertEquals(true, Logger.printLog().contains('printLog_Success'),
                            'methodName appears in log');
    }

    @isTest
    private static void sendLog_Fail_EnableLoggingBeatsSaveAllLogs() {
        //set internal values, sendLog is a private method that is tested here
        Logger.currentClassName = 'Class';
        Logger.logEntries = new List<Logger.LogEntry>{new Logger.LogEntry('test message')};
        Logger.cpuTimeStart = 300;
        Logger.cpuTimeEnd = 400;
        Logger.cpuTimeUsage = 100;
        AppConfigSupport.enableLogging = false; 
        AppConfigSupport.saveExceptionLogs = false; 
        AppConfigSupport.saveAllLogs=true;
        Test.startTest();
        Database.SaveResult result = Logger.sendLog();
        Test.stopTest();
        System.assertEquals(true, result.isSuccess(),
                            'Event must save successfully');
        System.assertEquals(0,[SELECT count() from DebugEntry__c],
                            'No Entry saved, logging deactivated');
    }

    @isTest
    private static void sendLog_Fail_InvalidTrace() {
        Logger.currentClassName = 'Class';
        Logger.cpuTimeStart = 300;
        Logger.cpuTimeEnd = 400;
        Logger.cpuTimeUsage = 100;
        Logger.logEntries = new List<Logger.LogEntry>{new Logger.LogEntry('test message')};
        AppConfigSupport.saveAllLogs=true;
        Test.startTest();
        Database.SaveResult result = Logger.sendLog();
        Test.stopTest();
        System.assertEquals(true, result.isSuccess(),
                            'Event must save successfully');
        System.assertEquals(0,[SELECT count() from DebugEntry__c],
                            'No Entry saved, Logger lacks trace information. Only Classname given.');
    }

    @isTest
    private static void sendLog_Success() {
        AppConfigSupport.saveAllLogs=true;
        Test.startTest();
        Logger.log('test message');
        Database.SaveResult result = Logger.sendLog();
        Test.stopTest();
        System.assertEquals(true, result.isSuccess(),
                            'Event must save successfully');
        List<debugEntry__c> entries = [SELECT Id, LogEntryJSON__c, cpuTimeUsage__c from DebugEntry__c Limit 10];
        System.assertEquals(1,entries.size(),
                            'One Entry saved');
        System.assertNotEquals(true, String.isBlank(entries[0].logEntryJSON__c),'JSON is filled');
        System.assertNotEquals(null, entries[0].cpuTimeUsage__c,'CPU Time is filled');       
        System.assert(entries[0].cpuTimeUsage__c > 0,'CPU Time is greater 0');             
    }

    @isTest
    private static void pop_DecrementsLogLevel_Success() {
        Test.startTest();
        Logger.push();
        Logger.push();
        System.assertEquals(2, Logger.currentLoggingLevel,'Loglevel = 2');
        Logger.pop();
        Test.stopTest();
        System.assertEquals(1, Logger.currentLoggingLevel,'Loglevel = 1');
    }

    @isTest
    private static void logException_Success() {
        Test.startTest();
        try {
            throw new DmlException();
        } catch (exception ex) {
            Logger.logException(ex);
        }
        Test.stopTest();
        System.assertEquals('logException_Success', Logger.logEntries[0].methodName, 
                                'methodName must match');
        System.assert(Logger.exceptionTrace.contains('Script-thrown exception'),
                        'ExceptionTrace has been updated');
    }

    @isTest
    private static void popAll_DecrementsLogLevel_Success() {
        Test.startTest();
        Logger.push();
        Logger.push();
        System.assertEquals(2, Logger.currentLoggingLevel,'Loglevel = 2');
        Logger.popAll();
        Test.stopTest();
        System.assertEquals(0, Logger.currentLoggingLevel,'Loglevel = 0');
    }



    @isTest
    private static void disabledLogging() {
        AppConfigSupport.enableLogging = false;
        Test.startTest();
        Logger.push();
        Logger.log('message');
        Logger.popAll();
        Logger.push();
        Test.stopTest();
        System.assertEquals(null, Logger.logEntries, 'No Entries Log initialised');
        System.assertEquals(0, Logger.currentLoggingLevel, 'Logging Level untouched');
        System.assertEquals(null, Logger.currentClassName, 'No traceStack parsed');
        System.AssertEquals(true, String.isBlank(Logger.printLog()),'Print Log is empty');
    }
}