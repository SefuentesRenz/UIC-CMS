<template>
  <div v-if="show" class="modal-overlay" @click.self="closeModal">
    <div class="modal-container">
      <div class="modal-header">
        <div class="header-content">
          <div class="transaction-icon">
            <svg width="36" height="36" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <rect x="3" y="4" width="18" height="16" rx="2" stroke="currentColor" stroke-width="2" fill="none"/>
              <path d="M7 8H17M7 12H13" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
              <path d="M18 16L21 13L18 10" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </div>
          <div>
            <h2 class="modal-title">Transaction Details</h2>
            <p class="modal-subtitle">View and edit transaction information</p>
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
          <button type="submit" class="btn-save">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M19 21H5C4.46957 21 3.96086 20.7893 3.58579 20.4142C3.21071 20.0391 3 19.5304 3 19V5C3 4.46957 3.21071 3.96086 3.58579 3.58579C3.96086 3.21071 4.46957 3 5 3H16L21 8V19C21 19.5304 20.7893 20.0391 20.4142 20.4142C20.0391 20.7893 19.5304 21 19 21Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M17 21V13H7V21M7 3V8H15" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            Save Changes
          </button>
          <button type="button" class="btn-delete" @click="confirmDelete">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M3 6H5H21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M8 6V4C8 3.46957 8.21071 2.96086 8.58579 2.58579C8.96086 2.21071 9.46957 2 10 2H14C14.5304 2 15.0391 2.21071 15.4142 2.58579C15.7893 2.96086 16 3.46957 16 4V6M19 6V20C19 20.5304 18.7893 21.0391 18.4142 21.4142C18.0391 21.7893 17.5304 22 17 22H7C6.46957 22 5.96086 21.7893 5.58579 21.4142C5.21071 21.0391 5 20.5304 5 20V6H19Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            Delete
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
export default {
  name: 'EditTransactionModal',
  props: {
    show: {
      type: Boolean,
      default: false
    },
    transaction: {
      type: Object,
      default: () => ({})
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
        status: '',
        notes: ''
      }
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
  watch: {
    transaction: {
      handler(newVal) {
        if (newVal && Object.keys(newVal).length > 0) {
          this.formData = {
            patientName: newVal.patientName || '',
            purpose: newVal.purpose || '',
            date: newVal.date || '',
            timeStart: newVal.timeStart || '',
            timeEnd: newVal.timeEnd || '',
            status: newVal.status || '',
            notes: newVal.notes || ''
          }
        }
      },
      immediate: true,
      deep: true
    }
  },
  methods: {
    closeModal() {
      this.$emit('close')
    },
    handleSubmit() {
      // Validate all required fields
      if (this.validateForm()) {
        // Emit the updated transaction data to parent component
        this.$emit('update-transaction', {
          ...this.transaction,
          ...this.formData,
          timeSpent: this.timeSpent
        })
        
        // Show success message
        alert('Transaction updated successfully!')
        
        // Close modal
        this.closeModal()
      }
    },
    confirmDelete() {
      if (confirm(`Are you sure you want to delete this transaction for ${this.formData.patientName}?`)) {
        this.$emit('delete-transaction', this.transaction.id)
        alert('Transaction deleted successfully!')
        this.closeModal()
      }
    },
    validateForm() {
      const requiredFields = ['patientName', 'purpose', 'date', 'timeStart', 'timeEnd', 'status']
      
      for (let field of requiredFields) {
        if (!this.formData[field] || this.formData[field] === '') {
          alert('Please fill in all required fields')
          return false
        }
      }

      // Validate time range
      const start = new Date(`2000-01-01 ${this.formData.timeStart}`)
      const end = new Date(`2000-01-01 ${this.formData.timeEnd}`)
      
      if (end <= start) {
        alert('Time End must be after Time Start')
        return false
      }

      // Validate date is not in the future
      const today = new Date().toISOString().split('T')[0]
      if (this.formData.date > today) {
        alert('Transaction date cannot be in the future')
        return false
      }
      
      return true
    }
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
  background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%);
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
  border-color: #8b5cf6;
  background: #faf5ff;
  box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.1);
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

.btn-save,
.btn-delete,
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

.btn-save {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

.btn-save:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(16, 185, 129, 0.4);
}

.btn-delete {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
}

.btn-delete:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(239, 68, 68, 0.4);
}

.btn-close {
  background: linear-gradient(135deg, #6b7280 0%, #4b5563 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(107, 114, 128, 0.3);
}

.btn-close:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(107, 114, 128, 0.4);
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

  .btn-save,
  .btn-delete,
  .btn-close {
    width: 100%;
  }
}
</style>
