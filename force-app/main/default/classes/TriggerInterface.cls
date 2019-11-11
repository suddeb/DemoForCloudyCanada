public interface TriggerInterface {
    
    void beforeInsert(List<SObject> newObjects);
    void beforeUpdate(List<SObject> newObjects, List<SObject> oldObjects, Map<Id,SObject> oldMapObject);
    
    void afterInsert(List<SObject> newObjects);
    void afterUpdate(List<SObject> newObjects, List<SObject> oldObjects, Map<Id,SObject> oldMapObject);
}