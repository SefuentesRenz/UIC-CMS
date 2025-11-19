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
        <a href="#" class="nav-item active" @click.prevent="activeTab = 'profile'">
          <i class="icon">👤</i>
          <span>My Profile</span>
        </a>
        <a href="#" class="nav-item" @click.prevent="activeTab = 'history'">
          <i class="icon">🏥</i>
          <span>Medical History</span>
        </a>
        <a href="#" class="nav-item" @click.prevent="activeTab = 'appointments'">
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
            <h2>Medical Consultation History</h2>
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
                <div class="consultation-item">
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
                </div>

                <!-- Vital Signs -->
                <div class="vital-signs" v-if="consultation.temperature || consultation.blood_pressure">
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
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../supabaseClient'
import { useRouter } from 'vue-router'
import NurseProfileImg from '@/assets/NurseProfile.jpg'

export default {
  name: 'StudentHome',
  setup() {
    const router = useRouter()
    
    // Reactive state
    const activeTab = ref('profile')
    const userProfile = ref(null)
    const consultations = ref([])
    const loading = ref(true)
    const error = ref(null)
    const userAvatar = ref(NurseProfileImg)

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
        // Get current user
        const { data: { user }, error: userError } = await supabase.auth.getUser()
        
        if (userError || !user) {
          console.error('Not authenticated:', userError)
          router.push('/login')
          return
        }

        console.log('Current user ID:', user.id)

        // Fetch user profile
        const { data: profile, error: profileError } = await supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
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

        // Fetch consultation history
        const { data: consultationData, error: consultationError } = await supabase
          .from('consultations')
          .select(`
            *,
            attended_by_profile:profiles!consultations_attended_by_fkey(full_name)
          `)
          .eq('student_id', user.id)
          .order('consultation_date', { ascending: false })

        if (consultationError) {
          console.error('Error fetching consultations:', consultationError)
          // Don't throw - consultations might not exist yet
        } else {
          consultations.value = consultationData.map(c => ({
            ...c,
            attended_by_name: c.attended_by_profile?.full_name || 'Clinic Staff'
          }))
          console.log(`Loaded ${consultations.value.length} consultations`)
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
        alert(`Failed to logout: ${err.message}`)
      }
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
      handleLogout
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
  flex-direction: column;
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
}

.attended-by {
  font-size: 13px;
  color: #64748b;
  font-style: italic;
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
}
</style>
