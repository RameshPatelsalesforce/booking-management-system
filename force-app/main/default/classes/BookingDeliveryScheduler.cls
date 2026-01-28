global class BookingDeliveryScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(
            new BookingDeliveryNotificationBatch(),
            200
        );
    }
}