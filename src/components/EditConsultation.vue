<template>
  <transition name="modal-fade">
    <div v-if="show" class="modal-overlay" @click="handleOverlayClick">
      <div class="modal-container" @click.stop>
        <div class="modal-header">
          <div class="header-icon">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </div>
          <h2 class="modal-title">Edit Consultation</h2>
          <button @click="$emit('close')" class="close-btn">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M18 6L6 18M6 6l12 12" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            </svg>
          </button>
        </div>

        <div class="modal-body">
          <form @submit.prevent="handleSubmit" class="edit-form">
            <!-- Patient Name (Read-only) -->
            <div class="form-group">
              <label class="field-label">
                <span class="label-icon">👤</span>
                Patient Name
              </label>
              <input 
                :value="editData.patient_name"
                type="text" 
                class="form-input"
                disabled
              />
            </div>

            <!-- Diagnosis -->
            <div class="form-group">
              <label class="field-label">
                <span class="label-icon">📋</span>
                Diagnosis <span class="required">*</span>
              </label>
              <textarea 
                v-model="editData.diagnosis"
                placeholder="Enter diagnosis..."
                rows="3"
                required
                class="form-textarea"
              ></textarea>
            </div>

            <!-- Prescription -->
            <div class="form-group">
              <label class="field-label">
                <span class="label-icon">💊</span>
                Prescription
              </label>
              <input 
                v-model="editData.prescription"
                type="text" 
                placeholder="Enter prescribed medicine..."
                class="form-input"
              />
            </div>

            <!-- Quantity -->
            <div class="form-group">
              <label class="field-label">
                <span class="label-icon">🔢</span>
                Quantity
              </label>
              <input 
                v-model.number="editData.quantity"
                type="number" 
                placeholder="0"
                min="0"
                class="form-input"
              />
            </div>

            <!-- Notes -->
            <div class="form-group">
              <label class="field-label">
                <span class="label-icon">📝</span>
                Notes
              </label>
              <textarea 
                v-model="editData.notes"
                placeholder="Enter notes..."
                rows="3"
                class="form-textarea"
              ></textarea>
            </div>

            <!-- Remarks -->
            <div class="form-group">
              <label class="field-label">
                <span class="label-icon">⚠️</span>
                Remarks
              </label>
              <textarea 
                v-model="editData.remarks"
                placeholder="Enter remarks..."
                rows="3"
                class="form-textarea"
              ></textarea>
            </div>

            <!-- Consultation Date -->
            <div class="form-group">
              <label class="field-label">
                <span class="label-icon">📅</span>
                Consultation Date
              </label>
              <input 
                v-model="editData.consultation_date"
                type="date" 
                class="form-input"
              />
            </div>

            <div class="form-actions">
              <button type="button" @click="$emit('close')" class="btn-cancel">
                Cancel
              </button>
              <button type="submit" class="btn-save" :disabled="isSaving">
                <svg v-if="!isSaving" width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M19 21H5a2 2 0 01-2-2V5a2 2 0 012-2h11l5 5v11a2 2 0 01-2 2z" stroke="currentColor" stroke-width="2"/>
                  <polyline points="17 21 17 13 7 13 7 21" stroke="currentColor" stroke-width="2"/>
                  <polyline points="7 3 7 8 15 8" stroke="currentColor" stroke-width="2"/>
                </svg>
                <div v-else class="btn-spinner"></div>
                {{ isSaving ? 'Saving...' : 'Save Changes' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
import { supabase } from '@/lib/Supabase.js'

export default {
  name: 'EditConsultation',
  props: {
    show: {
      type: Boolean,
      default: false
    },
    consultation: {
      type: Object,
      default: null
    }
  },
  data() {
    return {
      editData: {
        patient_name: '',
        diagnosis: '',
        prescription: '',
        quantity: null,
        notes: '',
        remarks: '',
        consultation_date: ''
      },
      isSaving: false
    }
  },
  watch: {
    consultation: {
      immediate: true,
      handler(newVal) {
        if (newVal) {
          this.editData = {
            patient_name: newVal.patient_name || '',
            diagnosis: newVal.diagnosis || '',
            prescription: newVal.prescription || '',
            quantity: newVal.quantity || null,
            notes: newVal.notes || '',
            remarks: newVal.treatment || newVal.remarks || '',
            consultation_date: this.formatDateForInput(newVal.consultation_date)
          }
        }
      }
    }
  },
  methods: {
    formatDateForInput(dateString) {
      if (!dateString) return ''
      const date = new Date(dateString)
      return date.toISOString().split('T')[0]
    },
    
    handleOverlayClick(event) {
      if (event.target.classList.contains('modal-overlay')) {
        this.$emit('close')
      }
    },
    
    async handleSubmit() {
      try {
        this.isSaving = true
        
        const updateData = {
          diagnosis: this.editData.diagnosis,
          prescription: this.editData.prescription || null,
          quantity: this.editData.quantity || null,
          notes: this.editData.notes || null,
          treatment: this.editData.remarks || null,
          consultation_date: this.editData.consultation_date || new Date().toISOString()
        }
        
        const { error } = await supabase
          .from('consultations')
          .update(updateData)
          .eq('id', this.consultation.id)
        
        if (error) throw error
        
        this.$emit('updated', {
          ...this.consultation,
          ...updateData,
          remarks: this.editData.remarks
        })
        this.$emit('close')
        
      } catch (err) {
        console.error('Error updating consultation:', err)
        alert('Failed to update consultation: ' + err.message)
      } finally {
        this.isSaving = false
      }
    }
  }
}
</script>

<style scoped>
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.3s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}

.modal-fade-enter-active .modal-container,
.modal-fade-leave-active .modal-container {
  transition: transform 0.3s ease;
}

.modal-fade-enter-from .modal-container,
.modal-fade-leave-to .modal-container {
  transform: scale(0.95);
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

.modal-container {
  background: white;
  border-radius: 20px;
  box-shadow: 0 25px 50px rgba(0, 0, 0, 0.25);
  width: 100%;
  max-width: 700px;
  max-height: 90vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.modal-header {
  background: linear-gradient(135deg, #ec4899 0%, #d946ef 100%);
  padding: 24px 32px;
  display: flex;
  align-items: center;
  gap: 16px;
  border-bottom: 3px solid rgba(255, 255, 255, 0.2);
}

.header-icon {
  width: 48px;
  height: 48px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
}

.modal-title {
  font-size: 24px;
  font-weight: 700;
  color: white;
  margin: 0;
  flex: 1;
  letter-spacing: -0.5px;
}

.close-btn {
  width: 40px;
  height: 40px;
  background: rgba(255, 255, 255, 0.2);
  border: none;
  border-radius: 10px;
  color: white;
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

.modal-body {
  padding: 32px;
  overflow-y: auto;
  flex: 1;
}

.edit-form {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.field-label {
  font-size: 13px;
  font-weight: 700;
  color: #1e293b;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.label-icon {
  font-size: 16px;
}

.required {
  color: #ef4444;
  font-size: 14px;
}

.form-input,
.form-textarea {
  width: 100%;
  padding: 14px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 10px;
  font-size: 14px;
  font-family: inherit;
  transition: all 0.3s ease;
  background: white;
  color: #1e293b;
}

.form-input:disabled {
  background: #f1f5f9;
  color: #64748b;
  cursor: not-allowed;
}

.form-textarea {
  resize: vertical;
  min-height: 80px;
  line-height: 1.6;
}

.form-input:focus,
.form-textarea:focus {
  outline: none;
  border-color: #ec4899;
  box-shadow: 0 0 0 4px rgba(236, 72, 153, 0.1);
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding-top: 16px;
  border-top: 2px solid #f1f5f9;
  margin-top: 8px;
}

.btn-cancel,
.btn-save {
  padding: 14px 32px;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s ease;
  border: none;
  display: flex;
  align-items: center;
  gap: 8px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.btn-cancel {
  background: #64748b;
  color: white;
  box-shadow: 0 4px 14px rgba(100, 116, 139, 0.3);
}

.btn-cancel:hover {
  background: #475569;
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(100, 116, 139, 0.4);
}

.btn-save {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  box-shadow: 0 4px 14px rgba(16, 185, 129, 0.4);
}

.btn-save:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(16, 185, 129, 0.5);
}

.btn-save:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.btn-spinner {
  width: 14px;
  height: 14px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

@media (max-width: 768px) {
  .modal-container {
    max-width: 100%;
    max-height: 100vh;
    border-radius: 0;
  }

  .modal-header {
    padding: 20px 24px;
  }

  .modal-body {
    padding: 24px;
  }

  .form-actions {
    flex-direction: column-reverse;
  }

  .btn-cancel,
  .btn-save {
    width: 100%;
    justify-content: center;
  }
}
</style>