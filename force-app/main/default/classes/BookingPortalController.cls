public with sharing class BookingPortalController {

    @AuraEnabled(cacheable=true)
    public static List<Booking__c> getBookings() {
        return [
            SELECT Id, name, Status__c,
                   Delivery_Date__c, Delivery_Address__c,
                   Logistic_Company__c
            FROM Booking__c
            ORDER BY Delivery_Date__c DESC
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Booking_History__c> getBookingHistory(Id bookingId) {
        return [
            SELECT name, Old_Value__c,
                   New_Value__c, Change_Date__c
            FROM Booking_History__c
            WHERE Booking__c = :bookingId
            ORDER BY Change_Date__c DESC
        ];
    }
}