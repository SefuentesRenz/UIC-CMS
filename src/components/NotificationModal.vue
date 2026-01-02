<template>
  <transition name="modal-fade">
    <div v-if="show" class="modal-overlay" @click.self="close">
      <div class="modal-container">
        <div class="modal-header" :class="typeClass">
          <span class="modal-icon">{{ icon }}</span>
          <h3 class="modal-title">{{ title }}</h3>
        </div>
        <div class="modal-body">
          <p>{{ message }}</p>
        </div>
        <div class="modal-footer">
          <button @click="close" class="btn-close">OK</button>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
export default {
  name: 'NotificationModal',
  props: {
    show: {
      type: Boolean,
      default: false
    },
    message: {
      type: String,
      default: ''
    },
    type: {
      type: String,
      default: 'info', // 'success', 'error', 'warning', 'info'
      validator: (value) => ['success', 'error', 'warning', 'info'].includes(value)
    }
  },
  computed: {
    typeClass() {
      return `modal-${this.type}`
    },
    icon() {
      const icons = {
        success: '✓',
        error: '✕',
        warning: '⚠',
        info: 'ℹ'
      }
      return icons[this.type]
    },
    title() {
      const titles = {
        success: 'Success',
        error: 'Error',
        warning: 'Warning',
        info: 'Information'
      }
      return titles[this.type]
    }
  },
  methods: {
    close() {
      this.$emit('close')
    }
  }
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
}

.modal-container {
  background: white;
  border-radius: 12px;
  width: 90%;
  max-width: 450px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
  overflow: hidden;
  animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
  from {
    transform: translateY(20px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.modal-header {
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 12px;
  border-bottom: 1px solid #e5e7eb;
}

.modal-success {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
}

.modal-error {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
}

.modal-warning {
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
  color: white;
}

.modal-info {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  color: white;
}

.modal-icon {
  font-size: 24px;
  font-weight: bold;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 50%;
}

.modal-title {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
}

.modal-body {
  padding: 24px;
  color: #374151;
  font-size: 15px;
  line-height: 1.6;
}

.modal-footer {
  padding: 16px 24px;
  background: #f9fafb;
  display: flex;
  justify-content: flex-end;
  border-top: 1px solid #e5e7eb;
}

.btn-close {
  background: #ff6347;
  color: white;
  border: none;
  padding: 10px 32px;
  border-radius: 8px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-close:hover {
  background: #ff4520;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(255, 99, 71, 0.3);
}

.btn-close:active {
  transform: translateY(0);
}

.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.3s;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}
</style>
