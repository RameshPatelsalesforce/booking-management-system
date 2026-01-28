import { LightningElement, track, wire } from 'lwc';
import getBookings from '@salesforce/apex/BookingPortalController.getBookings';
import getBookingHistory from '@salesforce/apex/BookingPortalController.getBookingHistory';

export default class BookingPortal extends LightningElement {

    @track bookings = [];
    @track filteredBookings = [];
    @track history = [];
    @track isLoading = true;
    @track noData = false;

    statusFilter = '';
    selectedBookingId;

    // STATUS OPTIONS
    get statusOptions() {
        return [
            { label: 'All', value: '' },
            { label: 'Draft', value: 'Draft' },
            { label: 'Scheduled', value: 'Scheduled' },
            { label: 'In Transit', value: 'In Transit' },
            { label: 'Delivered', value: 'Delivered' },
            { label: 'Cancelled', value: 'Cancelled' }
        ];
    }

    // LOAD BOOKINGS
    @wire(getBookings)
    wiredBookings({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.bookings = data;
            this.filteredBookings = data;
            this.noData = data.length === 0;
        } else if (error) {
            console.error(error);
            this.noData = true;
        }
    }

    // FILTER HANDLER
    handleStatusChange(event) {
        this.statusFilter = event.detail.value;
        this.applyFilter();
    }

    applyFilter() {
        if (!this.statusFilter) {
            this.filteredBookings = this.bookings;
        } else {
            this.filteredBookings = this.bookings.filter(
                b => b.Status__c === this.statusFilter
            );
        }
    }

    // BOOKING CLICK
    handleBookingSelect(event) {
        this.selectedBookingId = event.currentTarget.dataset.id;
        this.loadHistory();
    }

    // LOAD HISTORY
    async loadHistory() {
        try {
            this.history = await getBookingHistory({
                bookingId: this.selectedBookingId
            });
        } catch (error) {
            console.error(error);
        }
    }
}