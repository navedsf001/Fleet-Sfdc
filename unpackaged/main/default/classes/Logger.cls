public with sharing class Logger {

    private static List<Log__c> currentLogs;

    public enum LogType {ERROR, INFO, WARN, DEBUG}

    private class LogMessage {
        public String recordId {get; private set;}
        public String recordName {get; private set;}
        public List<Database.Error> loggedErrors {get; private set;}

        public LogMessage(String recordId, String recordName, List<Database.Error> loggedErrors) {
            this.recordId = recordId;
            this.recordName = recordName;
            this.loggedErrors = loggedErrors;
        }
    }

    private static void initCurrentLogs() {
        currentLogs = new List<Log__c>();
    }

    private static Log__c getLog(LogType logType, String stackTrace, String logMessage, String sourceClass) {
        Log__c log = new Log__c();
        log.Type__c = logType.name();
        log.Stack_Trace__c = stackTrace;
        log.Log_Message__c = logMessage;
        log.Source_Class__c = sourceClass;
        return log;
    }

    public static void persistLogs() {
        if(currentLogs != null && !currentLogs.isEmpty()) {
            insert currentLogs;
            initCurrentLogs();
        }
    }

    public static void log(LogType logType, String stackTrace, String logMessage, String sourceClass) {
        Log__c log = getLog(logType, stackTrace, logMessage, sourceClass);
        insert log;
    }

    public static void addLog(LogType logType, String stackTrace, String logMessage, String sourceClass) {
        if(currentLogs == null) {
            initCurrentLogs();
        }
        currentLogs.add(getLog(logType, stackTrace, logMessage, sourceClass));
    }

    public static void traceForErrors(String sourceClass, List<sObject> sObjList, List<Database.SaveResult> srList) {
        for(Integer srIndex=0; srIndex < srList.size(); srIndex++) {
            Database.SaveResult sr = srList[srIndex];
            if(!sr.isSuccess()) {
                String recordId = sObjList[srIndex].Id;
                String recordName = (String)sObjList[srIndex].get('Name');
                String logMessage = JSON.serializePretty(new LogMessage(recordId, recordName, sr.getErrors()));
                addLog(LogType.ERROR, null, logMessage, sourceClass);
            }
        }
    }
}