trigger BookingTrigger on Booking__c (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        BookingTriggerHandler.logHistory(
            Trigger.new,
            Trigger.oldMap
        );
    }
}