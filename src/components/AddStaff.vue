<template>
  <transition name="modal-fade">
    <div v-if="show" class="modal-overlay" @click.self="closeModal">
      <div class="modal-container">
        <!-- Modal Header -->
        <div class="modal-header">
          <div class="header-content">
            <h2 class="modal-title">New Staff User</h2>
            <p class="modal-subtitle">Create New User For The System. Make Sure To Fill All Of Them.</p>
          </div>
          <button class="close-btn" @click="closeModal" aria-label="Close modal">
            ✕
          </button>
        </div>

        <!-- Modal Body -->
        <div class="modal-body">
          <form @submit.prevent="handleSubmit">
            <!-- ID Field -->
            <div class="form-group full-width">
              <label for="staff-id">
                ID <span class="required">*</span>
              </label>
              <input 
                type="text" 
                id="staff-id" 
                v-model="formData.id" 
                placeholder="Fill ID"
                required
              />
            </div>

            <!-- Profile Upload -->
            <div class="form-group full-width">
              <label for="profile-upload">Profile Upload</label>
              <div class="file-upload-wrapper">
                <input 
                  type="file" 
                  id="profile-upload" 
                  ref="fileInput"
                  @change="handleFileChange"
                  accept="image/*"
                  hidden
                />
                <button 
                  type="button" 
                  class="file-upload-btn" 
                  @click="$refs.fileInput.click()"
                >
                  Choose File
                </button>
                <span class="file-name">{{ fileName || 'No File Chosen' }}</span>
              </div>
            </div>

            <!-- First Name and Last Name -->
            <div class="form-row">
              <div class="form-group">
                <label for="first-name">
                  First Name <span class="required">*</span>
                </label>
                <input 
                  type="text" 
                  id="first-name" 
                  v-model="formData.firstName" 
                  placeholder="Fill First Name"
                  required
                />
              </div>
              <div class="form-group">
                <label for="last-name">
                  Last Name <span class="required">*</span>
                </label>
                <input 
                  type="text" 
                  id="last-name" 
                  v-model="formData.lastName" 
                  placeholder="Fill Last Name"
                  required
                />
              </div>
            </div>

            <!-- Middle Name and Email -->
            <div class="form-row">
              <div class="form-group">
                <label for="middle-name">Middle Name</label>
                <input 
                  type="text" 
                  id="middle-name" 
                  v-model="formData.middleName" 
                  placeholder="Fill Middle Name"
                />
              </div>
              <div class="form-group">
                <label for="email">
                  EMAIL <span class="required">*</span>
                </label>
                <input 
                  type="email" 
                  id="email" 
                  v-model="formData.email" 
                  placeholder="Fill Email"
                  required
                />
              </div>
            </div>

            <!-- Position and System Role -->
            <div class="form-row">
              <div class="form-group">
                <label for="position">
                  Position <span class="required">*</span>
                </label>
                <input 
                  type="text" 
                  id="position" 
                  v-model="formData.position" 
                  placeholder="Fill Position"
                  required
                />
              </div>
              <div class="form-group">
                <label for="system-role">
                  SYSTEM ROLE <span class="required">*</span>
                </label>
                <select 
                  id="system-role" 
                  v-model="formData.systemRole"
                  required
                >
                  <option value="" disabled>Super Admin</option>
                  <option value="Super Admin">Super Admin</option>
                  <option value="Admin">Admin</option>
                  <option value="Nurse">Nurse</option>
                  <option value="Staff">Staff</option>
                </select>
              </div>
            </div>

            <!-- Status -->
            <div class="form-group full-width">
              <label for="status">
                Status <span class="required">*</span>
              </label>
              <select 
                id="status" 
                v-model="formData.status"
                required
              >
                <option value="Active">Active</option>
                <option value="Inactive">Inactive</option>
              </select>
            </div>

            <!-- Action Buttons -->
            <div class="modal-footer">
              <button type="submit" class="btn-add">Add</button>
              <button type="button" class="btn-close" @click="closeModal">Close</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
export default {
  name: 'AddStaff',
  props: {
    show: {
      type: Boolean,
      required: true
    }
  },
  data() {
    return {
      formData: {
        id: '',
        firstName: '',
        lastName: '',
        middleName: '',
        email: '',
        position: '',
        systemRole: '',
        status: 'Active'
      },
      fileName: '',
      profileFile: null
    }
  },
  methods: {
    closeModal() {
      this.resetForm()
      this.$emit('close')
    },
    handleFileChange(event) {
      const file = event.target.files[0]
      if (file) {
        this.profileFile = file
        this.fileName = file.name
      }
    },
    handleSubmit() {
      // Validate required fields
      if (!this.formData.id || !this.formData.firstName || !this.formData.lastName || 
          !this.formData.email || !this.formData.position || !this.formData.systemRole) {
        alert('Please fill in all required fields')
        return
      }

      // Validate email format
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      if (!emailRegex.test(this.formData.email)) {
        alert('Please enter a valid email address')
        return
      }

      // Create staff object
      const newStaff = {
        id: this.formData.id,
        name: `${this.formData.firstName} ${this.formData.middleName ? this.formData.middleName + ' ' : ''}${this.formData.lastName}`,
        firstName: this.formData.firstName,
        lastName: this.formData.lastName,
        middleName: this.formData.middleName,
        email: this.formData.email,
        position: this.formData.position,
        role: this.formData.systemRole,
        status: this.formData.status,
        profileFile: this.profileFile
      }

      this.$emit('add-staff', newStaff)
      this.closeModal()
    },
    resetForm() {
      this.formData = {
        id: '',
        firstName: '',
        lastName: '',
        middleName: '',
        email: '',
        position: '',
        systemRole: '',
        status: 'Active'
      }
      this.fileName = ''
      this.profileFile = null
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
  background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%);
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
  border-color: #8b5cf6;
  background: white;
  box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.1);
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

/* File Upload */
.file-upload-wrapper {
  display: flex;
  align-items: center;
  gap: 12px;
  background: #f9fafb;
  padding: 12px 14px;
  border: 2px solid #e5e7eb;
  border-radius: 10px;
  transition: all 0.2s ease;
}

.file-upload-wrapper:focus-within {
  border-color: #8b5cf6;
  background: white;
  box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.1);
}

.file-upload-btn {
  padding: 8px 16px;
  background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  white-space: nowrap;
}

.file-upload-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(139, 92, 246, 0.3);
}

.file-name {
  font-size: 13px;
  color: #6b7280;
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* Modal Footer */
.modal-footer {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  padding-top: 8px;
}

.btn-add,
.btn-close {
  padding: 12px 32px;
  border: none;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-add {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
}

.btn-add:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(239, 68, 68, 0.4);
}

.btn-close {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
}

.btn-close:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(59, 130, 246, 0.4);
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

  .btn-add,
  .btn-close {
    width: 100%;
  }
}
</style>
