public class BookingSharingService {

    public static void shareBooking(Id bookingId, Id accountId) {

        List<Booking__Share> shares = new List<Booking__Share>();

        for (AccountContactRelation acr : [
            SELECT ContactId
            FROM AccountContactRelation
            WHERE AccountId = :accountId
        ]) {
            shares.add(new Booking__Share(
                ParentId = bookingId,
                UserOrGroupId = acr.ContactId,
                AccessLevel = 'Read',
                RowCause = Schema.Booking__Share.RowCause.Manual
            ));
        }

        if (!shares.isEmpty()) {
            insert shares;
        }
    }
}