public with sharing class LoggerConfig {
    public Boolean enableLogging { public get; private set; }
    public Boolean saveExceptionLogs { public get; private set; }
    public Boolean saveAllLogs { public get; private set; }
    public Boolean saveUserLogs { public get; private set; }
    public Boolean logMessagesOnly { public get; private set; }
    public String classNamesToLog { public get; private set; }
    public String transactionUUID { public get; private set; }

    public static Id runningUserId;

    // used for easier testing
    @testvisible
    private static Boolean enableLoggingOverride = false;
    @testvisible
    private static Boolean saveExceptionLogsOverride = false;
    @testvisible
    private static Boolean saveAllLogsOverride = false;
    @testvisible
    private static Boolean saveUserLogsOverride = false;
    @testvisible
    private static String classNamesToLogOverride = '';

    private static LoggerConfig loggerConfigInstance;

    private LoggerConfig() {
        enableLogging = false;
        saveAllLogs = false;
        saveExceptionLogs = false;
        saveUserLogs = false;
        classNamesToLog = '';
        logMessagesOnly = false;

        List<LoggerConfig__mdt> settings = [
            SELECT IsActive__c, LogMessagesOnly__c, LogsToSave__c, ClassNames__c, AdditionalClassNames__c
            FROM LoggerConfig__mdt
            WHERE IsActive__c = true
            ORDER BY DeveloperName ASC
        ];
        if (settings.size() == 0) {
            return;
        }
        LoggerConfig__mdt setting = settings[0];
        enableLogging = true;
        logMessagesOnly = setting.LogMessagesOnly__c;

        String logsToSave = setting.LogsToSave__c;
        switch on logsToSave {
            when 'AllLogs' {
                saveAllLogs = true;
            }
            when 'ExceptionOnly' {
                saveExceptionLogs = true;
            }
            when 'UserLogs' {
                saveUserLogs = true;
            }
            when 'ForClass' {
                classNamesToLog = setting.ClassNames__c + setting.AdditionalClassNames__c;
            }
        }

        if (Test.isRunningTest()) {
            enableLogging = enableLoggingOverride;
            saveExceptionLogs = saveExceptionLogsOverride;
            saveAllLogs = saveAllLogsOverride;
            saveUserLogs = saveUserLogsOverride;
            classNamesToLog = classNamesToLogOverride;
        }

        transactionUUID = Utils_UUID_Generation.newGuid();

        loggerConfigInstance = this;
    }

    public static LoggerConfig getConfig() {
        if (loggerConfigInstance == null) {
            loggerConfigInstance = new LoggerConfig();
        }
        return loggerConfigInstance;
    }
}
