<template>
  <div class="student-portal">
    <!-- Sidebar -->
    <aside class="sidebar">
      <div class="sidebar-header">
        <img src="@/assets/logo.png" alt="UIC-CMS Logo" class="sidebar-logo" />
        <h2 class="sidebar-title">UIC-CMS</h2>
        <p class="sidebar-subtitle">Student Portal</p>
      </div>
      
      <nav class="sidebar-nav">
        <a href="#" :class="['nav-item', { active: activeTab === 'profile' }]" @click.prevent="activeTab = 'profile'">
          <i class="icon">👤</i>
          <span>My Profile</span>
        </a>
        <a href="#" :class="['nav-item', { active: activeTab === 'history' }]" @click.prevent="activeTab = 'history'">
          <i class="icon">🏥</i>
          <span>Medical History</span>
        </a>
        <a href="#" :class="['nav-item', { active: activeTab === 'appointments' }]" @click.prevent="activeTab = 'appointments'">
          <i class="icon">📅</i>
          <span>Appointments</span>
        </a>
      </nav>

      <div class="sidebar-footer">
        <button class="logout-btn" @click="handleLogout">
          <i class="icon">🚪</i>
          <span>Logout</span>
        </button>
      </div>
    </aside>

    <!-- Notification Modal -->
    <NotificationModal 
      :show="showNotification" 
      :message="notificationMessage" 
      :type="notificationType"
      @close="showNotification = false" />
    
    <!-- Main Content -->
    <main class="main-content">
      <!-- Header -->
      <header class="header">
        <div class="header-content">
          <h1 class="page-title">{{ pageTitle }}</h1>
          <p class="page-subtitle">{{ pageSubtitle }}</p>
        </div>
        <div class="user-profile">
          <img :src="userAvatar" alt="Student" class="user-avatar" />
          <div class="user-info">
            <span class="user-name">{{ userProfile?.full_name || 'Student' }}</span>
            <span class="user-id">{{ userProfile?.school_id }}</span>
          </div>
        </div>
      </header>

      <!-- Loading State -->
      <div v-if="loading" class="loading-state">
        <div class="spinner"></div>
        <p>Loading your information...</p>
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="error-state">
        <div class="error-icon">❌</div>
        <p class="error-message">{{ error }}</p>
        <button @click="fetchStudentData" class="retry-btn">Retry</button>
      </div>

      <!-- Content Area -->
      <div v-else class="content-area">
        <!-- Profile Tab -->
        <div v-show="activeTab === 'profile'" class="tab-content">
          <div class="profile-card">
            <div class="profile-header">
              <img :src="userAvatar" alt="Profile" class="profile-avatar" />
              <div class="profile-info">
                <h2>{{ userProfile?.full_name }}</h2>
                <p class="school-id">{{ userProfile?.school_id }}</p>
                <span :class="['status-badge', userProfile?.status?.toLowerCase()]">
                  {{ userProfile?.status || 'Active' }}
                </span>
              </div>
              <button @click="showEditModal = true" class="edit-profile-btn">
                <span class="icon">✏️</span>
                Edit Profile
              </button>
            </div>

            <div class="profile-details">
              <div class="detail-grid">
                <div class="detail-item">
                  <span class="label">Email:</span>
                  <span class="value">{{ userProfile?.email }}</span>
                </div>
                <div class="detail-item">
                  <span class="label">Contact Number:</span>
                  <span class="value">{{ userProfile?.contact_number || 'N/A' }}</span>
                </div>
                <div class="detail-item">
                  <span class="label">College/Department:</span>
                  <span class="value">{{ userProfile?.college_department || 'N/A' }}</span>
                </div>
                <div class="detail-item">
                  <span class="label">Program:</span>
                  <span class="value">{{ userProfile?.program || 'N/A' }}</span>
                </div>
                <div class="detail-item">
                  <span class="label">Year & Section:</span>
                  <span class="value">{{ userProfile?.year_section || 'N/A' }}</span>
                </div>
                <div class="detail-item">
                  <span class="label">Sex:</span>
                  <span class="value">{{ userProfile?.sex || 'N/A' }}</span>
                </div>
                <div class="detail-item">
                  <span class="label">Type:</span>
                  <span class="value">{{ userProfile?.type || 'Regular' }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Medical History Tab -->
        <div v-show="activeTab === 'history'" class="tab-content">
          <div class="history-header">
          
            <p>Total Consultations: <strong>{{ consultations.length }}</strong></p>
          </div>

          <div v-if="consultations.length === 0" class="empty-state">
            <div class="empty-icon">🏥</div>
            <p>No consultation history yet</p>
            <p class="empty-subtitle">Your medical visits will appear here</p>
          </div>

          <div v-else class="consultations-list">
            <div v-for="consultation in consultations" :key="consultation.id" class="consultation-card">
              <div class="consultation-header">
                <div class="consultation-date">
                  <i class="icon">📅</i>
                  <span>{{ formatDate(consultation.consultation_date) }}</span>
                </div>
                <span :class="['status-badge', consultation.status?.toLowerCase()]">
                  {{ consultation.status }}
                </span>
              </div>

              <div class="consultation-body">
                <div class="consultation-item" v-if="consultation.chief_complaint">
                  <strong>Chief Complaint:</strong>
                  <p>{{ consultation.chief_complaint }}</p>
                </div>
                <div class="consultation-item" v-if="consultation.diagnosis">
                  <strong>Diagnosis:</strong>
                  <p>{{ consultation.diagnosis }}</p>
                </div>
                <div class="consultation-item" v-if="consultation.treatment">
                  <strong>Treatment:</strong>
                  <p>{{ consultation.treatment }}</p>
                </div>
                <div class="consultation-item" v-if="consultation.prescription">
                  <strong>Prescription:</strong>
                  <p>{{ consultation.prescription }}</p>
                  <span v-if="consultation.quantity" class="quantity-badge">Qty: {{ consultation.quantity }}</span>
                </div>
                <div class="consultation-item" v-if="consultation.notes">
                  <strong>Notes:</strong>
                  <p>{{ consultation.notes }}</p>
                </div>
                <div class="consultation-item" v-if="consultation.remarks">
                  <strong>Remarks:</strong>
                  <p>{{ consultation.remarks }}</p>
                </div>

                <!-- Vital Signs -->
                <div class="vital-signs" v-if="consultation.temperature || consultation.blood_pressure || consultation.heart_rate || consultation.weight">
                  <strong>Vital Signs:</strong>
                  <div class="vitals-grid">
                    <span v-if="consultation.temperature">🌡️ {{ consultation.temperature }}°C</span>
                    <span v-if="consultation.blood_pressure">❤️ {{ consultation.blood_pressure }}</span>
                    <span v-if="consultation.heart_rate">💓 {{ consultation.heart_rate }} bpm</span>
                    <span v-if="consultation.weight">⚖️ {{ consultation.weight }} kg</span>
                  </div>
                </div>

                <div class="consultation-footer">
                  <span class="attended-by">Attended by: {{ consultation.attended_by_name || 'Clinic Staff' }}</span>
                  <span v-if="consultation.follow_up_date" class="follow-up">
                    Follow-up: {{ formatDate(consultation.follow_up_date) }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Appointments Tab (Placeholder) -->
        <div v-show="activeTab === 'appointments'" class="tab-content">
          <div class="empty-state">
            <div class="empty-icon">📅</div>
            <p>Appointments feature coming soon</p>
            <p class="empty-subtitle">You'll be able to schedule clinic appointments here</p>
          </div>
        </div>
      </div>
    </main>

    <!-- Edit Profile Modal -->
    <div v-if="showEditModal" class="modal-overlay" @click.self="showEditModal = false">
      <div class="modal-content edit-profile-modal">
        <div class="modal-header">
          <h2>Complete Your Profile</h2>
          <button @click="showEditModal = false" class="close-btn">×</button>
        </div>
        
        <div class="modal-body">
          <form @submit.prevent="saveProfile" class="profile-form">
            <div class="form-row">
              <div class="form-group">
                <label>Full Name <span class="required">*</span></label>
                <input 
                  v-model="editForm.full_name" 
                  type="text" 
                  required 
                  placeholder="Enter your full name"
                />
              </div>
              
              <div class="form-group">
                <label>Contact Number <span class="required">*</span></label>
                <input 
                  v-model="editForm.contact_number" 
                  type="tel" 
                  required
                  placeholder="09XX-XXX-XXXX"
                  pattern="[0-9]{11}"
                  maxlength="11"
                />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label>College/Department <span class="required">*</span></label>
                <select v-model="editForm.college_department" required>
                  <option value="">Select College/Department</option>
                  <option value="College of Engineering">College of Engineering</option>
                  <option value="College of Science">College of Science</option>
                  <option value="College of Arts and Letters">College of Arts and Letters</option>
                  <option value="College of Business Administration">College of Business Administration</option>
                  <option value="College of Education">College of Education</option>
                  <option value="College of Architecture and Fine Arts">College of Architecture and Fine Arts</option>
                  <option value="College of Social Sciences and Development">College of Social Sciences and Development</option>
                  <option value="College of Nursing">College of Nursing</option>
                  <option value="Other">Other</option>
                </select>
              </div>

              <div class="form-group">
                <label>Program <span class="required">*</span></label>
                <input 
                  v-model="editForm.program" 
                  type="text" 
                  required
                  placeholder="e.g., BS Computer Science"
                />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label>Year & Section <span class="required">*</span></label>
                <select v-model="editForm.year_section" required>
                  <option value="">Select Year & Section</option>
                  <option value="1st Year">1st Year</option>
                  <option value="2nd Year">2nd Year</option>
                  <option value="3rd Year">3rd Year</option>
                  <option value="4th Year">4th Year</option>
                  <option value="5th Year">5th Year</option>
                  <option value="Graduate">Graduate</option>
                </select>
              </div>

              <div class="form-group">
                <label>Sex <span class="required">*</span></label>
                <select v-model="editForm.sex" required>
                  <option value="">Select Sex</option>
                  <option value="Male">Male</option>
                  <option value="Female">Female</option>
                </select>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label>Type <span class="required">*</span></label>
                <select v-model="editForm.type" required>
                  <option value="">Select Type</option>
                  <option value="Student">Student</option>
                  <option value="Faculty">Faculty</option>
                  <option value="Staff">Staff</option>
                </select>
              </div>
            </div>

            <div class="form-actions">
              <button type="button" @click="showEditModal = false" class="btn-cancel">
                Cancel
              </button>
              <button type="submit" class="btn-save" :disabled="isSaving">
                {{ isSaving ? 'Saving...' : 'Save Profile' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../supabaseClient'
import { useRouter } from 'vue-router'
import NurseProfileImg from '@/assets/NurseProfile.jpg'
import NotificationModal from '../components/NotificationModal.vue'

export default {
  name: 'StudentHome',
  components: {
    NotificationModal
  },
  setup() {
    const router = useRouter()
    
    // Reactive state
    const activeTab = ref('profile')
    const userProfile = ref(null)
    const consultations = ref([])
    const loading = ref(true)
    const error = ref(null)
    const userAvatar = ref(NurseProfileImg)
    
    // Notification modal state
    const showNotification = ref(false)
    const notificationMessage = ref('')
    const notificationType = ref('info')
    
    // Edit profile modal state
    const showEditModal = ref(false)
    const isSaving = ref(false)
    const editForm = ref({
      full_name: '',
      contact_number: '',
      college_department: '',
      program: '',
      year_section: '',
      sex: '',
      type: ''
    })

    // Computed properties
    const pageTitle = computed(() => {
      switch (activeTab.value) {
        case 'profile': return 'My Profile'
        case 'history': return 'Medical History'
        case 'appointments': return 'Appointments'
        default: return 'Student Portal'
      }
    })

    const pageSubtitle = computed(() => {
      switch (activeTab.value) {
        case 'profile': return 'View and manage your personal information'
        case 'history': return 'View your consultation and medical records'
        case 'appointments': return 'Manage your clinic appointments'
        default: return 'Welcome to your student portal'
      }
    })

    // Fetch student profile and consultation history
    const fetchStudentData = async () => {
      console.log('=== FETCHING STUDENT DATA ===')
      loading.value = true
      error.value = null

      try {
        // Force refresh the session to get the most current authenticated user
        console.log('Refreshing session to get current user...')
        const { data: { session }, error: refreshError } = await supabase.auth.refreshSession()
        
        let currentUser = null
        
        if (refreshError || !session || !session.user) {
          console.warn('Session refresh failed, trying getSession:', refreshError)
          
          // Fallback to getSession if refresh fails
          const { data: { session: fallbackSession }, error: sessionError } = await supabase.auth.getSession()
          
          if (sessionError || !fallbackSession || !fallbackSession.user) {
            console.error('Not authenticated:', sessionError)
            router.push('/login')
            return
          }
          
          currentUser = fallbackSession.user
          console.log('Current user ID (fallback):', currentUser.id)
          console.log('Current user email (fallback):', currentUser.email)
        } else {
          currentUser = session.user
          console.log('Current user ID (refreshed):', currentUser.id)
          console.log('Current user email (refreshed):', currentUser.email)
        }

        // Fetch user profile
        const { data: profile, error: profileError } = await supabase
          .from('profiles')
          .select('*')
          .eq('id', currentUser.id)
          .single()

        if (profileError) {
          console.error('Error fetching profile:', profileError)
          throw new Error('Failed to load profile')
        }

        console.log('Profile loaded:', profile)

        // Verify user is a student
        if (profile.role !== 'Student') {
          console.warn('User is not a student, redirecting to dashboard')
          router.push('/dashboard')
          return
        }

        userProfile.value = profile
        
        // Populate edit form with current profile data
        editForm.value = {
          full_name: profile.full_name || '',
          contact_number: profile.contact_number || '',
          college_department: profile.college_department || '',
          program: profile.program || '',
          year_section: profile.year_section || '',
          sex: profile.sex || '',
          type: profile.type || 'Student'
        }

        // Find patient record by matching FULL NAME (primary match)
        // This allows linking consultations even if created before account existed
        console.log('Looking up patient record for name:', profile.full_name)
        
        let patientRecord = null
        let patientError = null
        
        // Strategy 1: Try exact full name match (case-insensitive)
        const { data: nameMatch, error: nameError } = await supabase
          .from('patients')
          .select('id, full_name, school_id')
          .ilike('full_name', profile.full_name)
          .limit(1)
          .single()

        if (!nameError && nameMatch) {
          patientRecord = nameMatch
          console.log('✅ Found patient by exact name match:', patientRecord)
        } else {
          // Strategy 2: Fallback to school_id match if available
          if (profile.school_id) {
            console.log('Name match failed, trying school_id:', profile.school_id)
            const { data: idMatch, error: idError } = await supabase
              .from('patients')
              .select('id, full_name, school_id')
              .eq('school_id', profile.school_id)
              .single()
            
            if (!idError && idMatch) {
              patientRecord = idMatch
              console.log('✅ Found patient by school_id match:', patientRecord)
            } else {
              patientError = idError
            }
          } else {
            patientError = nameError
          }
        }

        if (!patientRecord) {
          console.warn('No patient record found for:', profile.full_name)
          console.warn('Error:', patientError)
          consultations.value = []
        } else {
          console.log('📋 Using patient record:', patientRecord)
          
          // Fetch consultation history using patient ID
          const { data: consultationData, error: consultationError } = await supabase
            .from('consultations')
            .select('*')
            .eq('student_id', patientRecord.id)
            .order('consultation_date', { ascending: false })

          if (consultationError) {
            console.error('Error fetching consultations:', consultationError)
            consultations.value = []
          } else {
            consultations.value = consultationData.map(c => ({
              ...c,
              attended_by_name: c.attended_by_name || 'Clinic Staff'
            }))
            console.log(`✅ Loaded ${consultations.value.length} consultations for ${patientRecord.full_name}`)
          }
        }

      } catch (err) {
        console.error('Failed to fetch student data:', err)
        error.value = err.message || 'Failed to load student data'
      } finally {
        loading.value = false
      }
    }

    // Format date for display
    const formatDate = (dateString) => {
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

    // Logout handler
    const handleLogout = async () => {
      console.log('=== LOGGING OUT ===')
      try {
        const { error } = await supabase.auth.signOut()
        if (error) throw error
        
        console.log('✅ Logged out successfully')
        router.push('/login')
      } catch (err) {
        console.error('Logout error:', err)
        showNotificationModal(`Failed to logout: ${err.message}`, 'error')
      }
    }
    
    const saveProfile = async () => {
      try {
        isSaving.value = true
        
        // Validate contact number (11 digits)
        if (editForm.value.contact_number && !/^[0-9]{11}$/.test(editForm.value.contact_number)) {
          showNotificationModal('Contact number must be 11 digits', 'error')
          return
        }
        
        // Get current session
        const { data: { session } } = await supabase.auth.getSession()
        if (!session?.user) {
          showNotificationModal('Not authenticated', 'error')
          return
        }
        
        // Update profile in database
        const { error } = await supabase
          .from('profiles')
          .update({
            full_name: editForm.value.full_name,
            contact_number: editForm.value.contact_number,
            college_department: editForm.value.college_department,
            program: editForm.value.program,
            year_section: editForm.value.year_section,
            sex: editForm.value.sex,
            type: editForm.value.type,
            updated_at: new Date().toISOString()
          })
          .eq('id', session.user.id)
        
        if (error) throw error
        
        // Refresh profile data
        await fetchStudentData()
        
        showNotificationModal('Profile updated successfully!', 'success')
        showEditModal.value = false
        
      } catch (err) {
        console.error('Error updating profile:', err)
        showNotificationModal(`Failed to update profile: ${err.message}`, 'error')
      } finally {
        isSaving.value = false
      }
    }
    
    const showNotificationModal = (message, type = 'info') => {
      notificationMessage.value = message
      notificationType.value = type
      showNotification.value = true
    }

    // Load data on mount
    onMounted(async () => {
      await fetchStudentData()
    })

    return {
      activeTab,
      userProfile,
      consultations,
      loading,
      error,
      userAvatar,
      pageTitle,
      pageSubtitle,
      fetchStudentData,
      formatDate,
      handleLogout,
      showNotification,
      notificationMessage,
      notificationType,
      showNotificationModal,
      showEditModal,
      editForm,
      isSaving,
      saveProfile
    }
  }
}
</script>

<style scoped>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

.student-portal {
  display: flex;
  min-height: 100vh;
  background: #f5f7fa;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

/* Sidebar */
.sidebar {
  width: 260px;
  background: linear-gradient(180deg, #3b82f6 0%, #2563eb 100%);
  color: white;
  display: flex;
  flex-direction: column;
  box-shadow: 4px 0 10px rgba(0, 0, 0, 0.1);
  position: fixed;
  height: 100vh;
}

.sidebar-header {
  padding: 24px 20px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  text-align: center;
}

.sidebar-logo {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: white;
  padding: 8px;
  object-fit: contain;
  margin-bottom: 12px;
}

.sidebar-title {
  font-size: 22px;
  font-weight: 700;
  margin-bottom: 4px;
}

.sidebar-subtitle {
  font-size: 13px;
  opacity: 0.8;
}

.sidebar-nav {
  flex: 1;
  padding: 20px 0;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 20px;
  color: white;
  text-decoration: none;
  transition: all 0.3s ease;
  cursor: pointer;
  border-left: 4px solid transparent;
}

.nav-item:hover {
  background: rgba(255, 255, 255, 0.1);
  border-left-color: white;
}

.nav-item.active {
  background: rgba(255, 255, 255, 0.15);
  border-left-color: white;
  font-weight: 600;
}

.nav-item .icon {
  font-size: 20px;
}

.sidebar-footer {
  padding: 20px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.logout-btn {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px;
  background: rgba(255, 255, 255, 0.1);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.logout-btn:hover {
  background: rgba(255, 255, 255, 0.2);
}

/* Main Content */
.main-content {
  flex: 1;
  margin-left: 260px;
  display: flex;
  flex-direction: column;
}

.header {
  background: white;
  padding: 20px 32px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.header-content h1 {
  font-size: 28px;
  color: #1e293b;
  margin-bottom: 4px;
}

.page-subtitle {
  font-size: 14px;
  color: #64748b;
}

.user-profile {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #3b82f6;
}

.user-info {
  display: flex;
  flex-direction: column;
}

.user-name {
  font-size: 14px;
  font-weight: 600;
  color: #1e293b;
}

.user-id {
  font-size: 12px;
  color: #64748b;
}

/* Content Area */
.content-area {
  flex: 1;
  padding: 24px 32px;
  overflow-y: auto;
}

/* Loading/Error States */
.loading-state,
.error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  text-align: center;
  color: #64748b;
}

.spinner {
  width: 48px;
  height: 48px;
  border: 4px solid #e2e8f0;
  border-top-color: #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.error-icon {
  font-size: 64px;
  margin-bottom: 16px;
}

.error-message {
  font-size: 16px;
  font-weight: 600;
  color: #ef4444;
  margin-bottom: 16px;
}

.retry-btn {
  padding: 10px 24px;
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
}

/* Profile Card */
.profile-card {
  background: white;
  border-radius: 16px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.profile-header {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  padding: 32px;
  display: flex;
  align-items: center;
  gap: 24px;
  color: white;
}

.profile-avatar {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  object-fit: cover;
  border: 4px solid white;
}

.profile-info h2 {
  font-size: 28px;
  margin-bottom: 8px;
}

.school-id {
  font-size: 16px;
  opacity: 0.9;
  margin-bottom: 12px;
  display: block;
}

.status-badge {
  display: inline-block;
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 700;
}

.status-badge.active {
  background: #10b981;
  color: white;
}

.status-badge.inactive {
  background: #ef4444;
  color: white;
}

.profile-details {
  padding: 32px;
}

.detail-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 24px;
}

.detail-item {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.detail-item .label {
  font-size: 12px;
  font-weight: 600;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.detail-item .value {
  font-size: 16px;
  color: #1e293b;
  font-weight: 500;
}

/* Consultation History */
.history-header {
  margin-bottom: 24px;
}

.history-header h2 {
  font-size: 24px;
  color: #1e293b;
  margin-bottom: 8px;
}

.history-header p {
  font-size: 14px;
  color: #64748b;
}

.empty-state {
  background: white;
  border-radius: 16px;
  padding: 60px 20px;
  text-align: center;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.empty-icon {
  font-size: 64px;
  margin-bottom: 16px;
}

.empty-state p {
  font-size: 16px;
  color: #64748b;
  margin-bottom: 8px;
}

.empty-subtitle {
  font-size: 14px;
  color: #94a3b8;
}

.consultations-list {
  display: flex;
  flex-direction: row;
  gap: 16px;
}

.consultation-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  overflow: hidden;
  transition: transform 0.2s ease;
}

.consultation-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
}

.consultation-header {
  padding: 16px 20px;
  background: #f8fafc;
  border-bottom: 1px solid #e2e8f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.consultation-date {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  font-weight: 600;
  color: #475569;
}

.consultation-body {
  padding: 20px;
}

.consultation-item {
  margin-bottom: 16px;
}

.consultation-item strong {
  display: block;
  font-size: 13px;
  color: #64748b;
  margin-bottom: 4px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.consultation-item p {
  font-size: 15px;
  color: #1e293b;
  line-height: 1.6;
}

.vital-signs {
  margin-bottom: 16px;
}

.vitals-grid {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
  margin-top: 8px;
}

.vitals-grid span {
  padding: 8px 16px;
  background: #f1f5f9;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  color: #475569;
}

.consultation-footer {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #e2e8f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
}

.attended-by {
  font-size: 13px;
  color: #64748b;
  font-style: italic;
}

.follow-up {
  font-size: 12px;
  color: #f59e0b;
  font-weight: 600;
  padding: 4px 8px;
  background: #fef3c7;
  border-radius: 6px;
}

.quantity-badge {
  display: inline-block;
  margin-left: 8px;
  padding: 4px 10px;
  background: #dbeafe;
  color: #1e40af;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
}

/* Status badges in consultation */
.consultation-header .status-badge {
  font-size: 11px;
  padding: 4px 12px;
}

.status-badge.completed {
  background: #10b981;
  color: white;
}

.status-badge.pending {
  background: #f59e0b;
  color: white;
}

.status-badge.in.progress {
  background: #3b82f6;
  color: white;
}

/* Edit Profile Button */
.edit-profile-btn {
  padding: 10px 20px;
  background: linear-gradient(135deg, #01820a 0%, #00a838 100%);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(59, 130, 246, 0.3);
  margin-left: auto;
}

.edit-profile-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.4);
}

.edit-profile-btn .icon {
  font-size: 16px;
}

/* Edit Profile Modal */
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

/* Profile Form */
.profile-form {
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

.form-group label {
  font-size: 14px;
  font-weight: 600;
  color: #374151;
}

.required {
  color: #ef4444;
}

.form-group input,
.form-group select {
  padding: 12px 16px;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  font-size: 14px;
  transition: all 0.2s ease;
  font-family: inherit;
}

.form-group input:focus,
.form-group select:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.form-group input::placeholder {
  color: #9ca3af;
}

/* Form Actions */
.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 8px;
  padding-top: 20px;
  border-top: 1px solid #e5e7eb;
}

.btn-cancel,
.btn-save {
  padding: 12px 24px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  border: none;
}

.btn-cancel {
  background: #f1f5f9;
  color: #64748b;
}

.btn-cancel:hover {
  background: #e2e8f0;
  color: #475569;
}

.btn-save {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  color: white;
  box-shadow: 0 2px 8px rgba(59, 130, 246, 0.3);
}

.btn-save:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.4);
}

.btn-save:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* Responsive */
@media (max-width: 768px) {
  .sidebar {
    width: 70px;
  }

  .sidebar-title,
  .sidebar-subtitle,
  .nav-item span,
  .logout-btn span {
    display: none;
  }

  .main-content {
    margin-left: 70px;
  }

  .header {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }

  .profile-header {
    flex-direction: column;
    text-align: center;
  }

  .detail-grid {
    grid-template-columns: 1fr;
  }

  .form-row {
    grid-template-columns: 1fr;
  }

  .modal-content {
    margin: 10px;
    max-height: 95vh;
  }

  .modal-header {
    padding: 16px;
  }

  .modal-body {
    padding: 16px;
  }

  .edit-profile-btn {
    font-size: 12px;
    padding: 8px 16px;
  }
}
</style>
