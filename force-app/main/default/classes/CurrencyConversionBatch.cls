global with sharing class CurrencyConversionBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    global static Map<Id, String> errorsMap {get; set;}
    global Integer recordsProcessed = 0;
    
    global CurrencyConversionBatch(){
        errorsMap = new Map<Id, String>();
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, Salary_in_USD__c,Salary_in_CAD__c FROM Lead Where Salary_in_USD__c != null]);
    }

    global static void execute(Database.BatchableContext BC, List<Lead> allLeads) {       
        String endpoint;    
        CurrencyConversionWrapper currenyWrapper = null;   
        //errorMap = new Map<Id, String>();

        try{            
            Http http = new Http();    
            HttpRequest request = new HttpRequest();
            String finalUrl = 'https://free.currconv.com/api/v7/convert?q=USD_CAD&compact=ultra&apiKey=0442a4e058b62d01bbcf';
                
            request.setEndpoint(finalUrl);
            request.setMethod('GET');
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                currenyWrapper = (CurrencyConversionWrapper) JSON.deserializeStrict(response.getBody(), CurrencyConversionWrapper.class);
            }
        }catch (Exception e){
            // TODO
        }

        for ( Lead singleLead : allLeads ){
            singleLead.Salary_in_CAD__c = singleLead.Salary_in_USD__c * currenyWrapper.USD_CAD;
        }   
        
        if(allLeads.size() > 0 && currenyWrapper != null){
            List<Database.SaveResult> dsrs =  Database.update(allLeads, false);
            Integer index = 0;
            for(Database.SaveResult dsr : dsrs){
                if(!dsr.isSuccess()){
                    String errMsg = dsr.getErrors()[0].getMessage();
                    errorsMap.put(allLeads[index].Id, errMsg);
                }
                index++;
            }
        }
    } 

    global void finish(Database.BatchableContext BC){ 
        System.debug(recordsProcessed + ' records processed!');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        recordsProcessed = job.JobItemsProcessed;
        // call some utility to send email
        EmailUtility.sendEmail('sudipta.deb@gmail.com',null,'Batch Completed', 'Batch Processed : ' + recordsProcessed + ' records');
    
    }
}
