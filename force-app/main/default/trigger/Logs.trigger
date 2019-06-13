trigger Logs on Log__e (after insert) {
		private static LoggerConfig config = LoggerConfig.getConfig();
	if (config.enableLogging) {
        DebugEntryService.saveLogs(Trigger.new);
	}
    
}