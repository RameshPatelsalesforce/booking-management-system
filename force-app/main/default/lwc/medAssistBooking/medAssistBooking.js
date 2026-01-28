import { LightningElement, track, wire } from 'lwc';
import getActiveDoctors from '@salesforce/apex/MedAssistController.getActiveDoctors';
import getAvailableSlots from '@salesforce/apex/MedAssistController.getAvailableSlots';
import bookAppointment from '@salesforce/apex/MedAssistController.bookAppointment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MedAssistBooking extends LightningElement {

    @track patientName = '';
    @track selectedDoctor;
    @track selectedDate;
    @track selectedSlot;

    @track doctorOptions = [];
    @track slotOptions = [];

    // Load doctors
    @wire(getActiveDoctors)
    wiredDoctors({ data, error }) {
        if (data) {
            this.doctorOptions = data.map(doc => ({
                label: `${doc.Name} (${doc.Specialization__c})`,
                value: doc.Id
            }));
        }
    }

    handleNameChange(e) {
        this.patientName = e.target.value;
    }

    handleDoctorChange(e) {
        this.selectedDoctor = e.detail.value;
        this.loadSlots();
    }

    handleDateChange(e) {
        this.selectedDate = e.target.value;
        this.loadSlots();
    }

    handleSlotChange(e) {
        this.selectedSlot = e.detail.value;
    }

    loadSlots() {
        if (this.selectedDoctor && this.selectedDate) {
            getAvailableSlots({
                doctorId: this.selectedDoctor,
                selectedDate: this.selectedDate
            })
            .then(result => {
                this.slotOptions = result.map(slot => ({
                    label: `${slot.From_Time__c} - ${slot.To_Time__c}`,
                    value: slot.Id
                }));
            })
            .catch(() => {
                this.slotOptions = [];
            });
        }
    }

    bookAppointment() {
        if (!this.patientName || !this.selectedDoctor || !this.selectedDate || !this.selectedSlot) {
            this.showToast('Error', 'Please fill all fields', 'error');
            return;
        }

        bookAppointment({
            patientName: this.patientName,
            doctorId: this.selectedDoctor,
            slotId: this.selectedSlot,
            appointmentDate: this.selectedDate
        })
        .then(() => {
            this.showToast('Success', 'Appointment booked successfully', 'success');
            this.resetForm();
        })
        .catch(error => {
            this.showToast('Error', error.body.message, 'error');
        });
    }

    resetForm() {
        this.patientName = '';
        this.selectedDoctor = null;
        this.selectedDate = null;
        this.selectedSlot = null;
        this.slotOptions = [];
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}
