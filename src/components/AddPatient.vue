<template>
	<div v-if="show" class="modal-overlay" @click.self="closeModal">
		<NotificationModal
			:show="showNotification"
			:message="notificationMessage"
			:type="notificationType"
			@close="showNotification = false"
		/>

		<div class="modal-container">
			<div class="modal-header">
				<h2 class="modal-title">Add Patient</h2>
				<p class="modal-subtitle">Enter patient profile information</p>
			</div>

			<form class="modal-form" @submit.prevent="handleSubmit">
				<div class="form-row">
					<div class="form-group">
						<label for="idNumber">ID Number <span class="required">*</span></label>
						<input id="idNumber" v-model="formData.idNumber" class="form-input" type="text" required />
					</div>
					<div class="form-group">
						<label for="fullName">Full Name <span class="required">*</span></label>
						<input id="fullName" v-model="formData.fullName" class="form-input" type="text" required />
					</div>
				</div>

				<div class="form-row">
					<div class="form-group">
						<label for="email">Email <span class="required">*</span></label>
						<input id="email" v-model="formData.email" class="form-input" type="email" required />
					</div>
					<div class="form-group">
						<label for="contactNumber">Contact Number <span class="required">*</span></label>
						<input id="contactNumber" v-model="formData.contactNumber" class="form-input" type="text" required />
					</div>
				</div>

				<div class="form-row">
					<div class="form-group">
						<label for="department">College/Department <span class="required">*</span></label>
						<input id="department" v-model="formData.department" class="form-input" type="text" required />
					</div>
					<div class="form-group">
						<label for="program">Program <span class="required">*</span></label>
						<input id="program" v-model="formData.program" class="form-input" type="text" required />
					</div>
				</div>

				<div class="form-row">
					<div class="form-group">
						<label for="yearSection">Year/Section <span class="required">*</span></label>
						<input id="yearSection" v-model="formData.yearSection" class="form-input" type="text" required />
					</div>
					<div class="form-group">
						<label for="sex">Sex <span class="required">*</span></label>
						<select id="sex" v-model="formData.sex" class="form-select" required>
							<option value="">Select sex</option>
							<option value="Male">Male</option>
							<option value="Female">Female</option>
						</select>
					</div>
				</div>

				<div class="form-group">
					<label for="type">Type <span class="required">*</span></label>
					<select id="type" v-model="formData.type" class="form-select" required>
						<option value="">Select patient type</option>
						<option value="Student">Student</option>
						<option value="Faculty">Faculty</option>
						<option value="Staff">Staff</option>
					</select>
				</div>

				<div class="form-actions">
					<button type="submit" class="btn-submit">Add Patient</button>
					<button type="button" class="btn-close" @click="closeModal">Cancel</button>
				</div>
			</form>
		</div>
	</div>
</template>

<script>
import NotificationModal from './NotificationModal.vue'

export default {
	name: 'AddPatient',
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
				idNumber: '',
				fullName: '',
				email: '',
				contactNumber: '',
				department: '',
				program: '',
				yearSection: '',
				sex: '',
				type: ''
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
			if (!this.validateForm()) {
				return
			}

			this.$emit('add-patient', { ...this.formData })
			this.showNotificationModal('Adding patient...', 'info')
			this.resetForm()
		},
		validateForm() {
			const requiredFields = [
				'idNumber',
				'fullName',
				'email',
				'contactNumber',
				'department',
				'program',
				'yearSection',
				'sex',
				'type'
			]

			for (const field of requiredFields) {
				if (!this.formData[field]) {
					this.showNotificationModal('Please fill in all required fields', 'warning')
					return false
				}
			}

			return true
		},
		resetForm() {
			this.formData = {
				idNumber: '',
				fullName: '',
				email: '',
				contactNumber: '',
				department: '',
				program: '',
				yearSection: '',
				sex: '',
				type: ''
			}
		},
		showNotificationModal(message, type = 'info') {
			this.notificationMessage = message
			this.notificationType = type
			this.showNotification = true
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
	background: rgba(0, 0, 0, 0.45);
	display: flex;
	justify-content: center;
	align-items: center;
	z-index: 1000;
	padding: 20px;
}

.modal-container {
	background: #fff;
	width: 100%;
	max-width: 760px;
	border-radius: 16px;
	overflow: hidden;
	box-shadow: 0 20px 50px rgba(0, 0, 0, 0.25);
}

.modal-header {
	background: linear-gradient(135deg, #0ea5e9 0%, #0284c7 100%);
	color: #fff;
	padding: 20px 24px;
}

.modal-title {
	margin: 0;
	font-size: 24px;
}

.modal-subtitle {
	margin: 4px 0 0;
	opacity: 0.9;
	font-size: 13px;
}

.modal-form {
	padding: 24px;
	display: flex;
	flex-direction: column;
	gap: 16px;
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

label {
	font-size: 14px;
	font-weight: 600;
	color: #374151;
}

.required {
	color: #ef4444;
}

.form-input,
.form-select {
	border: 2px solid #e5e7eb;
	border-radius: 10px;
	padding: 10px 12px;
	font-size: 14px;
}

.form-input:focus,
.form-select:focus {
	outline: none;
	border-color: #0ea5e9;
}

.form-actions {
	display: flex;
	justify-content: flex-end;
	gap: 10px;
	margin-top: 4px;
}

.btn-submit,
.btn-close {
	border: 0;
	border-radius: 10px;
	padding: 10px 16px;
	font-weight: 600;
	cursor: pointer;
}

.btn-submit {
	background: #0284c7;
	color: #fff;
}

.btn-close {
	background: #e5e7eb;
	color: #374151;
}

@media (max-width: 768px) {
	.form-row {
		grid-template-columns: 1fr;
	}
}
</style>