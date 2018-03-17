trigger Logs on Log__e (after insert) {
    if (AppConfigMain.isActive && AppConfigSupport.enableLogging) {
        DebugEntryService.saveLogs(Trigger.new);
    }
}