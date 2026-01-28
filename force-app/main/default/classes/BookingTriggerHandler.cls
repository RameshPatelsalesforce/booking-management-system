public class BookingTriggerHandler {

    public static void logHistory(
        List<Booking__c> newList,
        Map<Id, Booking__c> oldMap
    ) {
        List<Booking_History__c> historyList = new List<Booking_History__c>();

        for (Booking__c newRec : newList) {
            Booking__c oldRec = oldMap.get(newRec.Id);

            // Status Change
            if (newRec.Status__c != oldRec.Status__c) {
                historyList.add(createHistory(
                    newRec.Id,
                    'Status__c',
                    oldRec.Status__c,
                    newRec.Status__c
                ));
            }

            // Delivery Date Change
            if (newRec.Delivery_Date__c != oldRec.Delivery_Date__c) {
                historyList.add(createHistory(
                    newRec.Id,
                    'Delivery_Date__c',
                    String.valueOf(oldRec.Delivery_Date__c),
                    String.valueOf(newRec.Delivery_Date__c)
                ));
            }
        }

        if (!historyList.isEmpty()) {
            insert historyList;
        }
    }

    private static Booking_History__c createHistory(
        Id bookingId,
        String fieldName,
        String oldVal,
        String newVal
    ) {
        return new Booking_History__c(
            Booking__c = bookingId,
            Change_Date__c = System.now(),
            Changed_By__c = UserInfo.getUserId(),
            Name = fieldName,
            Old_Value__c = oldVal,
            New_Value__c = newVal
        );
    }
}