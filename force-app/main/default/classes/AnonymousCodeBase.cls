public with sharing class AnonymousCodeBase {
    public AnonymousCodeBase() {

    }

    /*

    //Call Batch class
    CurrencyConversionBatch myBatchObject = new CurrencyConversionBatch(); 
    Id batchId = Database.executeBatch(myBatchObject);

    //Clear Lead Field
    List<Lead> allLeads = [Select Id, Salary_in_CAD__c, Salary_in_USD__c from Lead];
    for(Lead singleLead : allLeads){
        singleLead.Salary_in_CAD__c = 0;
        singleLead.Salary_in_USD__c = 0;
    }
    update allLeads;

    //Update Lead Field
    List<Lead> allLeads = [Select Id, Salary_in_CAD__c, Salary_in_USD__c from Lead];
    for(Lead singleLead : allLeads){
        singleLead.Salary_in_USD__c = Integer.valueof((Math.random() * 200000));
    }
    update allLeads;

    */

}
