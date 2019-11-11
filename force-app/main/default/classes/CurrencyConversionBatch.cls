global with sharing class CurrencyConversionBatch implements Database.Batchable<sObject>, 
            Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {
    global static Map<Id, String> errorsMap {get; set;}
    global Integer recordsProcessed = 0;
    
    global CurrencyConversionBatch(){
        errorsMap = new Map<Id, String>();
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        if(System.Label.LeadBatchReprocessFailedRecord.equalsIgnoreCase('false')){
            return Database.getQueryLocator([SELECT Id, Salary_in_USD__c,Salary_in_CAD__c,isFailed__c FROM Lead Where Salary_in_USD__c != null]);
        }else if(System.Label.LeadBatchReprocessFailedRecord.equalsIgnoreCase('true')){
            return Database.getQueryLocator([SELECT Id, Salary_in_USD__c,Salary_in_CAD__c,isFailed__c FROM Lead Where isFailed__c = true]);
        }
        return null;
    }

    global static void execute(Database.BatchableContext BC, List<Lead> allLeads) {       
        String endpoint;    
        CurrencyConversionWrapper currenyWrapper = null;  
        List<BatchFailed__e> allFailed = new List<BatchFailed__e>(); 
        //errorMap = new Map<Id, String>();

        try{       
            Http http = new Http();    
            HttpRequest request = new HttpRequest();
            String finalUrl = 'https://notfree.currconv.com/api/v7/convert?q=USD_CAD&compact=ultra&apiKey=0442a4e058b62d01bbcf';
                
            request.setEndpoint(finalUrl);
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                currenyWrapper = (CurrencyConversionWrapper) JSON.deserializeStrict(response.getBody(), CurrencyConversionWrapper.class);
            }

            for ( Lead singleLead : allLeads ){
                singleLead.Salary_in_CAD__c = singleLead.Salary_in_USD__c * currenyWrapper.USD_CAD;
                if(singleLead.isFailed__c) singleLead.isFailed__c = false;
            }   
            
            if(allLeads.size() > 0 && currenyWrapper != null){
                List<Database.SaveResult> dsrs =  Database.update(allLeads, false);
                Integer index = 0;
                for(Database.SaveResult dsr : dsrs){
                    
                    if(!dsr.isSuccess()){
                        String errMsg = dsr.getErrors()[0].getMessage();
                        BatchFailed__e batchFailed = new BatchFailed__e(
                            Message__c='Batch Failed after getting exception : ' + errMsg, 
                            Urgent__c=true,
                            ClassName__c = 'CurrencyConversionBatch',
                            recordId__c = allLeads[index].Id);
                        allFailed.add(batchFailed) ;
                    }
                    
                    //Faking the error Messaging
                    /*
                    if(index/5 == 0){
                        String errMsg = 'Fake Error Message';
                        BatchFailed__e batchFailed = new BatchFailed__e(
                            Message__c='Batch Failed after getting exception : ' + errMsg, 
                            Urgent__c=true,
                            ClassName__c = 'CurrencyConversionBatch',
                            recordId__c = allLeads[index].Id);
                        allFailed.add(batchFailed) ;
                    }
                    */
                    index++;
                }
            }
        }catch (Exception e){
            BatchFailed__e batchFailed = new BatchFailed__e(
                Message__c='Batch Failed after getting exception : ' + e.getMessage(), 
                Urgent__c=true,
                ClassName__c = 'CurrencyConversionBatch');
            allFailed.add(batchFailed) ;
        }finally{
            System.Debug('--++-- SD: Inside Finally Block');
            if(allFailed.size() > 0){
                System.Debug('--++-- SD: There are Published Platform Event');
                List<Database.SaveResult> results = EventBus.publish(allFailed);
                // Inspect publishing result for each event
                for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully published event.');
                    } else {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('Error returned: ' +
                                        err.getStatusCode() +
                                        ' - ' +
                                        err.getMessage());
                        }
                    }       
                }
            }
            System.Debug('--++-- SD: Published Platform Event');
        }

        
    } 

    global void finish(Database.BatchableContext BC){ 
    }
}
