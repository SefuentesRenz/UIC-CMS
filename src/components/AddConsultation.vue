<template>
  <transition name="modal-fade">
    <div v-if="show" class="modal-overlay" @click.self="closeModal">
      <div class="modal-container">
        <!-- Modal Header -->
        <div class="modal-header">
          <div class="header-content">
            <h2 class="modal-title">Add Consultation</h2>
            <p class="modal-subtitle">Create New User For The System. Make Sure To Fill All Of Them.</p>
          </div>
          <button class="close-btn" @click="closeModal" aria-label="Close modal">
            ✕
          </button>
        </div>

        <!-- Modal Body -->
        <div class="modal-body">
          <form @submit.prevent="handleSubmit">
            <!-- Search By Name Or ID -->
            <div class="form-group full-width">
              <label for="patient-search">
                Search By Name Or ID <span class="required">*</span>
              </label>
              <div class="search-dropdown">
                <input 
                  type="text" 
                  id="patient-search" 
                  v-model="searchQuery"
                  @input="filterPatients"
                  @focus="showDropdown = true"
                  placeholder="Search"
                  required
                  autocomplete="off"
                />
                <span class="dropdown-icon">▼</span>
                
                <!-- Dropdown Results -->
                <div v-if="showDropdown && filteredPatients.length > 0" class="dropdown-results">
                  <div 
                    v-for="patient in filteredPatients" 
                    :key="patient.id"
                    class="dropdown-item"
                    @click="selectPatient(patient)"
                  >
                    <div class="patient-info">
                      <span class="patient-name">{{ patient.name }}</span>
                      <span class="patient-id">ID: {{ patient.id }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Diagnosis -->
            <div class="form-group full-width">
              <label for="diagnosis">
                Diagnosis <span class="required">*</span>
              </label>
              <textarea 
                id="diagnosis" 
                v-model="formData.diagnosis" 
                placeholder="Type The Diagnosis"
                rows="3"
                required
              ></textarea>
            </div>

            <!-- Medicine and Quantity -->
            <div class="form-row">
              <div class="form-group">
                <label for="medicine">
                  Medicine <span class="required">*</span>
                </label>
                <select 
                  id="medicine" 
                  v-model="formData.medicine"
                  required
                >
                  <option value="" disabled>Search Medicine</option>
                  <option value="Paracetamol">Paracetamol</option>
                  <option value="Ibuprofen">Ibuprofen</option>
                  <option value="Loperamide">Loperamide</option>
                  <option value="Cetirizine">Cetirizine</option>
                  <option value="Mefenamic Acid">Mefenamic Acid</option>
                  <option value="Amoxicillin">Amoxicillin</option>
                  <option value="Biogesic">Biogesic</option>
                  <option value="Neozep">Neozep</option>
                </select>
              </div>
              <div class="form-group">
                <label for="quantity">
                  Quantity <span class="required">*</span>
                </label>
                <input 
                  type="number" 
                  id="quantity" 
                  v-model.number="formData.quantity" 
                  placeholder="Type Quantity"
                  min="1"
                  required
                />
              </div>
            </div>

            <!-- Notes -->
            <div class="form-group full-width">
              <label for="notes">
                Notes <span class="required">*</span>
              </label>
              <textarea 
                id="notes" 
                v-model="formData.notes" 
                placeholder="Type Note"
                rows="3"
                required
              ></textarea>
            </div>

            <!-- Date -->
            <div class="form-group half-width">
              <label for="date">
                Date <span class="required">*</span>
              </label>
              <input 
                type="date" 
                id="date" 
                v-model="formData.date"
                required
              />
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
  name: 'AddConsultation',
  props: {
    show: {
      type: Boolean,
      required: true
    }
  },
  data() {
    return {
      searchQuery: '',
      showDropdown: false,
      selectedPatient: null,
      formData: {
        patientName: '',
        patientId: '',
        diagnosis: '',
        medicine: '',
        quantity: '',
        notes: '',
        date: this.getCurrentDate()
      },
      // Sample patient data - in real app, this would come from API
      patients: [
        { id: '2021-001', name: 'RENZ ANGELO SEFUENTES' },
        { id: '2021-002', name: 'MARY JANE SANTOS' },
        { id: '2021-003', name: 'ESTOY BAN' },
        { id: '2021-004', name: 'MARIA THERESA PABLO' },
        { id: '2021-005', name: 'LEBRON JAMES' },
        { id: '2021-006', name: 'JOHN DELA CRUZ' },
        { id: '2021-007', name: 'ANNA MARIE LOPEZ' }
      ],
      filteredPatients: []
    }
  },
  watch: {
    show(newVal) {
      if (newVal) {
        // Add click listener when modal opens
        this.$nextTick(() => {
          document.addEventListener('click', this.handleClickOutside)
        })
      } else {
        // Remove click listener when modal closes
        document.removeEventListener('click', this.handleClickOutside)
      }
    }
  },
  beforeUnmount() {
    document.removeEventListener('click', this.handleClickOutside)
  },
  methods: {
    getCurrentDate() {
      const today = new Date()
      const year = today.getFullYear()
      const month = String(today.getMonth() + 1).padStart(2, '0')
      const day = String(today.getDate()).padStart(2, '0')
      return `${year}-${month}-${day}`
    },
    filterPatients() {
      if (this.searchQuery.trim() === '') {
        this.filteredPatients = this.patients
      } else {
        const query = this.searchQuery.toLowerCase()
        this.filteredPatients = this.patients.filter(patient =>
          patient.name.toLowerCase().includes(query) ||
          patient.id.toLowerCase().includes(query)
        )
      }
      this.showDropdown = true
    },
    selectPatient(patient) {
      this.selectedPatient = patient
      this.searchQuery = patient.name
      this.formData.patientName = patient.name
      this.formData.patientId = patient.id
      this.showDropdown = false
    },
    handleClickOutside(event) {
      // Check if click is outside the search dropdown
      const searchDropdown = event.target.closest('.search-dropdown')
      if (!searchDropdown) {
        this.showDropdown = false
      }
    },
    closeModal() {
      this.resetForm()
      this.$emit('close')
    },
    handleSubmit() {
      // Validate required fields
      if (!this.selectedPatient) {
        alert('Please select a patient from the dropdown')
        return
      }

      if (!this.formData.diagnosis || !this.formData.medicine || 
          !this.formData.quantity || !this.formData.notes || !this.formData.date) {
        alert('Please fill in all required fields')
        return
      }

      // Validate quantity
      if (this.formData.quantity < 1) {
        alert('Quantity must be at least 1')
        return
      }

      // Create consultation object
      const newConsultation = {
        name: this.formData.patientName,
        patientId: this.formData.patientId,
        diagnosis: this.formData.diagnosis,
        prescribedMedicine: this.formData.medicine,
        quantity: this.formData.quantity,
        notes: this.formData.notes,
        date: this.formData.date
      }

      this.$emit('add-consultation', newConsultation)
      this.closeModal()
    },
    resetForm() {
      this.searchQuery = ''
      this.selectedPatient = null
      this.showDropdown = false
      this.filteredPatients = []
      this.formData = {
        patientName: '',
        patientId: '',
        diagnosis: '',
        medicine: '',
        quantity: '',
        notes: '',
        date: this.getCurrentDate()
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
  max-width: 650px;
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
  background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
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
  color: rgba(255, 255, 255, 0.85);
  margin: 0;
  line-height: 1.5;
}

.close-btn {
  background: rgba(255, 255, 255, 0.15);
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
  background: rgba(255, 255, 255, 0.25);
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

.form-group.half-width {
  max-width: 48%;
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
.form-group select,
.form-group textarea {
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
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #1e293b;
  background: white;
  box-shadow: 0 0 0 3px rgba(30, 41, 59, 0.1);
}

.form-group input::placeholder,
.form-group textarea::placeholder {
  color: #9ca3af;
  font-size: 13px;
}

.form-group textarea {
  resize: vertical;
  min-height: 80px;
}

.form-group select {
  cursor: pointer;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%236b7280' d='M6 9L1 4h10z'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 12px center;
  padding-right: 36px;
}

/* Search Dropdown */
.search-dropdown {
  position: relative;
}

.search-dropdown input {
  padding-right: 36px;
}

.dropdown-icon {
  position: absolute;
  right: 14px;
  top: 50%;
  transform: translateY(-50%);
  color: #6b7280;
  font-size: 12px;
  pointer-events: none;
}

.dropdown-results {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: white;
  border: 2px solid #e5e7eb;
  border-top: none;
  border-radius: 0 0 10px 10px;
  max-height: 200px;
  overflow-y: auto;
  z-index: 1000;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.dropdown-item {
  padding: 12px 14px;
  cursor: pointer;
  transition: background 0.2s ease;
  border-bottom: 1px solid #f3f4f6;
}

.dropdown-item:last-child {
  border-bottom: none;
}

.dropdown-item:hover {
  background: #f9fafb;
}

.patient-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.patient-name {
  font-size: 14px;
  font-weight: 500;
  color: #1f2937;
}

.patient-id {
  font-size: 12px;
  color: #6b7280;
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

  .form-group.half-width {
    max-width: 100%;
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
