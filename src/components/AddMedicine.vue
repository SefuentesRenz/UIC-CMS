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
          <div class="medicine-icon">
            <svg width="36" height="36" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <rect x="3" y="3" width="18" height="18" rx="2" stroke="currentColor" stroke-width="2" fill="none"/>
              <path d="M12 8V16M8 12H16" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            </svg>
          </div>
          <div>
            <h2 class="modal-title">Add Medicine Stocks</h2>
            <p class="modal-subtitle">Fill in the medicine details</p>
          </div>
        </div>
      </div>

      <form class="modal-form" @submit.prevent="handleSubmit">
        <div class="form-group">
          <label for="medicineName">Medicine Name <span class="required">*</span></label>
          <input 
            type="text" 
            id="medicineName" 
            v-model="formData.medicineName" 
            class="form-input"
            placeholder="Enter medicine name"
            required
          />
        </div>

        <div class="form-group">
          <label for="dateAdded">Date Added <span class="required">*</span></label>
          <input 
            type="date" 
            id="dateAdded" 
            v-model="formData.dateAdded" 
            class="form-input"
            required
          />
        </div>

        <div class="form-group">
          <label for="quantity">Quantity <span class="required">*</span></label>
          <input 
            type="number" 
            id="quantity" 
            v-model.number="formData.quantity" 
            class="form-input"
            placeholder="Enter quantity"
            min="1"
            required
          />
        </div>

        <div class="form-group">
          <label for="expirationDate">Expiration Date <span class="required">*</span></label>
          <input 
            type="date" 
            id="expirationDate" 
            v-model="formData.expirationDate" 
            class="form-input"
            required
          />
        </div>

        <div class="form-actions">
          <button type="submit" class="btn-submit">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M5 13L9 17L19 7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            Submit
          </button>
          <button type="button" class="btn-close" @click="closeModal">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M18 6L6 18M6 6L18 18" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            </svg>
            Close
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import NotificationModal from './NotificationModal.vue'

export default {
  name: 'AddMedicine',
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
        medicineName: '',
        dateAdded: '',
        quantity: '',
        expirationDate: ''
      },
      showNotification: false,
      notificationMessage: '',
      notificationType: 'info'
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
        // Emit the new medicine data to parent component
        this.$emit('add-medicine', {
          ...this.formData,
          id: Date.now(), // Generate unique ID
          name: this.formData.medicineName,
          status: 'Active' // Default status
        })
        
        // Show success message
        this.showNotificationModal('Medicine added successfully!', 'success')
        
        // Reset form and close modal after delay
        setTimeout(() => {
          this.closeModal()
        }, 1500)
      }
    },
    validateForm() {
      const requiredFields = ['medicineName', 'dateAdded', 'quantity', 'expirationDate']
      
      for (let field of requiredFields) {
        if (!this.formData[field] || this.formData[field] === '') {
          this.showNotificationModal('Please fill in all required fields', 'warning')
          return false
        }
      }

      // Validate quantity is positive
      if (this.formData.quantity <= 0) {
        this.showNotificationModal('Quantity must be greater than 0', 'warning')
        return false
      }

      // Validate expiration date is in the future
      const today = new Date().toISOString().split('T')[0]
      if (this.formData.expirationDate <= today) {
        this.showNotificationModal('Expiration date must be in the future', 'warning')
        return false
      }

      // Validate date added is not in the future
      if (this.formData.dateAdded > today) {
        this.showNotificationModal('Date added cannot be in the future', 'warning')
        return false
      }
      
      return true
    },
    resetForm() {
      this.formData = {
        medicineName: '',
        dateAdded: '',
        quantity: '',
        expirationDate: ''
      }
    },
    showNotificationModal(message, type = 'info') {
      this.notificationMessage = message
      this.notificationType = type
      this.showNotification = true
    }
  },
  mounted() {
    // Set today's date as default for dateAdded
    const today = new Date().toISOString().split('T')[0]
    this.formData.dateAdded = today
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
  max-width: 550px;
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
  background: linear-gradient(135deg, #ec4899 0%, #d946ef 100%);
  color: white;
  padding: 24px 30px;
  border-bottom: 3px solid rgba(255, 255, 255, 0.2);
}

.header-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.medicine-icon {
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

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
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

.form-input {
  padding: 12px 16px;
  border: 2px solid #e5e7eb;
  border-radius: 10px;
  font-size: 14px;
  color: #1f2937;
  background: white;
  transition: all 0.2s ease;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.form-input::placeholder {
  color: #9ca3af;
}

.form-input:focus {
  outline: none;
  border-color: #ec4899;
  background: #fdf2f8;
  box-shadow: 0 0 0 3px rgba(236, 72, 153, 0.1);
}

.form-input[type="date"]::-webkit-calendar-picker-indicator {
  cursor: pointer;
  filter: opacity(0.6);
}

.form-input[type="date"]::-webkit-calendar-picker-indicator:hover {
  filter: opacity(1);
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
  background: linear-gradient(135deg, #ec4899 0%, #d946ef 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(236, 72, 153, 0.3);
}

.btn-submit:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(236, 72, 153, 0.4);
}

.btn-close {
  background: linear-gradient(135deg, #64748b 0%, #475569 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(100, 116, 139, 0.3);
}

.btn-close:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(100, 116, 139, 0.4);
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
@media (max-width: 640px) {
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

  .medicine-icon {
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

  .form-actions {
    flex-direction: column;
  }

  .btn-submit,
  .btn-close {
    width: 100%;
  }
}
</style>
