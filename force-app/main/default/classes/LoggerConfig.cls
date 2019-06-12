public with sharing class LoggerConfig {

	public Boolean enableLogging { public get; private set;}
	public Boolean saveExceptionLogs {public get; private set;}
	public Boolean saveAllLogs { public get; private set;}
	public Boolean saveUserLogs { public get; private set;}
	public String classNamesToLog {public get; private set;}

	// used for easier testing
	@testvisible private static Boolean enableLoggingOverride = false;
	@testvisible private static Boolean saveExceptionLogsOverride = false;
	@testvisible private static Boolean saveAllLogsOverride = false;
	@testvisible private static Boolean saveUserLogsOverride = false;
	@testvisible private static String classNamesToLogOverride = '';

	private static LoggerConfig loggerConfigInstance;

	private LoggerConfig() {
		if (Test.isRunningTest()) {
			enableLogging = enableLoggingOverride;
			saveExceptionLogs= saveExceptionLogsOverride;
			saveAllLogs = saveAllLogsOverride;
			saveUserLogs = saveExceptionLogsOverride;
			classNamesToLog = classNamesToLogOverride;
			return;
		}

		enableLogging = false;
		saveAllLogs = false;
		saveExceptionLogs = false;
		saveUserLogs = false;
		classNamesToLog = '';

		LoggerConfig__mdt setting = [SELECT IsActive__c, LogsToSave__c, ClassNames__c, AdditionalClassNames__c FROM LoggerConfig__mdt WHERE IsActive__c = true ORDER BY DeveloperName ASC LIMIT 1];
		if (setting == null) {
			enableLogging = false;
			return;
		}
		enableLogging = true;

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
			when 'ByClass' {
				classNamesToLog =  setting.ClassNames__c + setting.AdditionalClassNames__c;
			}
		}
		loggerConfigInstance = this;
	}

	public static LoggerConfig getConfig() {
		if (loggerConfigInstance == null) {
			loggerConfigInstance = new LoggerConfig();
		}
		return loggerConfigInstance;
	}
}
