<template>
  <transition name="modal-fade">
    <div v-if="show" class="modal-overlay" @click.self="closeModal">
      <div class="modal-container">
        <!-- Modal Header -->
        <div class="modal-header">
          <div class="header-content">
            <h2 class="modal-title">Add Patient</h2>
            <p class="modal-subtitle">Register new patient to the clinic management system</p>
          </div>
          <button class="close-btn" @click="closeModal" aria-label="Close modal">
            ✕
          </button>
        </div>

        <!-- Modal Body -->
        <div class="modal-body">
          <form @submit.prevent="handleSubmit">
            <!-- Full Name -->
            <div class="form-group full-width">
              <label for="fullName">
                Full Name <span class="required">*</span>
              </label>
              <input 
                type="text" 
                id="fullName" 
                v-model="formData.fullName" 
                placeholder="Enter full name"
                required
              />
            </div>

            <!-- College Dept and School ID -->
            <div class="form-row">
              <div class="form-group">
                <label for="collegeDept">
                  College Dept. <span class="required">*</span>
                </label>
                <input 
                  type="text" 
                  id="collegeDept" 
                  v-model="formData.collegeDept" 
                  placeholder="Enter college department"
                  required
                />
              </div>
              <div class="form-group">
                <label for="schoolId">
                  School ID <span class="required">*</span>
                </label>
                <input 
                  type="text" 
                  id="schoolId" 
                  v-model="formData.schoolId" 
                  placeholder="Enter school ID"
                  required
                />
              </div>
            </div>

            <!-- Program and Year Section -->
            <div class="form-row">
              <div class="form-group">
                <label for="program">
                  Program <span class="required">*</span>
                </label>
                <input 
                  type="text" 
                  id="program" 
                  v-model="formData.program" 
                  placeholder="Enter program"
                  required
                />
              </div>
              <div class="form-group">
                <label for="yearSection">
                  Year and Section <span class="required">*</span>
                </label>
                <input 
                  type="text" 
                  id="yearSection" 
                  v-model="formData.yearSection" 
                  placeholder="Enter year and section"
                  required
                />
              </div>
            </div>

            <!-- Email and Contact Number -->
            <div class="form-row">
              <div class="form-group">
                <label for="email">
                  Email Address <span class="required">*</span>
                </label>
                <input 
                  type="email" 
                  id="email" 
                  v-model="formData.email" 
                  placeholder="Enter email address"
                  required
                />
              </div>
              <div class="form-group">
                <label for="contactNumber">
                  Contact Number <span class="required">*</span>
                </label>
                <input 
                  type="tel" 
                  id="contactNumber" 
                  v-model="formData.contactNumber" 
                  placeholder="Enter contact number"
                  required
                />
              </div>
            </div>

            <!-- Sex and Type -->
            <div class="form-row">
              <div class="form-group">
                <label for="sex">
                  Sex <span class="required">*</span>
                </label>
                <select 
                  id="sex" 
                  v-model="formData.sex"
                  required
                >
                  <option value="" disabled>Select sex</option>
                  <option value="Male">Male</option>
                  <option value="Female">Female</option>
                </select>
              </div>
              <div class="form-group">
                <label for="type">
                  Type <span class="required">*</span>
                </label>
                <select 
                  id="type" 
                  v-model="formData.type"
                  required
                >
                  <option value="" disabled>Select type</option>
                  <option value="Student">Student</option>
                  <option value="Faculty">Faculty</option>
                  <option value="Staff">Staff</option>
                </select>
              </div>
            </div>

            <!-- Action Buttons -->
            <div class="modal-footer">
              <button type="submit" class="btn-submit">Submit</button>
              <button type="button" class="btn-back" @click="closeModal">Back</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
export default {
  name: 'AddPatientModal',
  props: {
    show: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      formData: {
        fullName: '',
        collegeDept: '',
        schoolId: '',
        program: '',
        yearSection: '',
        email: '',
        contactNumber: '',
        sex: '',
        type: ''
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
        // Emit the new patient data to parent component
        this.$emit('add-patient', {
          ...this.formData,
          id: Date.now(), // Generate unique ID
          idNumber: this.formData.schoolId,
          status: 'Active' // Default status
        })
        
        // Show success message
        alert('Patient added successfully!')
        
        // Reset form and close modal
        this.closeModal()
      }
    },
    validateForm() {
      const requiredFields = ['fullName', 'collegeDept', 'schoolId', 'program', 'yearSection', 'email', 'contactNumber', 'sex', 'type']
      
      for (let field of requiredFields) {
        if (!this.formData[field] || this.formData[field].trim() === '') {
          alert(`Please fill in all required fields`)
          return false
        }
      }
      
      // Validate email format
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      if (!emailRegex.test(this.formData.email)) {
        alert('Please enter a valid email address')
        return false
      }
      
      return true
    },
    resetForm() {
      this.formData = {
        fullName: '',
        collegeDept: '',
        schoolId: '',
        program: '',
        yearSection: '',
        email: '',
        contactNumber: '',
        sex: '',
        type: ''
      }
    }
  }
}
</script>

<style scoped>
/* Modal Overlay */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
  padding: 20px;
}

/* Modal Container */
.modal-container {
  background: white;
  border-radius: 16px;
  width: 100%;
  max-width: 700px;
  max-height: 90vh;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  display: flex;
  flex-direction: column;
  animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Modal Header */
.modal-header {
  background: linear-gradient(135deg, #ec4899 0%, #d946ef 100%);
  padding: 24px 28px;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 20px;
}

.header-content {
  flex: 1;
}

.modal-title {
  font-size: 24px;
  font-weight: 700;
  color: white;
  margin: 0 0 6px 0;
  letter-spacing: -0.3px;
}

.modal-subtitle {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.9);
  margin: 0;
  line-height: 1.5;
}

.close-btn {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  color: white;
  font-size: 24px;
  width: 36px;
  height: 36px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: rotate(90deg);
}

/* Modal Body */
.modal-body {
  padding: 28px;
  overflow-y: auto;
  flex: 1;
}

/* Form Styles */
form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
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
  font-size: 13px;
  font-weight: 600;
  color: #374151;
  text-transform: uppercase;
  letter-spacing: 0.3px;
}

.required {
  color: #ef4444;
  font-weight: 700;
}

.form-group input,
.form-group select {
  padding: 12px 14px;
  border: 2px solid #e5e7eb;
  border-radius: 10px;
  font-size: 14px;
  color: #1f2937;
  background: #f9fafb;
  transition: all 0.2s ease;
  font-family: inherit;
}

.form-group input:focus,
.form-group select:focus {
  outline: none;
  border-color: #ec4899;
  background: white;
  box-shadow: 0 0 0 3px rgba(236, 72, 153, 0.1);
}

.form-group input::placeholder {
  color: #9ca3af;
  font-size: 13px;
}

.form-group select {
  cursor: pointer;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%236b7280' d='M6 9L1 4h10z'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 12px center;
  padding-right: 36px;
}

/* Modal Footer */
.modal-footer {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  padding-top: 8px;
}

.btn-submit,
.btn-back {
  padding: 12px 32px;
  border: none;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
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

.btn-back {
  background: linear-gradient(135deg, #64748b 0%, #475569 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(100, 116, 139, 0.3);
}

.btn-back:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(100, 116, 139, 0.4);
}

/* Transitions */
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.3s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}

.modal-fade-enter-active .modal-container {
  animation: slideUp 0.3s ease-out;
}

.modal-fade-leave-active .modal-container {
  animation: slideUp 0.3s ease-out reverse;
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
  background: #cbd5e1;
  border-radius: 10px;
}

.modal-body::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}

/* Responsive Design */
@media (max-width: 768px) {
  .modal-container {
    max-width: 95%;
    max-height: 95vh;
  }

  .modal-header {
    padding: 20px;
  }

  .modal-title {
    font-size: 20px;
  }

  .modal-subtitle {
    font-size: 12px;
  }

  .modal-body {
    padding: 20px;
  }

  .form-row {
    grid-template-columns: 1fr;
    gap: 20px;
  }

  .modal-footer {
    flex-direction: column-reverse;
  }

  .btn-submit,
  .btn-back {
    width: 100%;
  }
}
</style>
