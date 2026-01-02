<template>
  <div v-if="show" class="modal-overlay" @click.self="closeModal">
    <!-- Notification Modal -->
    <NotificationModal 
      :show="showNotification" 
      :message="notificationMessage" 
      :type="notificationType"
      @close="showNotification = false" />
    
    <div class="modal-container">
      <div class="modal-header">
        <div class="header-content">
          <div class="transaction-icon">
            <svg width="36" height="36" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <rect x="3" y="4" width="18" height="16" rx="2" stroke="currentColor" stroke-width="2" fill="none"/>
              <path d="M7 8H17M7 12H13" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
              <circle cx="17" cy="17" r="4" fill="currentColor"/>
              <path d="M17 15V19M15 17H19" stroke="white" stroke-width="1.5" stroke-linecap="round"/>
            </svg>
          </div>
          <div>
            <h2 class="modal-title">Add Transaction</h2>
            <p class="modal-subtitle">Record new patient transaction</p>
          </div>
        </div>
      </div>

      <form class="modal-form" @submit.prevent="handleSubmit">
        <div class="form-row">
          <div class="form-group">
            <label for="patientName">Patient Name <span class="required">*</span></label>
            <input 
              type="text" 
              id="patientName" 
              v-model="formData.patientName" 
              class="form-input"
              placeholder="Enter patient name"
              required
            />
          </div>

          <div class="form-group">
            <label for="purpose">Purpose <span class="required">*</span></label>
            <select 
              id="purpose" 
              v-model="formData.purpose" 
              class="form-select"
              required
            >
              <option value="">Select purpose</option>
              <option value="Medical Consultation">Medical Consultation</option>
              <option value="Dental Check-Up & Treatment">Dental Check-Up & Treatment</option>
              <option value="Medical Certificate Issuance">Medical Certificate Issuance</option>
              <option value="Urinalysis Test">Urinalysis Test</option>
              <option value="Blood Pressure Monitoring">Blood Pressure Monitoring</option>
              <option value="First Aid Treatment">First Aid Treatment</option>
              <option value="Medicine Request">Medicine Request</option>
              <option value="Physical Examination">Physical Examination</option>
              <option value="Other">Other</option>
            </select>
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label for="date">Date <span class="required">*</span></label>
            <input 
              type="date" 
              id="date" 
              v-model="formData.date" 
              class="form-input"
              required
            />
          </div>

          <div class="form-group">
            <label for="timeStart">Time Start <span class="required">*</span></label>
            <input 
              type="time" 
              id="timeStart" 
              v-model="formData.timeStart" 
              class="form-input"
              required
            />
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label for="timeEnd">Time End <span class="required">*</span></label>
            <input 
              type="time" 
              id="timeEnd" 
              v-model="formData.timeEnd" 
              class="form-input"
              required
            />
          </div>

          <div class="form-group">
            <label for="status">Status <span class="required">*</span></label>
            <select 
              id="status" 
              v-model="formData.status" 
              class="form-select"
              required
            >
              <option value="">Select status</option>
              <option value="Done">Done</option>
              <option value="Pending">Pending</option>
              <option value="Cancelled">Cancelled</option>
            </select>
          </div>
        </div>

        <div class="form-group full-width">
          <label for="notes">Additional Notes</label>
          <textarea 
            id="notes" 
            v-model="formData.notes" 
            class="form-textarea"
            placeholder="Enter any additional notes or observations..."
            rows="3"
          ></textarea>
        </div>

        <div class="time-spent-display" v-if="timeSpent">
          <div class="time-spent-icon">⏱️</div>
          <div class="time-spent-info">
            <span class="time-label">Calculated Time Spent:</span>
            <span class="time-value">{{ timeSpent }}</span>
          </div>
        </div>

        <div class="form-actions">
          <button type="submit" class="btn-submit">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M5 13L9 17L19 7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            Submit Transaction
          </button>
          <button type="button" class="btn-close" @click="closeModal">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M18 6L6 18M6 6L18 18" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            </svg>
            Cancel
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import NurseProfileImg from '@/assets/NurseProfile.jpg'
import NotificationModal from './NotificationModal.vue'

export default {
  name: 'AddTransactionModal',
  components: {
    NotificationModal
  },
  props: {
    show: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      formData: {
        patientName: '',
        purpose: '',
        date: '',
        timeStart: '',
        timeEnd: '',
        status: 'Done',
        notes: ''
      },
      showNotification: false,
      notificationMessage: '',
      notificationType: 'info'
    }
  },
  computed: {
    timeSpent() {
      if (!this.formData.timeStart || !this.formData.timeEnd) {
        return ''
      }

      const start = new Date(`2000-01-01 ${this.formData.timeStart}`)
      const end = new Date(`2000-01-01 ${this.formData.timeEnd}`)
      
      if (end <= start) {
        return 'Invalid time range'
      }

      const diffMs = end - start
      const diffMins = Math.floor(diffMs / 60000)
      const hours = Math.floor(diffMins / 60)
      const mins = diffMins % 60

      if (hours > 0) {
        return mins > 0 ? `${hours} Hour${hours > 1 ? 's' : ''} ${mins} Min${mins > 1 ? 's' : ''}` : `${hours} Hour${hours > 1 ? 's' : ''}`
      } else {
        return `${mins} Min${mins > 1 ? 's' : ''}`
      }
    }
  },
  methods: {
    closeModal() {
      this.resetForm()
      this.$emit('close')
    },
    handleSubmit() {
      // Validate all required fields
      if (this.validateForm()) {
        // Emit the new transaction data to parent component
        // ID will be auto-generated by Supabase, patientAvatar handled by parent
        this.$emit('add-transaction', {
          ...this.formData,
          timeSpent: this.timeSpent
        })
        
        // Show success message
        this.showNotificationModal('Adding transaction...', 'info')
        
        // Reset form - parent will close modal after successful save
        this.resetForm()
      }
    },
    validateForm() {
      const requiredFields = ['patientName', 'purpose', 'date', 'timeStart', 'timeEnd', 'status']
      
      for (let field of requiredFields) {
        if (!this.formData[field] || this.formData[field] === '') {
          this.showNotificationModal('Please fill in all required fields', 'warning')
          return false
        }
      }

      // Validate time range
      const start = new Date(`2000-01-01 ${this.formData.timeStart}`)
      const end = new Date(`2000-01-01 ${this.formData.timeEnd}`)
      
      if (end <= start) {
        this.showNotificationModal('Time End must be after Time Start', 'warning')
        return false
      }

      // Validate date and time are not in the future
      const selectedDate = new Date(this.formData.date)
      const today = new Date()
      today.setHours(0, 0, 0, 0) // Reset time to midnight for date comparison
      
      // Only check if the date is actually in the future (beyond today)
      if (selectedDate > today) {
        this.showNotificationModal('Transaction date cannot be in the future', 'warning')
        return false
      }
      
      // If the date is today, check if the time is in the future
      if (selectedDate.toDateString() === today.toDateString()) {
        const now = new Date()
        const selectedDateTime = new Date(`${this.formData.date} ${this.formData.timeEnd}`)
        
        if (selectedDateTime > now) {
          this.showNotificationModal('Transaction time cannot be in the future', 'warning')
          return false
        }
      }
      
      return true
    },
    resetForm() {
      this.formData = {
        patientName: '',
        purpose: '',
        date: '',
        timeStart: '',
        timeEnd: '',
        status: 'Done',
        notes: ''
      }
    },
    showNotificationModal(message, type = 'info') {
      this.notificationMessage = message
      this.notificationType = type
      this.showNotification = true
    }
  },
  mounted() {
    // Set today's date as default
    const today = new Date().toISOString().split('T')[0]
    this.formData.date = today
  }
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
  padding: 20px;
  overflow-y: auto;
}

.modal-container {
  background: white;
  border-radius: 20px;
  width: 90%;
  max-width: 750px;
  max-height: 90vh;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  animation: slideIn 0.3s ease;
  display: flex;
  flex-direction: column;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-30px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.modal-header {
  background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%);
  color: white;
  padding: 24px 30px;
  border-bottom: 3px solid rgba(255, 255, 255, 0.2);
}

.header-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.transaction-icon {
  width: 56px;
  height: 56px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  backdrop-filter: blur(10px);
}

.modal-title {
  font-size: 24px;
  margin: 0;
  font-weight: 700;
  letter-spacing: -0.5px;
}

.modal-subtitle {
  font-size: 13px;
  margin: 4px 0 0 0;
  opacity: 0.9;
  font-weight: 400;
}

.modal-form {
  padding: 30px;
  display: flex;
  flex-direction: column;
  gap: 20px;
  overflow-y: auto;
  flex: 1;
}

.form-row {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group.full-width {
  grid-column: 1 / -1;
}

.form-group label {
  font-size: 14px;
  font-weight: 600;
  color: #4b5563;
}

.required {
  color: #ef4444;
  margin-left: 2px;
}

.form-input,
.form-select,
.form-textarea {
  padding: 12px 16px;
  border: 2px solid #e5e7eb;
  border-radius: 10px;
  font-size: 14px;
  color: #1f2937;
  background: white;
  transition: all 0.2s ease;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.form-input::placeholder,
.form-textarea::placeholder {
  color: #9ca3af;
}

.form-input:focus,
.form-select:focus,
.form-textarea:focus {
  outline: none;
  border-color: #6366f1;
  background: #f8f9ff;
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
}

.form-select {
  cursor: pointer;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%236b7280' d='M6 9L1 4h10z'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 12px center;
  padding-right: 36px;
}

.form-textarea {
  resize: vertical;
  min-height: 80px;
}

.form-input[type="date"]::-webkit-calendar-picker-indicator,
.form-input[type="time"]::-webkit-calendar-picker-indicator {
  cursor: pointer;
  filter: opacity(0.6);
}

.form-input[type="date"]::-webkit-calendar-picker-indicator:hover,
.form-input[type="time"]::-webkit-calendar-picker-indicator:hover {
  filter: opacity(1);
}

/* Time Spent Display */
.time-spent-display {
  background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
  border: 2px solid #86efac;
  border-radius: 12px;
  padding: 16px 20px;
  display: flex;
  align-items: center;
  gap: 14px;
  margin-top: -8px;
}

.time-spent-icon {
  font-size: 28px;
  flex-shrink: 0;
}

.time-spent-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.time-label {
  font-size: 12px;
  font-weight: 600;
  color: #166534;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.time-value {
  font-size: 18px;
  font-weight: 700;
  color: #15803d;
}

.form-actions {
  display: flex;
  gap: 12px;
  margin-top: 10px;
  padding-top: 20px;
  border-top: 2px solid #f3f4f6;
}

.btn-submit,
.btn-close {
  flex: 1;
  padding: 14px 24px;
  border: none;
  border-radius: 12px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.btn-submit {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

.btn-submit:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(16, 185, 129, 0.4);
}

.btn-close {
  background: linear-gradient(135deg, #ec4899 0%, #db2777 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(236, 72, 153, 0.3);
}

.btn-close:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(236, 72, 153, 0.4);
}

/* Custom Scrollbar */
.modal-form::-webkit-scrollbar {
  width: 8px;
}

.modal-form::-webkit-scrollbar-track {
  background: #f1f5f9;
  border-radius: 10px;
}

.modal-form::-webkit-scrollbar-thumb {
  background: linear-gradient(180deg, #cbd5e1 0%, #94a3b8 100%);
  border-radius: 10px;
}

.modal-form::-webkit-scrollbar-thumb:hover {
  background: linear-gradient(180deg, #94a3b8 0%, #64748b 100%);
}

/* Responsive Design */
@media (max-width: 768px) {
  .modal-container {
    width: 95%;
    border-radius: 16px;
  }

  .modal-header {
    padding: 20px;
  }

  .header-content {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }

  .transaction-icon {
    width: 48px;
    height: 48px;
  }

  .modal-title {
    font-size: 20px;
  }

  .modal-subtitle {
    font-size: 12px;
  }

  .modal-form {
    padding: 24px;
  }

  .form-row {
    grid-template-columns: 1fr;
    gap: 20px;
  }

  .form-actions {
    flex-direction: column;
  }

  .btn-submit,
  .btn-close {
    width: 100%;
  }
}
</style>
