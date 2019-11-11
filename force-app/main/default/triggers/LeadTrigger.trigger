trigger LeadTrigger on Lead (before insert, after insert, before update, after update) {
    TriggerFactory.execute(Lead.SObjectType);
}