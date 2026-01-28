global class BookingDeliveryNotificationBatch implements Database.Batchable<sobject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Delivery_Address__c, Logistic_Company__c, Status__c,' +
            ' Contact__c, Account__c ' +
            'FROM Booking__c ' +
            'WHERE Delivery_Date__c = TODAY ' +
            'AND Status__c != \'Delivered\''
        );
    }

    global void execute(
        Database.BatchableContext bc,
        List<Booking__c> bookings
    ) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Booking__c b : bookings) {

            Set<Id> contactIds = new Set<Id>();

            if (b.Contact__c != null) {
                contactIds.add(b.Contact__c);
            }

            for (AccountContactRelation acr : [
                SELECT ContactId
                FROM AccountContactRelation
                WHERE AccountId = :b.Account__c
            ]) {
                contactIds.add(acr.ContactId);
            }

            for (Contact c : [
                SELECT Email FROM Contact WHERE Id IN :contactIds AND Email != null
            ]) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { c.Email });
                mail.setSubject('Delivery Notification');
                mail.setPlainTextBody(
                    'Your booking is scheduled for delivery today.\n\n' +
                    'Status: ' + b.Status__c + '\n' +
                    'Address: ' + b.Delivery_Address__c + '\n' +
                    'Logistics Partner: ' + b.Logistic_Company__c
                );
                emails.add(mail);
            }
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    global void finish(Database.BatchableContext bc) {}
}