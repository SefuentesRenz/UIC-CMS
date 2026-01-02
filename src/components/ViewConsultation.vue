<template>
  <div v-if="show" class="modal-overlay" @click.self="$emit('close')">
    <div class="modal-content view-consultation-modal">
      <div class="modal-header">
        <h2>Consultation Details</h2>
        <button @click="$emit('close')" class="close-btn">×</button>
      </div>

      <div class="modal-body" v-if="consultation">
        <div class="detail-section">
          <div class="detail-row">
            <div class="detail-item">
              <label>Patient Name:</label>
              <p>{{ consultation.patient_name || 'N/A' }}</p>
            </div>
            <div class="detail-item">
              <label>Date:</label>
              <p>{{ formatDate(consultation.consultation_date) }}</p>
            </div>
          </div>

          <div class="detail-row">
            <div class="detail-item full-width">
              <label>Chief Complaint:</label>
              <p>{{ consultation.chief_complaint || 'N/A' }}</p>
            </div>
          </div>

          <div class="detail-row">
            <div class="detail-item full-width">
              <label>Diagnosis:</label>
              <p>{{ consultation.diagnosis || 'N/A' }}</p>
            </div>
          </div>

          <div class="detail-row">
            <div class="detail-item full-width">
              <label>Prescribed Medicine:</label>
              <p>{{ consultation.prescription || 'N/A' }}</p>
            </div>
          </div>

          <div class="detail-row">
            <div class="detail-item">
              <label>Quantity:</label>
              <p>{{ consultation.quantity || 'N/A' }}</p>
            </div>
            <div class="detail-item">
              <label>Status:</label>
              <p :class="['status-badge', consultation.status?.toLowerCase()]">
                {{ consultation.status || 'N/A' }}
              </p>
            </div>
          </div>

          <div class="detail-row">
            <div class="detail-item full-width">
              <label>Treatment/Remark:</label>
              <p>{{ consultation.treatment || 'N/A' }}</p>
            </div>
          </div>

          <div class="detail-row">
            <div class="detail-item full-width">
              <label>Notes:</label>
              <p>{{ consultation.notes || 'N/A' }}</p>
            </div>
          </div>

          <div class="vital-signs-section" v-if="hasVitalSigns">
            <h3>Vital Signs</h3>
            <div class="detail-row">
              <div class="detail-item" v-if="consultation.temperature">
                <label>Temperature:</label>
                <p>{{ consultation.temperature }}°C</p>
              </div>
              <div class="detail-item" v-if="consultation.blood_pressure">
                <label>Blood Pressure:</label>
                <p>{{ consultation.blood_pressure }}</p>
              </div>
            </div>
            <div class="detail-row">
              <div class="detail-item" v-if="consultation.heart_rate">
                <label>Heart Rate:</label>
                <p>{{ consultation.heart_rate }} bpm</p>
              </div>
              <div class="detail-item" v-if="consultation.weight">
                <label>Weight:</label>
                <p>{{ consultation.weight }} kg</p>
              </div>
            </div>
          </div>

          <div class="detail-row" v-if="consultation.attended_by_name">
            <div class="detail-item full-width">
              <label>Attended By:</label>
              <p class="attended-by">{{ consultation.attended_by_name }}</p>
            </div>
          </div>
        </div>
      </div>

      <div class="modal-footer">
        <button @click="$emit('close')" class="btn-close">Close</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ViewConsultation',
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
  computed: {
    hasVitalSigns() {
      if (!this.consultation) return false
      return this.consultation.temperature || 
             this.consultation.blood_pressure || 
             this.consultation.heart_rate || 
             this.consultation.weight
    }
  },
  methods: {
    formatDate(dateString) {
      if (!dateString) return 'N/A'
      const date = new Date(dateString)
      return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
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
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

.modal-content {
  background: white;
  border-radius: 12px;
  max-width: 700px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px;
  border-bottom: 1px solid #e5e7eb;
}

.modal-header h2 {
  font-size: 22px;
  color: #1e293b;
  font-weight: 600;
}

.close-btn {
  background: none;
  border: none;
  font-size: 32px;
  color: #64748b;
  cursor: pointer;
  line-height: 1;
  padding: 0;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  transition: all 0.2s ease;
}

.close-btn:hover {
  background: #f1f5f9;
  color: #1e293b;
}

.modal-body {
  padding: 24px;
}

.detail-section {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.detail-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.detail-item {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.detail-item.full-width {
  grid-column: 1 / -1;
}

.detail-item label {
  font-size: 12px;
  font-weight: 700;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.detail-item p {
  font-size: 15px;
  color: #1e293b;
  line-height: 1.6;
  padding: 10px 12px;
  background: #f8fafc;
  border-radius: 6px;
  border: 1px solid #e2e8f0;
}

.status-badge {
  display: inline-block;
  padding: 6px 16px !important;
  border-radius: 20px;
  font-size: 13px !important;
  font-weight: 600;
  text-align: center;
  width: fit-content;
  border: none !important;
}

.status-badge.completed {
  background: #10b981 !important;
  color: white;
}

.status-badge.pending {
  background: #f59e0b !important;
  color: white;
}

.status-badge.cancelled {
  background: #ef4444 !important;
  color: white;
}

.vital-signs-section {
  margin-top: 8px;
  padding-top: 20px;
  border-top: 2px solid #e2e8f0;
}

.vital-signs-section h3 {
  font-size: 16px;
  color: #1e293b;
  margin-bottom: 16px;
  font-weight: 600;
}

.attended-by {
  font-style: italic;
  color: #64748b !important;
}

.modal-footer {
  padding: 16px 24px;
  border-top: 1px solid #e5e7eb;
  display: flex;
  justify-content: flex-end;
}

.btn-close {
  padding: 10px 24px;
  background: #64748b;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-close:hover {
  background: #475569;
}

@media (max-width: 768px) {
  .detail-row {
    grid-template-columns: 1fr;
  }

  .modal-content {
    margin: 10px;
    max-height: 95vh;
  }

  .modal-header,
  .modal-body,
  .modal-footer {
    padding: 16px;
  }
}
</style>
