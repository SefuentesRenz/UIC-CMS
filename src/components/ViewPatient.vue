<template>
  <div v-if="show" class="modal-overlay" @click.self="closeModal">
    <div class="modal-container">
      <div class="modal-header">
        <div class="header-content">
          <div class="patient-icon">
            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <circle cx="12" cy="8" r="4" fill="currentColor"/>
              <path d="M6 21C6 17.134 8.686 14 12 14C15.314 14 18 17.134 18 21" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            </svg>
          </div>
          <div>
            <h2 class="modal-title">{{ isEditMode ? 'Edit Patient Information' : 'Patient Information' }}</h2>
            <p class="modal-subtitle">{{ isEditMode ? 'Update patient record details' : 'Complete medical record details' }}</p>
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
        <div v-if="!patient || Object.keys(patient).length === 0" class="empty-state">
          <svg width="64" height="64" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <circle cx="12" cy="12" r="10" stroke="#cbd5e1" stroke-width="2"/>
            <path d="M12 8V12L15 15" stroke="#cbd5e1" stroke-width="2" stroke-linecap="round"/>
          </svg>
          <p>Loading patient data...</p>
        </div>

        <!-- Patient Data -->
        <template v-else>
          <!-- Status Badge -->
          <div class="status-section" v-if="patient.status">
            <span :class="['status-badge-large', patient.status?.toLowerCase()]">
              <span class="status-dot"></span>
              {{ patient.status }}
            </span>
          </div>

          <!-- Patient Details Grid -->
          <div class="details-grid">
          <!-- Personal Information Section -->
          <div class="section-card">
            <div class="section-header">
              <div class="section-icon personal">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <circle cx="12" cy="8" r="4" fill="currentColor"/>
                  <path d="M6 21C6 17.134 8.686 14 12 14C15.314 14 18 17.134 18 21" stroke="currentColor" stroke-width="2"/>
                </svg>
              </div>
              <h3 class="section-title">Personal Information</h3>
            </div>
            <div class="info-rows">
              <div class="info-row">
                <span class="info-label">Full Name <span v-if="isEditMode" class="required">*</span></span>
                <span v-if="!isEditMode" class="info-value">{{ patient.full_name || patient.fullName }}</span>
                <input v-else type="text" v-model="editedPatient.full_name" class="edit-input" required />
              </div>
              <div class="info-row">
                <span class="info-label">ID Number <span v-if="isEditMode" class="required">*</span></span>
                <span v-if="!isEditMode" class="info-value">{{ patient.school_id || patient.idNumber }}</span>
                <input v-else type="text" v-model="editedPatient.school_id" class="edit-input" required />
              </div>
              <div class="info-row">
                <span class="info-label">Sex <span v-if="isEditMode" class="required">*</span></span>
                <span v-if="!isEditMode" class="info-value">{{ patient.sex }}</span>
                <select v-else v-model="editedPatient.sex" class="edit-select" required>
                  <option value="Male">Male</option>
                  <option value="Female">Female</option>
                </select>
              </div>
              <div class="info-row">
                <span class="info-label">Type <span v-if="isEditMode" class="required">*</span></span>
                <span v-if="!isEditMode" class="info-value type-badge">{{ patient.type }}</span>
                <select v-else v-model="editedPatient.type" class="edit-select" required>
                  <option value="Student">Student</option>
                  <option value="Faculty">Faculty</option>
                  <option value="Staff">Staff</option>
                </select>
              </div>
            </div>
          </div>

          <!-- Contact Information Section -->
          <div class="section-card">
            <div class="section-header">
              <div class="section-icon contact">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <rect x="3" y="4" width="18" height="16" rx="2" stroke="currentColor" stroke-width="2" fill="none"/>
                  <path d="M3 7L12 13L21 7" stroke="currentColor" stroke-width="2"/>
                </svg>
              </div>
              <h3 class="section-title">Contact Information</h3>
            </div>
            <div class="info-rows">
              <div class="info-row">
                <span class="info-label">Email Address <span v-if="isEditMode" class="required">*</span></span>
                <span v-if="!isEditMode" class="info-value email">{{ patient.email }}</span>
                <input v-else type="email" v-model="editedPatient.email" class="edit-input" required />
              </div>
              <div class="info-row">
                <span class="info-label">Contact Number <span v-if="isEditMode" class="required">*</span></span>
                <span v-if="!isEditMode" class="info-value">{{ patient.contact_number || patient.contactNumber || 'N/A' }}</span>
                <input v-else type="tel" v-model="editedPatient.contact_number" class="edit-input" placeholder="09XXXXXXXXX" required />
              </div>
            </div>
          </div>

          <!-- Academic Information Section (if applicable) -->
          <div class="section-card" v-if="patient.type === 'Student' || editedPatient.type === 'Student'">
            <div class="section-header">
              <div class="section-icon academic">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M12 3L2 7L12 11L22 7L12 3Z" stroke="currentColor" stroke-width="2" fill="currentColor"/>
                  <path d="M6 10V16C6 17.1 8.686 20 12 20C15.314 20 18 17.1 18 16V10" stroke="currentColor" stroke-width="2"/>
                </svg>
              </div>
              <h3 class="section-title">Academic Information</h3>
            </div>
            <div class="info-rows">
              <div class="info-row">
                <span class="info-label">College/Department <span v-if="isEditMode" class="required">*</span></span>
                <span v-if="!isEditMode" class="info-value">{{ patient.college_department || patient.collegeDept || 'N/A' }}</span>
                <input v-else type="text" v-model="editedPatient.college_department" class="edit-input" required />
              </div>
              <div class="info-row">
                <span class="info-label">Program <span v-if="isEditMode" class="required">*</span></span>
                <span v-if="!isEditMode" class="info-value">{{ patient.program || 'N/A' }}</span>
                <input v-else type="text" v-model="editedPatient.program" class="edit-input" required />
              </div>
              <div class="info-row">
                <span class="info-label">Year & Section <span v-if="isEditMode" class="required">*</span></span>
                <span v-if="!isEditMode" class="info-value">{{ patient.year_section || patient.yearSection || 'N/A' }}</span>
                <input v-else type="text" v-model="editedPatient.year_section" class="edit-input" placeholder="e.g., 3-A" required />
              </div>
            </div>
          </div>

          <!-- Medical History Section (Placeholder) -->
          <div class="section-card full-width">
            <div class="section-header">
              <div class="section-icon medical">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M12 2L12 12M12 12L12 22M12 12L2 12M12 12L22 12" stroke="currentColor" stroke-width="3" stroke-linecap="round"/>
                </svg>
              </div>
              <h3 class="section-title">Medical History</h3>
            </div>
            <div class="info-rows">
              <div class="info-row">
                <span class="info-label">Last Visit</span>
                <span class="info-value">{{ patient.lastVisit || 'No previous visits' }}</span>
              </div>
              <div class="info-row">
                <span class="info-label">Blood Type</span>
                <span class="info-value">{{ patient.bloodType || 'Not specified' }}</span>
              </div>
              <div class="info-row">
                <span class="info-label">Allergies</span>
                <span class="info-value">{{ patient.allergies || 'None reported' }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="modal-actions" v-if="patient && Object.keys(patient).length > 0">
          <template v-if="!isEditMode">
            <button type="button" class="btn-edit" @click="editPatient">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M11 4H4C3.46957 4 2.96086 4.21071 2.58579 4.58579C2.21071 4.96086 2 5.46957 2 6V20C2 20.5304 2.21071 21.0391 2.58579 21.4142C2.96086 21.7893 3.46957 22 4 22H18C18.5304 22 19.0391 21.7893 19.4142 21.4142C19.7893 21.0391 20 20.5304 20 20V13" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                <path d="M18.5 2.50023C18.8978 2.1024 19.4374 1.87891 20 1.87891C20.5626 1.87891 21.1022 2.1024 21.5 2.50023C21.8978 2.89805 22.1213 3.43762 22.1213 4.00023C22.1213 4.56284 21.8978 5.1024 21.5 5.50023L12 15.0002L8 16.0002L9 12.0002L18.5 2.50023Z" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
              </svg>
              Edit Patient
            </button>
            <button type="button" class="btn-close" @click="closeModal">
              Close
            </button>
          </template>
          <template v-else>
            <button type="button" class="btn-save" @click="savePatient">
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
  name: 'ViewPatientModal',
  props: {
    show: {
      type: Boolean,
      default: false
    },
    patient: {
      type: Object,
      default: null
    }
  },
  data() {
    return {
      isEditMode: false,
      editedPatient: {}
    }
  },
  watch: {
    patient: {
      immediate: true,
      deep: true,
      handler(newPatient) {
        if (newPatient && Object.keys(newPatient).length > 0) {
          this.editedPatient = { ...newPatient }
        }
      }
    },
    show(newVal) {
      if (!newVal) {
        this.isEditMode = false
      } else if (newVal && this.patient) {
        // Ensure editedPatient is synced when modal opens
        this.editedPatient = { ...this.patient }
      }
    }
  },
  methods: {
    closeModal() {
      this.isEditMode = false
      this.$emit('close')
    },
    editPatient() {
      this.isEditMode = true
    },
    cancelEdit() {
      this.isEditMode = false
      this.editedPatient = { ...this.patient }
    },
    async savePatient() {
      console.log('=== SAVE PATIENT CLICKED ===')
      console.log('editedPatient data:', JSON.stringify(this.editedPatient, null, 2))
      
      if (!this.validateForm()) {
        console.log('❌ Validation failed')
        return
      }
      
      console.log('✅ Validation passed')
      console.log('🚀 Emitting update-patient event with data:', this.editedPatient)
      
      this.$emit('update-patient', this.editedPatient)
      
      // Keep edit mode open until parent confirms success
      // Parent will close modal after successful update
    },
    validateForm() {
      const { full_name, school_id, email, contact_number, college_department, program, year_section, sex, type } = this.editedPatient
      
      console.log('Validating form with data:', { full_name, school_id, email, contact_number, college_department, program, year_section, sex, type })
      
      if (!full_name || !school_id || !email) {
        console.log('Missing required field:', { full_name, school_id, email })
        this.$emit('validation-error', 'Please fill in all required fields (Name, ID, Email)')
        return false
      }
      
      // Check other required fields
      if (!college_department || !program || !year_section || !sex || !type) {
        console.log('Missing required field:', { college_department, program, year_section, sex, type })
        this.$emit('validation-error', 'Please fill in all required fields')
        return false
      }
      
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      if (!emailRegex.test(email)) {
        console.log('Invalid email format:', email)
        this.$emit('validation-error', 'Please enter a valid email address')
        return false
      }
      
      if (contact_number) {
        const phoneRegex = /^09\d{9}$/
        if (!phoneRegex.test(contact_number)) {
          console.log('Invalid phone format:', contact_number)
          this.$emit('validation-error', 'Please enter a valid Philippine mobile number (09XXXXXXXXX)')
          return false
        }
      }
      
      console.log('Validation passed!')
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
  max-width: 900px;
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
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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

.patient-icon {
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

.close-btn {
  background: rgba(255, 255, 255, 0.15);
  border: none;
  width: 36px;
  height: 36px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: white;
  transition: all 0.2s ease;
  backdrop-filter: blur(10px);
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

/* Status Section */
.status-section {
  display: flex;
  justify-content: flex-end;
  margin-bottom: 24px;
}

.status-badge-large {
  padding: 10px 24px;
  border-radius: 24px;
  font-size: 14px;
  font-weight: 700;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: currentColor;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

.status-badge-large.active {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

.status-badge-large.inactive {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
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

.section-icon.personal {
  background: linear-gradient(135deg, #ec4899 0%, #db2777 100%);
}

.section-icon.contact {
  background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%);
}

.section-icon.academic {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
}

.section-icon.medical {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
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
  gap: 12px;
}

.info-row {
  display: flex;
  flex-direction: column;
  gap: 4px;
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
  font-weight: 500;
  color: #1e293b;
  word-break: break-word;
}

.info-value.email {
  color: #6366f1;
  text-decoration: none;
}

.info-value.type-badge {
  display: inline-block;
  padding: 4px 12px;
  background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%);
  color: white;
  border-radius: 12px;
  font-size: 13px;
  font-weight: 600;
  width: fit-content;
}

/* Modal Actions */
.modal-actions {
  display: flex;
  gap: 12px;
  padding-top: 20px;
  border-top: 2px solid #e2e8f0;
}

.btn-edit,
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
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
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

/* Custom Scrollbar */
.modal-body::-webkit-scrollbar {
  width: 8px;
}

.modal-body::-webkit-scrollbar-track {
  background: #f1f5f9;
  border-radius: 10px;
}

.modal-body::-webkit-scrollbar-thumb {
  background: linear-gradient(180deg, #cbd5e1 0%, #94a3b8 100%);
  border-radius: 10px;
}

.modal-body::-webkit-scrollbar-thumb:hover {
  background: linear-gradient(180deg, #94a3b8 0%, #64748b 100%);
}

/* Responsive Design */
@media (max-width: 768px) {
  .modal-container {
    width: 95%;
    max-width: 100%;
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

  .modal-title {
    font-size: 20px;
  }

  .modal-body {
    padding: 20px;
  }

  .details-grid {
    grid-template-columns: 1fr;
    gap: 16px;
  }

  .modal-actions {
    flex-direction: column;
  }

  .btn-edit,
  .btn-close {
    width: 100%;
  }

  .status-section {
    justify-content: center;
  }
}

@media (max-width: 480px) {
  .modal-header {
    padding: 16px;
  }

  .patient-icon {
    width: 48px;
    height: 48px;
  }

  .modal-title {
    font-size: 18px;
  }

  .modal-subtitle {
    font-size: 12px;
  }

  .section-card {
    padding: 16px;
  }
}
</style>
    