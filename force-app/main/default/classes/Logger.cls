public with sharing class Logger {

	public static Boolean loggingEnabled = AppConfigSupport.enableLogging;


	@testvisible private static String currentClassName, currentMethodName;
	@testvisible private static Integer currentLine, currentColumn, cpuTimeUsage, cpuTimeStart, cpuTimeEnd;
	@testvisible private static DateTime startDateTime;
	@testvisible private static Integer jsonCharLimit = 130000;


	@testvisible
	private class LogEntry {
		public final Integer level, line, column, cpuTime;
		public final String className, methodName, description;

		public LogEntry(String entryDescription) {
			this.level = decrementLevel && currentLoggingLevel > 0 ? currentLoggingLevel-1 : currentLoggingLevel;
			this.description = entryDescription;
			this.className = currentClassName;
			this.methodName = currentMethodName;
			this.line = currentLine;
			this.column = currentColumn;
			this.cpuTime = Limits.getCpuTime();
		}
	}

	@testvisible private static Integer currentLoggingLevel = 0;
	@testvisible private static List<System.TriggerOperation> executedTriggerOperations = new List<System.TriggerOperation>();
	@testvisible private static System.TriggerOperation currentTriggerOperation;

	@testvisible private static List<LogEntry> logEntries;

	@testvisible private static Boolean decrementLevel = false;

	public static List<String> stackTrace = new List<String>();

	//this will store stackTrace References even in managed/subscriber context
	// subscriber facing exception messages do not contain a stacktrace
	public static String exceptionTrace = '';

	@testvisible
	private static void log(String message, String stackTraceString) {
		if (!loggingEnabled) {
			return;
		}

		if(cpuTimeStart == null) {
			cpuTimeStart = Limits.getCpuTime();
		}

		if(startDateTime == null) {
			startDateTime = System.Now();
		}

		Matcher trace = generateMatcher(stackTraceString);
		setCurrentLogPosition(trace);

		if (logEntries==null) {
			logEntries = new List<LogEntry>();
		}
		logEntries.add(new LogEntry(message));
	}

	public static void logTrigger(System.TriggerOperation newTriggerOperation, String stackTraceString) {
		if (!loggingEnabled) {
			return;
		}

		if (newTriggerOperation == null) {
			return;
		}
		if (newTriggerOperation == currentTriggerOperation) {
			currentLoggingLevel-=1;
			log('end:' +String.valueOf(currentTriggerOperation), stackTraceString);
			popAll();
			logEntries = new List<LogEntry>();
			decrementLevel = false;
		} else {
			executedTriggerOperations.add(newTriggerOperation);
			currentTriggerOperation = newTriggerOperation;
			log('start:' +String.valueOf(currentTriggerOperation), stackTraceString);
			currentLoggingLevel+=1;
			decrementLevel = true;
		}


	}

	private static void logTrace(String stackTraceString) {
		log('',stackTraceString);
	}

	public static void log(String message) {
		String stackTraceString = new DmlException().getStackTraceString();
		stackTraceString = stackTraceString.substringAfter('\n');
		stackTraceString = stackTraceString.substringBefore('\n');
		log(message,stackTraceString);
	}

	public static void logException(Exception ex) {
		Integer line = ex.getLineNumber();
		String message = ex.getMessage();
		String exTrace = ex.getStackTraceString();

		String exceptionInfo = 'Exception on line: ' +line+ ' - ' + message;
		exceptionInfo +=' StackTrace: '+exTrace;


		//todo is exceptionTrace worth the trouble?
		// Which infos does it add that are not yet present?
		exceptionTrace = 'Exception on line: ' +line+ ' - ' + message;
		for (String trace : stackTrace) {
			exceptionTrace += ' | '+trace;
		}
		exceptionTrace +='|\n';
		log(exceptionTrace, exTrace);
	}

	public static void push() {
		if (!loggingEnabled) {
			return;
		}

		currentLoggingLevel+=1;

		String stackTraceString = new DmlException().getStackTraceString();
		stackTraceString = stackTraceString.substringAfter('\n');
		stackTraceString = stackTraceString.substringBefore('\n');
		logTrace(stackTraceString);
		stacktrace.add(currentMethodName);
	}

	public static void pop() {
		if (!loggingEnabled) {
			return;
		}

		if (currentLoggingLevel>0) {
			currentLoggingLevel-=1;
		}

		//todo decide if writing to debugs is clever
		if (currentLoggingLevel == 0) {
			if(Utility.isSandbox || Utility.isDevOrg) {
				System.Debug(LoggingLevel.Info,'Log '+System.Now()+' \n' + printLog());
			}
			sendLog();
			// add further functions here on exit
		}

		if (stackTrace.size()>0) {
			stackTrace.remove(stackTrace.size()-1);
		}
	}

	public static void popAll() {
		currentLoggingLevel=0;
		pop();
	}

	public static String printLog() {
		if (!loggingEnabled || logEntries == null) {
			return '';
		}

		//Adding padding for layout
		String padding = '+';

		for (Integer i = 0; i < 72; i++) {
			padding += '+';
		}

		String result = '';
		for(Logger.LogEntry entry : logEntries) {
			Integer entryLevel = entry.level < 0 ? 0 : entry.level;
			Integer endIndex = 3 * entryLevel;
			if (endIndex >= padding.length()) {
				endIndex = padding.length()-1;
			}

			result += padding.substring(0,endIndex)+'> ';
			result += String.isBlank(entry.description) ? entry.methodName  : '';
			result += !String.isBlank(entry.description) ? ' '+entry.description  : '';
			result += ' logLevel: '+entryLevel;
			result += '\n';

		}
		return result;
	}

	public static String getLogJSON() {
		return JSON.serializePretty(logEntries, true);
	}

	private static void setCurrentLogPosition(Matcher trace) {
		if (trace.find()) {
			if (String.isBlank(trace.group(3))) {
				currentClassName = trace.group(1);
				currentMethodName = prettifyMethodName(trace.group(2));
			} else {
				currentClassName = trace.group(1) + '.' + trace.group(2);
				currentMethodName = prettifyMethodName(trace.group(3));
			}
			currentLine = Integer.valueOf(trace.group(4));
			currentColumn = Integer.valueOf(trace.group(5));
		}
	}

	private static Matcher generateMatcher(String firstLine) {
		return Pattern.compile(
			'(?i)^(?:class\\.)?([^.]+)\\.?([^\\.\\:]+)?[\\.\\:]?([^\\.\\:]*): line (\\d+), column (\\d+)$'
			).matcher(firstLine);
	}

	private static String prettifyMethodName(String name) {
		return (name == null) ? 'invalid methodName' :
		       name.replace('<init>', '(constructor) ')
		       .replace('__sfdc_', '(getter/setter) ');
	}

	@testvisible
	private static Database.SaveResult sendLog() {
		cpuTimeEnd = Limits.getCpuTime();
		cpuTimeUsage = cpuTimeEnd - cpuTimeStart;
		Log__e logEvent = new Log__e();
		logEvent.Trace__c = currentClassName+':'+currentMethodName+':'+currentLine+':'+currentColumn+':'+cpuTimeUsage+':'+UserInfo.getUserId();
		logEvent.LogEntriesJSON__c = createJSON(logEntries);
		logEvent.isException__c = !String.isBlank(exceptionTrace);
		logEvent.startDateTime__c = startDateTime;
		if (currentTriggerOperation != null) {
			logEvent.TriggerOperation__c = String.valueOf(currentTriggerOperation);
		}

		return EventBus.publish(logEvent);
	}

	@testvisible
	private static String createJSON(List<LogEntry> entries) {
		String jsonString = JSON.serializePretty(entries);
		if (jsonString.length() < jsonCharLimit) {
			return jsonString;
		}
		jsonString = JSON.serialize(entries);
		if (jsonString.length() < jsonCharLimit) {
			return jsonString;
		}

		Integer truncateTo = Integer.ValueOf(entries.size() * 0.5);
		for (Integer i; i < truncateTo; i++) {
			entries.remove(entries.size()-1);
		}

		LogEntry entry  = new LogEntry('!!! Log size exceeded !!!');
		entries.add(entry);
		jsonString = JSON.serialize(entries);
		if (jsonString.length() < jsonCharLimit) {
			return jsonString;
		}

		entries.clear();
		entries.add(entry);
		return JSON.serializePretty(entries);
	}
}