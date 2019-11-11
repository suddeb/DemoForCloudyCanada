public with sharing class TriggerFactory {
    private static TriggerInterface handler;

    public static void execute(Schema.SObjectType objectType){
        getHandler(objectType);
        if(handler == null) {
            //Throw Exception and Preferrable store in some internal logging framework
        }else{
            run();
        }
    }

    private static void getHandler(Schema.SObjectType objectType){
        handler = null;
        String className = getClassesToCallForObject(String.valueOf(objectType));
        if(!className.equalsIgnoreCase('NA')){
            Type classType = Type.forName(className);
            Object classInstance = classType.newInstance();

            if(classInstance instanceof TriggerInterface) {
                handler = (TriggerInterface)classInstance;
            }
        }
    }

    private static void run(){
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                handler.beforeInsert(Trigger.New);
            }
            if(Trigger.isUpdate){
                handler.beforeUpdate(Trigger.New, Trigger.Old, Trigger.oldMap);
            }
        }
    }

    private static String getClassesToCallForObject(String objectName) {
        String retVal = 'NA';
        //Getting the Handler configuration
        List<Trigger_Handler_Map__mdt> allHandlers = [Select Object__c, Handler_Class__c, Active__c from Trigger_Handler_Map__mdt];
        for(Trigger_Handler_Map__mdt single : allHandlers){
            if(single.Object__c.equalsIgnoreCase(objectName) && single.Active__c){
                retVal = single.Handler_Class__c;
                break;
            }
        }
        return retVal;
    }
}