public with sharing class LeadRatingMapUtil {
    private Set<String> companyNames;
    private List<Lead_Rating__mdt> allMappings;
    public static LeadRatingMapUtil leadRatingMapObj;

    public static LeadRatingMapUtil getLeadRatingMap(Set<String> companyNames){
        if(leadRatingMapObj == null){
            leadRatingMapObj = new LeadRatingMapUtil(companyNames);
        }
        return leadRatingMapObj;
    }

    private LeadRatingMapUtil(Set<String> companyNames){
        this.companyNames = companyNames;
        fetchMapping();
    }

    private void fetchMapping(){
        allMappings = [Select Id, Company_Name__c, Rating__c from Lead_Rating__mdt where Company_Name__c in: companyNames];
    }

    public String getMapping(String companyName){
        String retVal;
        for(Lead_Rating__mdt single: allMappings){
            if(single.Company_Name__c.equalsIgnoreCase(companyName)){
                retVal = single.Rating__c;
                break;
            }
        }
        return retVal;
    }


}