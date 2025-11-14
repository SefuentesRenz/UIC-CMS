<template>
  <div v-if="show" class="profile-overlay" @click.self="closeProfile">
    <div class="profile-modal">
      <div class="profile-header">
        <img :src="userAvatar" alt="User Avatar" class="profile-avatar" />
        <h2 class="profile-greeting">Hi, <strong>{{ userName }}!</strong></h2>
      </div>

      <form class="profile-form" @submit.prevent="handleModify">
        <div class="form-group">
          <label for="full_name">Name</label>
          <input 
            type="text" 
            id="full_name" 
            v-model="formData.full_name" 
            class="form-input"
            :readonly="!isEditing"
          />
        </div>

        <div class="form-group">
          <label for="email">Email</label>
          <input 
            type="email" 
            id="email" 
            v-model="formData.email" 
            class="form-input"
            :readonly="!isEditing"
          />
        </div>

        <div class="form-group">
          <label for="school_id">School ID</label>
          <input 
            type="text" 
            id="school_id" 
            v-model="formData.school_id" 
            class="form-input"
            :readonly="!isEditing"
          />
        </div>

        <div class="form-group">
          <label for="role">Role</label>
          <input 
            type="text" 
            id="role" 
            v-model="formData.role" 
            class="form-input"
            :readonly="!isEditing"
          />
        </div>

        <div class="form-group">
          <label for="profileUpload">Profile Upload</label>
          <select 
            id="profileUpload" 
            class="form-select"
            :disabled="!isEditing"
          >
            <option value="">Choose File | File Uploaded</option>
          </select>
        </div>

        <!-- Messages -->
        <div v-if="errorMessage" class="error-message">{{ errorMessage }}</div>
        <div v-if="successMessage" class="success-message">{{ successMessage }}</div>

        <div class="form-actions">
          <button type="submit" class="btn-modify" :disabled="isLoading">
            {{ isEditing ? (isLoading ? 'Saving...' : 'Save') : 'Modify' }}
          </button>
          <button v-if="isEditing" type="button" class="btn-back" @click="cancelEdit">Cancel</button>
          <button v-else type="button" class="btn-back" @click="closeProfile">Back</button>
        </div>

        <div class="logout-section">
          <button type="button" class="btn-logout" @click="handleLogout">
            Logout
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, watch } from 'vue'
import { supabase } from '@/lib/Supabase.js'
import NurseProfileImg from '@/assets/NurseProfile.jpg'

// Props & emits
const props = defineProps({ show: { type: Boolean, default: false } })
const emit = defineEmits(['close', 'update:userName'])

// Router for navigation
import { useRouter } from 'vue-router'
const router = useRouter()

// Local state
const isEditing = ref(false)
const isLoading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')

const userName = ref('')
const userAvatar = ref(NurseProfileImg)

const formData = reactive({
  full_name: '',
  email: '',
  school_id: '',
  role: ''
})

/**
 * Fetch currently authenticated user and load their profile from `profiles` table
 */
async function fetchProfile() {
  isLoading.value = true
  errorMessage.value = ''
  successMessage.value = ''

  try {
    // Get current session first
    const { data: { session }, error: sessionErr } = await supabase.auth.getSession()
    console.log('Session check:', session ? 'Session exists' : 'No session', sessionErr || '')
    
    if (sessionErr) {
      console.error('Session error:', sessionErr)
      throw sessionErr
    }
    
    if (!session) {
      console.error('No session found')
      errorMessage.value = 'Auth session missing! Please log in again.'
      return
    }

    console.log('User ID:', session.user.id)

    const user = session.user
    if (!user) {
      errorMessage.value = 'No authenticated user found.'
      return
    }

    // Fetch profile row for this user
    const { data: profile, error: profileErr } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.id)
      .single()

    console.log('Profile fetch result:', profile || 'No profile', profileErr || '')

    if (profileErr) {
      console.error('Profile fetch error:', profileErr)
      errorMessage.value = 'Failed to load profile data. Error: ' + profileErr.message
      return
    }

    if (!profile) {
      console.error('No profile data found')
      errorMessage.value = 'No profile data found.'
      return
    }

    // Populate local state with profile values (preserve UI layout)
    userName.value = profile.full_name || user.user_metadata?.full_name || user.email?.split('@')[0] || 'User'
    userAvatar.value = NurseProfileImg

    // Emit the user name to parent for the dashboard header
    emit('update:userName', userName.value)

    formData.full_name = profile.full_name || ''
    formData.email = profile.email || user.email || ''
    formData.school_id = profile.school_id || ''
    formData.role = profile.role || ''

  } catch (err) {
    console.error('Error fetching profile:', err)
    errorMessage.value = err?.message ?? String(err)
  } finally {
    isLoading.value = false
  }
}

// Re-fetch profile whenever the modal is shown
watch(() => props.show, (visible) => {
  if (visible) {
    fetchProfile()
    isEditing.value = false
    errorMessage.value = ''
    successMessage.value = ''
  }
})

/**
 * Close the profile modal (emit to parent)
 */
function closeProfile() {
  emit('close')
}

/**
 * Handle the Modify button action.
 * - If not editing, this enables edit mode
 * - If editing, this saves changes back to `profiles` for the logged-in user
 */
async function handleModify() {
  // Toggle into edit mode if not already editing
  if (!isEditing.value) {
    isEditing.value = true
    errorMessage.value = ''
    successMessage.value = ''
    return
  }

  // Save changes
  isLoading.value = true
  errorMessage.value = ''
  successMessage.value = ''

  try {
    const { data: { session }, error: sessionErr } = await supabase.auth.getSession()
    if (sessionErr) throw sessionErr
    if (!session) throw new Error('No active session')

    const user = session.user
    if (!user) throw new Error('No authenticated user')

    // Update only the logged-in user's profile row
    const updates = {
      full_name: formData.full_name,
      school_id: formData.school_id,
      role: formData.role,
      email: formData.email
    }

    const { error: updateErr } = await supabase
      .from('profiles')
      .update(updates)
      .eq('id', user.id)

    if (updateErr) throw updateErr

    successMessage.value = 'Profile updated successfully.'
    isEditing.value = false

    // Refresh profile data to reflect saved values
    await fetchProfile()
  } catch (err) {
    console.error('Profile update error:', err)
    errorMessage.value = err?.message ?? String(err)
  } finally {
    isLoading.value = false
  }
}

/**
 * Cancel edit mode and revert changes by reloading profile data
 */
async function cancelEdit() {
  isEditing.value = false
  errorMessage.value = ''
  successMessage.value = ''
  await fetchProfile()
}

/**
 * Handle user logout
 */
async function handleLogout() {
  try {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
    
    // Clear any stored session data
    localStorage.removeItem('supabase.auth.token')
    
    // Redirect to login page
    router.push('/login')
  } catch (err) {
    console.error('Logout error:', err)
    errorMessage.value = 'Failed to logout. Please try again.'
  }
}
</script>

<style scoped>
.logout-section {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #e2e8f0;
}

.btn-logout {
  width: 100%;
  padding: 14px 24px;
  border: none;
  border-radius: 10px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  letter-spacing: 0.3px;
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
  box-shadow: 0 3px 10px rgba(239, 68, 68, 0.26);
}

.btn-logout:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 14px rgba(239, 68, 68, 0.34);
}

.btn-logout:active {
  transform: translateY(0);
}
.profile-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(15, 23, 42, 0.6);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  backdrop-filter: blur(8px);
  animation: fadeIn 0.2s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.profile-modal {
  background: white;
  border-radius: 20px;
  padding: 0;
  width: 86%;
  max-width: 500px;
  box-shadow: 0 14px 40px rgba(0, 0, 0, 0.22);
  animation: slideIn 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  overflow: hidden;
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

.profile-header {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px 18px;
  background: linear-gradient(135deg, #ec4899 0%, #d946ef 100%);
  border-bottom: none;
}

.profile-avatar {
  width: 72px;
  height: 72px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid white;
  box-shadow: 0 6px 18px rgba(0, 0, 0, 0.18);
}

.profile-greeting {
  font-size: 18px;
  color: white;
  margin: 0;
  font-weight: 600;
}

.profile-greeting strong {
  color: white;
  font-weight: 700;
}

.profile-form {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 18px 18px 20px 18px;
  max-height: calc(100vh - 160px);
  overflow-y: auto;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-group label {
  font-size: 12px;
  font-weight: 600;
  color: #475569;
  text-transform: uppercase;
  letter-spacing: 0.4px;
}

.form-input,
.form-select {
  padding: 10px 12px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  font-size: 14px;
  color: #1e293b;
  background: #f8fafc;
  transition: all 0.18s cubic-bezier(0.4, 0, 0.2, 1);
  font-family: inherit;
}

.form-input:hover:not([readonly]),
.form-select:hover {
  border-color: #cbd5e1;
  background: white;
}

.form-input:focus,
.form-select:focus {
  outline: none;
  border-color: #ec4899;
  background: white;
  box-shadow: 0 0 0 3px rgba(236, 72, 153, 0.08);
}

.form-input[readonly] {
  background: #f1f5f9;
  cursor: not-allowed;
  color: #64748b;
}

.form-select {
  cursor: pointer;
  background: white;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 16 16'%3E%3Cpath fill='%2364748b' d='M4 6l4 4 4-4z'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 10px center;
  padding-right: 36px;
}

.form-actions {
  display: flex;
  gap: 12px;
  margin-top: 8px;
}

.btn-modify,
.btn-back {
  flex: 1;
  padding: 14px 24px;
  border: none;
  border-radius: 10px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  letter-spacing: 0.3px;
}

.btn-modify {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  box-shadow: 0 3px 10px rgba(16, 185, 129, 0.26);
}

.btn-modify:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 14px rgba(16, 185, 129, 0.34);
}

.btn-modify:active {
  transform: translateY(0);
}

.btn-back {
  background: linear-gradient(135deg, #64748b 0%, #475569 100%);
  color: white;
  box-shadow: 0 3px 10px rgba(100, 116, 139, 0.22);
}

.btn-back:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(100, 116, 139, 0.4);
}

.btn-back:active {
  transform: translateY(0);
}

/* Message styles */
.error-message {
  background: #fee2e2;
  border: 1px solid #fca5a5;
  color: #b91c1c;
  padding: 10px 12px;
  border-radius: 8px;
  font-size: 13px;
}

.success-message {
  background: #ecfdf5;
  border: 1px solid #bbf7d0;
  color: #065f46;
  padding: 10px 12px;
  border-radius: 8px;
  font-size: 13px;
}

/* Responsive Design */
@media (max-width: 640px) {
  .profile-modal {
    width: 96%;
  }

  .profile-header {
    flex-direction: column;
    text-align: center;
    padding: 28px 24px;
  }

  .profile-greeting {
    font-size: 18px;
  }

  .profile-form {
    padding: 16px;
  }

  .form-actions {
    flex-direction: column;
  }

  .btn-modify,
  .btn-back {
    width: 100%;
  }
}
</style>
