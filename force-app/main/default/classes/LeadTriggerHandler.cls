public with sharing class LeadTriggerHandler implements TriggerInterface{
    public void beforeInsert(List<SObject> newObjects){
        System.Debug('Inside beforeInsert');
        List<Lead> leads = (List<Lead>)newObjects;
        updateRatings(leads);
    }

    public void beforeUpdate(List<SObject> newObjects, List<SObject> oldObjects, Map<Id,SObject> oldMapObject){
        System.Debug('Inside beforeUpdate');
        List<Lead> leads = (List<Lead>)newObjects;
        updateRatings(leads);
    }
    
    public void afterInsert(List<SObject> newObjects){
        System.Debug('Inside afterInsert');
    }

    public void afterUpdate(List<SObject> newObjects, List<SObject> oldObjects, Map<Id,SObject> oldMapObject){
        System.Debug('Inside afterUpdate');
    }

    private void updateRatings(List<Lead> allLeads){
        Set<String> companyNames = new Set<String>();
        for(Lead singleLead : allLeads){
            companyNames.add(singleLead.Company);
        }
        for(Lead singleLead : allLeads){
            singleLead.Rating = LeadRatingMapUtil.getLeadRatingMap(companyNames).getMapping(singleLead.Company);
        }
    }
}
