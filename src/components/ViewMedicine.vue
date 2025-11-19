<template>
  <div v-if="show" class="modal-overlay" @click.self="closeModal">
    <div class="modal-container">
      <div class="modal-header">
        <div class="header-content">
          <div class="medicine-icon">
            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <rect x="9" y="2" width="6" height="20" rx="1" fill="currentColor"/>
              <rect x="2" y="9" width="20" height="6" rx="1" fill="currentColor"/>
            </svg>
          </div>
          <div>
            <h2 class="modal-title">{{ isEditMode ? 'Edit Medicine Details' : 'Medicine Details' }}</h2>
            <p class="modal-subtitle">{{ isEditMode ? 'Update medicine information' : 'View medicine information' }}</p>
          </div>
        </div>
        <button class="close-btn" @click="closeModal" title="Close">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M18 6L6 18M6 6L18 18" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          </svg>
        </button>
      </div>

      <div class="modal-body">
        <!-- Loading/Empty State -->
        <div v-if="!medicine || Object.keys(medicine).length === 0" class="empty-state">
          <svg width="64" height="64" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <circle cx="12" cy="12" r="10" stroke="#cbd5e1" stroke-width="2"/>
            <path d="M12 8V12L15 15" stroke="#cbd5e1" stroke-width="2" stroke-linecap="round"/>
          </svg>
          <p>Loading medicine data...</p>
        </div>

        <!-- Medicine Data -->
        <template v-else>
          <!-- Medicine Details Grid -->
          <div class="details-grid">
            <!-- Basic Information Section -->
            <div class="section-card">
              <div class="section-header">
                <div class="section-icon medicine-info">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <rect x="9" y="2" width="6" height="20" rx="1" fill="currentColor"/>
                    <rect x="2" y="9" width="20" height="6" rx="1" fill="currentColor"/>
                  </svg>
                </div>
                <h3 class="section-title">Medicine Information</h3>
              </div>
              <div class="info-rows">
                <div class="info-row">
                  <span class="info-label">Medicine Name <span v-if="isEditMode" class="required">*</span></span>
                  <span v-if="!isEditMode" class="info-value">{{ medicine.name }}</span>
                  <input v-else type="text" v-model="editedMedicine.name" class="edit-input" required />
                </div>
                <div class="info-row">
                  <span class="info-label">Quantity <span v-if="isEditMode" class="required">*</span></span>
                  <span v-if="!isEditMode" class="info-value">{{ medicine.quantity }}</span>
                  <input v-else type="number" v-model.number="editedMedicine.quantity" class="edit-input" min="0" required />
                </div>
              </div>
            </div>

            <!-- Date Information Section -->
            <div class="section-card">
              <div class="section-header">
                <div class="section-icon date-info">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <rect x="3" y="4" width="18" height="18" rx="2" stroke="currentColor" stroke-width="2" fill="none"/>
                    <path d="M16 2V6M8 2V6M3 10H21" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                  </svg>
                </div>
                <h3 class="section-title">Date Information</h3>
              </div>
              <div class="info-rows">
                <div class="info-row">
                  <span class="info-label">Date Added <span v-if="isEditMode" class="required">*</span></span>
                  <span v-if="!isEditMode" class="info-value">{{ formatDate(medicine.dateAdded) }}</span>
                  <input v-else type="date" v-model="editedMedicine.dateAdded" class="edit-input" required />
                </div>
                <div class="info-row">
                  <span class="info-label">Expiration Date <span v-if="isEditMode" class="required">*</span></span>
                  <span v-if="!isEditMode" class="info-value">{{ formatDate(medicine.expirationDate) }}</span>
                  <input v-else type="date" v-model="editedMedicine.expirationDate" class="edit-input" required />
                </div>
              </div>
            </div>

            <!-- Status Information Section -->
            <div class="section-card full-width">
              <div class="section-header">
                <div class="section-icon status-info">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                    <polyline points="22 4 12 14.01 9 11.01" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                </div>
                <h3 class="section-title">Status</h3>
              </div>
              <div class="info-rows">
                <div class="info-row">
                  <span class="info-label">Current Status</span>
                  <span v-if="!isEditMode" :class="['status-badge-large', medicine.status?.toLowerCase()]">
                    {{ medicine.status }}
                  </span>
                  <select v-else v-model="editedMedicine.status" class="edit-select">
                    <option value="Active">Active</option>
                    <option value="Low Stock">Low Stock</option>
                    <option value="Expired">Expired</option>
                  </select>
                </div>
              </div>
            </div>
          </div>

          <!-- Action Buttons -->
          <div class="modal-actions" v-if="medicine && Object.keys(medicine).length > 0">
            <template v-if="!isEditMode">
              <button type="button" class="btn-edit" @click="editMedicine">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M11 4H4C3.46957 4 2.96086 4.21071 2.58579 4.58579C2.21071 4.96086 2 5.46957 2 6V20C2 20.5304 2.21071 21.0391 2.58579 21.4142C2.96086 21.7893 3.46957 22 4 22H18C18.5304 22 19.0391 21.7893 19.4142 21.4142C19.7893 21.0391 20 20.5304 20 20V13" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                  <path d="M18.5 2.50023C18.8978 2.1024 19.4374 1.87891 20 1.87891C20.5626 1.87891 21.1022 2.1024 21.5 2.50023C21.8978 2.89805 22.1213 3.43762 22.1213 4.00023C22.1213 4.56284 21.8978 5.1024 21.5 5.50023L12 15.0002L8 16.0002L9 12.0002L18.5 2.50023Z" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                </svg>
                Edit Medicine
              </button>
              <button type="button" class="btn-close" @click="closeModal">
                Close
              </button>
            </template>
            <template v-else>
              <button type="button" class="btn-save" @click="saveMedicine">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M20 6L9 17L4 12" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                Save Changes
              </button>
              <button type="button" class="btn-cancel" @click="cancelEdit">
                Cancel
              </button>
            </template>
          </div>
        </template>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ViewMedicineModal',
  props: {
    show: {
      type: Boolean,
      default: false
    },
    medicine: {
      type: Object,
      default: null
    }
  },
  data() {
    return {
      isEditMode: false,
      editedMedicine: {}
    }
  },
  watch: {
    medicine: {
      immediate: true,
      deep: true,
      handler(newMedicine) {
        if (newMedicine && Object.keys(newMedicine).length > 0) {
          this.editedMedicine = { ...newMedicine }
        }
      }
    },
    show(newVal) {
      if (!newVal) {
        this.isEditMode = false
      } else if (newVal && this.medicine) {
        // Ensure editedMedicine is synced when modal opens
        this.editedMedicine = { ...this.medicine }
      }
    }
  },
  methods: {
    closeModal() {
      this.isEditMode = false
      this.$emit('close')
    },
    editMedicine() {
      this.isEditMode = true
    },
    cancelEdit() {
      this.isEditMode = false
      this.editedMedicine = { ...this.medicine }
    },
    async saveMedicine() {
      console.log('=== SAVE MEDICINE CLICKED ===')
      console.log('editedMedicine data:', JSON.stringify(this.editedMedicine, null, 2))
      
      if (!this.validateForm()) {
        console.log('❌ Validation failed')
        return
      }
      
      console.log('✅ Validation passed')
      console.log('🚀 Emitting update-medicine event with data:', this.editedMedicine)
      
      this.$emit('update-medicine', this.editedMedicine)
    },
    validateForm() {
      const { name, quantity, dateAdded, expirationDate } = this.editedMedicine
      
      console.log('Validating form with data:', { name, quantity, dateAdded, expirationDate })
      
      if (!name || name.trim() === '') {
        this.$emit('validation-error', 'Medicine name is required')
        return false
      }
      
      if (quantity === null || quantity === undefined || quantity < 0) {
        this.$emit('validation-error', 'Quantity must be a positive number')
        return false
      }
      
      if (!dateAdded) {
        this.$emit('validation-error', 'Date added is required')
        return false
      }
      
      if (!expirationDate) {
        this.$emit('validation-error', 'Expiration date is required')
        return false
      }
      
      // Check if expiration date is after date added
      if (new Date(expirationDate) <= new Date(dateAdded)) {
        this.$emit('validation-error', 'Expiration date must be after date added')
        return false
      }
      
      console.log('Validation passed!')
      return true
    },
    formatDate(dateString) {
      if (!dateString) return 'N/A'
      const date = new Date(dateString)
      return date.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })
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
  max-width: 800px;
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
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  padding: 24px 30px;
  display: flex;
  justify-content: space-between;
  align-items: center;
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
}

.modal-title {
  font-size: 24px;
  font-weight: 700;
  margin: 0 0 4px 0;
}

.modal-subtitle {
  font-size: 14px;
  opacity: 0.9;
  margin: 0;
}

.close-btn {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  color: white;
  width: 40px;
  height: 40px;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.25);
  transform: rotate(90deg);
}

.modal-body {
  padding: 30px;
  overflow-y: auto;
  flex: 1;
}

/* Empty State */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  color: #94a3b8;
  text-align: center;
  min-height: 300px;
}

.empty-state svg {
  margin-bottom: 16px;
  opacity: 0.5;
  animation: pulse 2s infinite;
}

.empty-state p {
  font-size: 16px;
  margin: 0;
  font-weight: 500;
}

/* Details Grid */
.details-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
  gap: 20px;
  margin-bottom: 24px;
}

.section-card {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  padding: 20px;
  transition: all 0.3s ease;
}

.section-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
  border-color: #cbd5e1;
}

.section-card.full-width {
  grid-column: 1 / -1;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 2px solid #e2e8f0;
}

.section-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.section-icon.medicine-info {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
}

.section-icon.date-info {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
}

.section-icon.status-info {
  background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%);
}

.section-title {
  font-size: 16px;
  font-weight: 700;
  color: #1e293b;
  margin: 0;
}

.info-rows {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.info-row {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.info-label {
  font-size: 12px;
  font-weight: 600;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.info-value {
  font-size: 15px;
  color: #1e293b;
  font-weight: 500;
  padding: 8px 0;
}

.status-badge-large {
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 700;
  display: inline-flex;
  align-items: center;
  width: fit-content;
}

.status-badge-large.active {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
}

.status-badge-large.low.stock,
.status-badge-large.low {
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
  color: white;
}

.status-badge-large.expired {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
}

/* Modal Actions */
.modal-actions {
  display: flex;
  gap: 12px;
  padding-top: 20px;
  border-top: 2px solid #e2e8f0;
}

.btn-edit,
.btn-close,
.btn-save,
.btn-cancel {
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

.btn-edit {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

.btn-edit:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(16, 185, 129, 0.4);
}

.btn-close {
  background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
}

.btn-close:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(99, 102, 241, 0.4);
}

.btn-save {
  background: linear-gradient(135deg, #ec4899 0%, #d946ef 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(236, 72, 153, 0.3);
}

.btn-save:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(236, 72, 153, 0.4);
}

.btn-cancel {
  background: linear-gradient(135deg, #64748b 0%, #475569 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(100, 116, 139, 0.3);
}

.btn-cancel:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(100, 116, 139, 0.4);
}

/* Edit Mode Styles */
.edit-input,
.edit-select {
  width: 100%;
  padding: 10px 14px;
  border: 2px solid #cbd5e1;
  border-radius: 10px;
  font-size: 14px;
  color: #1f2937;
  background: white;
  transition: all 0.2s ease;
  font-family: inherit;
}

.edit-input:focus,
.edit-select:focus {
  outline: none;
  border-color: #10b981;
  box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
}

.edit-select {
  cursor: pointer;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%236b7280' d='M6 9L1 4h10z'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 12px center;
  padding-right: 36px;
}

.required {
  color: #ef4444;
  font-weight: 700;
}

/* Responsive Design */
@media (max-width: 768px) {
  .details-grid {
    grid-template-columns: 1fr;
  }

  .modal-actions {
    flex-direction: column;
  }

  .btn-edit,
  .btn-close,
  .btn-save,
  .btn-cancel {
    width: 100%;
  }
}
</style>
