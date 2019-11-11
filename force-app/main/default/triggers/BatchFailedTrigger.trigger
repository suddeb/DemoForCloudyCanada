trigger BatchFailedTrigger on BatchFailed__e (after insert) {
    System.Debug('--++-- SD: BatchFailedTrigger fired');

    Set<Id> leadIds = new Set<Id>();

    // Iterate through each notification.
    for (BatchFailed__e event : Trigger.New) {
        if (event.ClassName__c == 'CurrencyConversionBatch') {
            if(event.recordId__c != null){
                leadIds.add(Id.valueOf(event.recordId__c));
            }else{
                EmailUtility.sendEmail('sudipta.deb@gmail.com',null,'Batch Failed', 'Batch Failed to with message: ' + event.Message__c);
            }
        }
    }

    System.Debug('--++-- SD: leadIds: ' + leadIds.size());
    if(leadIds.size() > 0){
        //Fetch All Leads
        List<Lead> allLeads = [SELECT ID , isFailed__c FROM LEAD WHERE ID IN: leadIds];
        for(Lead singleLead : allLeads){
            singleLead.isFailed__c = true;
        }
        if(allLeads.size() > 0){
            Database.update(allLeads);
            EmailUtility.sendEmail('sudipta.deb@gmail.com',null,'Batch Failed', 'Batch Failed to process : ' + allLeads.size() + ' lead records');
        }
    }
    

}
