<template>
  <div class="dashboard-container">
    <!-- Sidebar -->
    <aside class="sidebar">
      <div class="sidebar-header">
        <img src="@/assets/logo.png" alt="UIC-CMS Logo" class="sidebar-logo" />
        <h2 class="sidebar-title">UIC-CMS</h2>
      </div>
      
      <nav class="sidebar-nav">
        <router-link to="/dashboard" class="nav-item">
          <i class="icon" aria-hidden="true">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <rect x="3" y="3" width="7" height="7" fill="currentColor" />
              <rect x="14" y="3" width="7" height="4" fill="currentColor" />
              <rect x="14" y="9" width="7" height="12" fill="currentColor" />
              <rect x="3" y="11" width="7" height="10" fill="currentColor" />
            </svg>
          </i>
          <span>Dashboard</span>
        </router-link>
        <router-link to="/patient-record" class="nav-item active">
          <i class="icon" aria-hidden="true">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M7 7H17V5H7V7Z" fill="currentColor" />
              <rect x="7" y="9" width="10" height="12" rx="1" fill="currentColor" />
            </svg>
          </i>
          <span>Patient Record</span>
        </router-link>
        <router-link to="/medicine" class="nav-item">
          <i class="icon" aria-hidden="true">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M21 7L17 11" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
              <path d="M7 17L11 13" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
            </svg>
          </i>
          <span>Medicine</span>
        </router-link>
        <router-link to="/consultations" class="nav-item">
          <i class="icon" aria-hidden="true">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M19 3H5C3.89543 3 3 3.89543 3 5V19C3 20.1046 3.89543 21 5 21H19C20.1046 21 21 20.1046 21 19V5C21 3.89543 20.1046 3 19 3Z" stroke="currentColor" stroke-width="2" fill="none"/>
              <path d="M9 7H15M9 12H15M9 17H12" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
            </svg>
          </i>
          <span>Consultations</span>
        </router-link>
        <router-link to="/transactions" class="nav-item">
          <i class="icon" aria-hidden="true">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <rect x="3" y="4" width="18" height="16" rx="2" stroke="currentColor" stroke-width="1.5" fill="currentColor" />
              <path d="M7 8H17" stroke="#fff" stroke-width="1.2" stroke-linecap="round" />
              <path d="M7 12H13" stroke="#fff" stroke-width="1.2" stroke-linecap="round" />
            </svg>
          </i>
          <span>Transactions</span>
        </router-link>
        <router-link to="/staff-users" class="nav-item">
          <i class="icon" aria-hidden="true">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M16 11C17.6569 11 19 9.65685 19 8C19 6.34315 17.6569 5 16 5C14.3431 5 13 6.34315 13 8C13 9.65685 14.3431 11 16 11Z" fill="currentColor" />
              <path d="M8 11C9.65685 11 11 9.65685 11 8C11 6.34315 9.65685 5 8 5C6.34315 5 5 6.34315 5 8C5 9.65685 6.34315 11 8 11Z" fill="currentColor" />
            </svg>
          </i>
          <span>Clinic Staff Users</span>
        </router-link>
        
      </nav>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
      <!-- Header -->
      <header class="header">
        
        <div class="user-profile" @click="showProfileModal = true" style="cursor: pointer;">
          <img src="@/assets/NurseProfile.jpg" alt="User Avatar" class="user-avatar" />
          <span class="user-greeting">Hi, <strong>{{ userName }}</strong></span>
        </div>
      </header>

      <!-- Profile Modal -->
      <Profile :show="showProfileModal" @close="showProfileModal = false" />

      <!-- Add Patient Modal -->
      <AddPatient :show="showAddPatientModal" @close="showAddPatientModal = false" @add-patient="handleAddPatient" />

      <!-- View Patient Modal -->
      <ViewPatient 
        :show="showViewPatientModal" 
        :patient="selectedPatient" 
        @close="showViewPatientModal = false" 
        @update-patient="handleUpdatePatient"
        @validation-error="handleValidationError"
      />

      <!-- Error Notification -->
      <transition name="fade">
        <div v-if="error" class="error-notification">
          <div class="error-content">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/>
              <path d="M12 8V12" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
              <circle cx="12" cy="16" r="1" fill="currentColor"/>
            </svg>
            <span>{{ error }}</span>
          </div>
          <button @click="error = null" class="error-close">✕</button>
        </div>
      </transition>

      <!-- Patient Record Content -->
      <div class="page-content">
        <!-- Page Header with Title, Filters, and Actions -->
        <div class="page-header-section">
          <div class="title-and-filters">
            <h2 class="page-title">Patients</h2>
            <div class="filter-chips" role="toolbar" aria-label="Patient filters">
              <button 
                :class="['filter-chip', { active: activeFilter === 'all' }]"
                @click="activeFilter = 'all'"
                aria-label="Show all patients"
              >
                All
              </button>
              <button 
                :class="['filter-chip', { active: activeFilter === 'student' }]"
                @click="activeFilter = 'student'"
                aria-label="Show students only"
              >
                Student
              </button>
              <button 
                :class="['filter-chip', { active: activeFilter === 'faculty' }]"
                @click="activeFilter = 'faculty'"
                aria-label="Show faculty only"
              >
                Faculty
              </button>
              <button 
                :class="['filter-chip', { active: activeFilter === 'staff' }]"
                @click="activeFilter = 'staff'"
                aria-label="Show staff only"
              >
                Staff
              </button>
            </div>
          </div>

          <div class="header-actions">
            <div class="search-control-inline">
              <i class="search-icon-inline">🔍</i>
              <input type="text" v-model="tableSearch" placeholder="Search patients..." aria-label="Search patients" />
            </div>
            <button class="add-patient-btn" @click="addPatient">
              + Add Patient
            </button>
          </div>
        </div>

        <!-- Table Section -->
        <div class="table-container">
          <div class="table-controls">
            <div class="entries-control">
              <input type="checkbox" id="entries-checkbox" />
              <label for="entries-checkbox">Show entries</label>
            </div>
            <div class="results-info">
              Showing {{ filteredPatients.length }} patient{{ filteredPatients.length !== 1 ? 's' : '' }}
            </div>
          </div>

          <!-- Scrollable Table -->
          <div class="table-scroll">
            <table class="patients-table">
              <thead>
                <tr>
                  <th>School ID</th>
                  <th>Full Name</th>
                  <th>College Department</th>
                  <th>Program</th>
                  <th>Year & Section</th>
                  <th>Type</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="patient in filteredPatients" :key="patient.id">
                  <td>{{ patient.school_id }}</td>
                  <td class="name-cell">{{ patient.full_name }}</td>
                  <td>{{ patient.college_department || '-' }}</td>
                  <td>{{ patient.program || '-' }}</td>
                  <td>{{ patient.year_section || '-' }}</td>
                  <td>
                    <span :class="['type-badge', patient.type?.toLowerCase()]">
                      {{ patient.type }}
                    </span>
                  </td>
                  <td>
                    <button class="view-btn" @click="viewPatient(patient)" title="View Details">
                      👁️
                    </button>
                  </td>
                </tr>
                <tr v-if="isLoading">
                  <td colspan="7" class="loading-message">Loading patients...</td>
                </tr>
                <tr v-else-if="error">
                  <td colspan="7" class="error-message">{{ error }}</td>
                </tr>
                <tr v-else-if="filteredPatients.length === 0">
                  <td colspan="7" class="empty-message">No patients found</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '@/lib/Supabase.js'
import Profile from '../components/Profile.vue'
import AddPatient from '../components/AddPatient.vue'
import ViewPatient from '../components/ViewPatient.vue'

const router = useRouter()

// State variables
const showProfileModal = ref(false)
const showAddPatientModal = ref(false)
const showViewPatientModal = ref(false)
const selectedPatient = ref(null)
const patients = ref([])
const isLoading = ref(false)
const error = ref(null)
const globalSearch = ref('')
const tableSearch = ref('')
const activeFilter = ref('all')
const userName = ref('User')

// Fetch user data
const fetchUserData = async () => {
  try {
    const { data: { session }, error: sessionErr } = await supabase.auth.getSession()
    if (sessionErr) throw sessionErr
    
    if (session?.user) {
      const { data: profile } = await supabase
        .from('profiles')
        .select('full_name')
        .eq('id', session.user.id)
        .single()
        
      userName.value = profile?.full_name || session.user.email?.split('@')[0] || 'User'
    }
  } catch (err) {
    console.error('Error fetching user data:', err)
  }
}

// Fetch all patients
const fetchPatients = async () => {
  try {
    isLoading.value = true
    error.value = null
    
    const { data, error: err } = await supabase
      .from('patients')
      .select('*')
      .order('created_at', { ascending: false })
    
    if (err) throw err
    
    patients.value = data
  } catch (err) {
    console.error('Error fetching patients:', err)
    error.value = 'Failed to load patients'
  } finally {
    isLoading.value = false
  }
}

// Filter patients based on search and type filter
const filteredPatients = computed(() => {
  let filtered = patients.value

  // Apply type filter
  if (activeFilter.value !== 'all') {
    filtered = filtered.filter(p => p.type.toLowerCase() === activeFilter.value)
  }

  // Apply search filter
  if (tableSearch.value) {
    const searchLower = tableSearch.value.toLowerCase()
    filtered = filtered.filter(p => 
      p.full_name.toLowerCase().includes(searchLower) ||
      p.school_id.toLowerCase().includes(searchLower) ||
      p.email.toLowerCase().includes(searchLower)
    )
  }

  return filtered
})

// Add new patient
const handleAddPatient = async (patientData) => {
  try {
    isLoading.value = true
    error.value = null

    // Get current user's ID
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) throw new Error('No authenticated user')

    // Insert new patient with correct field mapping
    const newPatient = {
      school_id: patientData.idNumber,
      full_name: patientData.fullName,
      email: patientData.email,
      contact_number: patientData.contactNumber,
      college_department: patientData.department,
      program: patientData.program,
      year_section: patientData.yearSection,
      sex: patientData.sex,
      type: patientData.type,
      created_by: user.id,
      created_at: new Date().toISOString()
    }

    const { data, error: err } = await supabase
      .from('patients')
      .insert([newPatient])
      .select()
      .single()

    if (err) {
      console.error('Supabase error:', err)
      throw err
    }

    console.log('New patient added:', data)
    patients.value = [data, ...(patients.value || [])]
    showAddPatientModal.value = false
    
    // Clear any error messages on success
    error.value = null

  } catch (err) {
    console.error('Error adding patient:', err)
    error.value = `Failed to add patient: ${err.message}`
  } finally {
    isLoading.value = false
  }
}

// View patient details
const viewPatient = async (patient) => {
  try {
    isLoading.value = true
    error.value = null

    console.log('Fetching patient details for:', patient)

    // Fetch full patient details including any related data
    const { data, error: err } = await supabase
      .from('patients')
      .select('*')
      .eq('id', patient.id)
      .single()

    if (err) throw err

    console.log('Patient data fetched:', data)
    selectedPatient.value = data
    showViewPatientModal.value = true

  } catch (err) {
    console.error('Error fetching patient details:', err)
    error.value = 'Failed to load patient details'
  } finally {
    isLoading.value = false
  }
}

// Update patient details
const handleUpdatePatient = async (updatedPatient) => {
  console.log('=== handleUpdatePatient CALLED ===')
  console.log('Received updatedPatient:', JSON.stringify(updatedPatient, null, 2))
  
  try {
    isLoading.value = true
    error.value = null

    console.log('📝 Updating patient with ID:', updatedPatient.id)

    // Prepare update payload
    const updatePayload = {
      full_name: updatedPatient.full_name,
      school_id: updatedPatient.school_id,
      email: updatedPatient.email,
      contact_number: updatedPatient.contact_number,
      college_department: updatedPatient.college_department,
      program: updatedPatient.program,
      year_section: updatedPatient.year_section,
      sex: updatedPatient.sex,
      type: updatedPatient.type,
      updated_at: new Date().toISOString()
    }

    console.log('📤 Update payload:', updatePayload)

    // First, update the patient record
    const { error: updateError } = await supabase
      .from('patients')
      .update(updatePayload)
      .eq('id', updatedPatient.id)

    if (updateError) {
      console.error('❌ Update error:', updateError)
      throw updateError
    }

    console.log('✅ Update successful, fetching updated data...')

    // Then fetch the updated patient data
    let { data, error: fetchError } = await supabase
      .from('patients')
      .select('*')
      .eq('id', updatedPatient.id)
      .single()

    if (fetchError) {
      console.error('❌ Fetch error:', fetchError)
      throw fetchError
    }

    console.log('✅ Patient data fetched:', data)

    // Verify that fetched data matches the submitted payload
    const fieldsToCheck = ['full_name','school_id','email','contact_number','college_department','program','year_section','sex','type']
    const mismatches = []
    for (const f of fieldsToCheck) {
      const submitted = (updatePayload)[f] ?? null
      const returned = (data)[f] ?? null
      // Normalize strings for comparison
      const s = typeof submitted === 'string' ? submitted.trim() : submitted
      const r = typeof returned === 'string' ? returned.trim() : returned
      if (s !== r) mismatches.push({ field: f, submitted: s, returned: r })
    }

    if (mismatches.length) {
      console.warn('⚠️ Mismatched fields after update:', mismatches)
      console.table(mismatches)
      // Try to perform an update that returns the row (select) and capture response
      try {
        const { data: returnedRows, error: retryError } = await supabase
          .from('patients')
          .update(updatePayload)
          .eq('id', updatedPatient.id)
          .select()

        if (retryError) {
          console.error('Retry update error:', retryError)
          throw retryError
        }

        console.log('Raw retry response - returnedRows:', returnedRows)
        
        // returnedRows may be an array — pick first
        const returned = Array.isArray(returnedRows) ? returnedRows[0] : returnedRows
        console.log('Retry returned row:', returned)
        
        if (!returned || !returnedRows || (Array.isArray(returnedRows) && returnedRows.length === 0)) {
          console.error('❌ UPDATE DID NOT RETURN ANY ROWS - This means RLS is blocking the update!')
          error.value = 'Update blocked by database security policy (RLS). The update was rejected.'
          throw new Error('RLS policy blocked the update')
        }

        // Use returned data if valid
        if (returned) data = returned
      } catch (retryErr) {
        console.error('Retry failed:', retryErr)
        error.value = 'Update appears to have not persisted. Check Supabase RLS and try again.'
      }
    }

    // Update local patients array
    const index = patients.value.findIndex(p => p.id === updatedPatient.id)
    console.log('📊 Updating local array at index:', index)
    
    if (index !== -1) {
      patients.value[index] = data
      console.log('✅ Local array updated')
    }

    // Update selectedPatient to reflect changes in the modal
    selectedPatient.value = data
    console.log('✅ selectedPatient updated')

    // Refresh whole list to ensure UI consistency
    try {
      await fetchPatients()
      console.log('✅ Refreshed patients list')
    } catch (refreshErr) {
      console.warn('Failed to refresh patient list after update:', refreshErr)
    }

    showViewPatientModal.value = false
    console.log('✅ Modal closed')

  } catch (err) {
    console.error('❌ Error updating patient:', err)
    console.error('Error details:', {
      message: err.message,
      code: err.code,
      details: err.details,
      hint: err.hint
    })
    error.value = `Failed to update patient: ${err.message}`
  } finally {
    isLoading.value = false
    console.log('=== handleUpdatePatient FINISHED ===')
  }
}

// Handle validation errors from modals
const handleValidationError = (errorMessage) => {
  error.value = errorMessage
  setTimeout(() => {
    error.value = null
  }, 5000)
}

// Helper functions
const addPatient = () => {
  showAddPatientModal.value = true
}

// Initialize
// Check authentication on mount
onMounted(async () => {
  const isDemoMode = sessionStorage.getItem('uic_demo_mode') === '1'
  const { data: { session } } = await supabase.auth.getSession()
  if (!session && !isDemoMode) {
    router.push('/login')
    return
  }
  await fetchUserData()
  fetchPatients()
})



</script>


<style scoped>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

.dashboard-container {
  display: flex;
  min-height: 100vh;
  background: #f5f7fa;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

/* Error Notification */
.error-notification {
  position: fixed;
  top: 80px;
  right: 20px;
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
  padding: 16px 20px;
  border-radius: 12px;
  box-shadow: 0 8px 24px rgba(239, 68, 68, 0.4);
  z-index: 9998;
  display: flex;
  align-items: center;
  gap: 12px;
  max-width: 400px;
  animation: slideInRight 0.3s ease;
}

@keyframes slideInRight {
  from {
    opacity: 0;
    transform: translateX(100px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.error-content {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
}

.error-content svg {
  flex-shrink: 0;
}

.error-close {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  color: white;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  transition: background 0.2s ease;
  flex-shrink: 0;
}

.error-close:hover {
  background: rgba(255, 255, 255, 0.3);
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* Sidebar Styles (reused from Dashboard) */
.sidebar {
  width: 266px;
  background: linear-gradient(180deg, #ec4899 0%, #d946ef 100%);
  color: white;
  display: flex;
  flex-direction: column;
  box-shadow: 4px 0 10px rgba(0, 0, 0, 0.1);
  position: fixed;
  height: 100vh;
  overflow-y: auto;
}

.sidebar-header {
  display: flex;
  align-items: center;
  padding: 16px 16px;
  gap: 10px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.sidebar-logo {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: white;
  padding: 5px;
  object-fit: contain;
}

.sidebar-title {
  font-size: 20px;
  font-weight: bold;
  letter-spacing: 0.5px;
}

.sidebar-nav {
  display: flex;
  flex-direction: column;
  padding: 12px 0;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 20px;
  color: white;
  text-decoration: none;
  transition: all 0.3s ease;
  font-size: 14px;
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
  width: 24px;
  text-align: center;
}

/* Main Content */
.main-content {
  flex: 1;
  margin-left: 266px;
  display: flex;
  flex-direction: column;
  height: 100vh;
  overflow: hidden;
}

/* Header */
.header {
  background: white;
  padding: 12px 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  z-index: 100;
}

.search-bar {
  display: flex;
  align-items: center;
  background: #f0f0f0;
  padding: 8px 14px;
  border-radius: 8px;
  width: 400px;
  gap: 10px;
}

.search-icon {
  font-size: 16px;
  color: #666;
}

.search-bar input {
  border: none;
  background: none;
  outline: none;
  font-size: 14px;
  flex: 1;
  color: #333;
}

.search-bar input::placeholder {
  color: #999;
}

.user-profile {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  gap: 12px;
  margin-left: auto; /* push user profile to the right side of the header */
}

.user-avatar {
  width: 38px;
  height: 38px;
  border-radius: 50%;
  border: 2px solid #ec4899;
  object-fit: cover;
}

.user-greeting {
  font-size: 14px;
  color: #333;
}

.user-greeting strong {
  color: #ec4899;
  font-weight: 600;
}

/* Page Content */
.page-content {
  flex: 1;
  padding: 20px 24px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* Page Header Section */
.page-header-section {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 20px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.title-and-filters {
  display: flex;
  flex-direction: column;
  gap: 12px;
  flex: 1;
  min-width: 250px;
}

.page-title {
  font-size: 28px;
  color: #1e293b;
  font-weight: 700;
  margin: 0;
  letter-spacing: -0.5px;
}

.filter-chips {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.filter-chip {
  padding: 8px 16px;
  border: none;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  background: #f1f5f9;
  color: #64748b;
}

.filter-chip:hover {
  background: #e2e8f0;
  color: #475569;
  transform: translateY(-1px);
}

.filter-chip.active {
  background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
}

.header-actions {
  display: flex;
  gap: 12px;
  align-items: center;
}

.search-control-inline {
  display: flex;
  align-items: center;
  background: white;
  padding: 8px 14px;
  border-radius: 10px;
  border: 2px solid #e5e7eb;
  gap: 8px;
  min-width: 250px;
  transition: all 0.2s ease;
}

.search-control-inline:focus-within {
  border-color: #6366f1;
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
}

.search-icon-inline {
  font-size: 16px;
  color: #9ca3af;
}

.search-control-inline input {
  border: none;
  background: none;
  outline: none;
  font-size: 14px;
  flex: 1;
  color: #1f2937;
}

.search-control-inline input::placeholder {
  color: #9ca3af;
}

.add-patient-btn {
  padding: 10px 24px;
  background: linear-gradient(135deg, #ec4899 0%, #db2777 100%);
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(236, 72, 153, 0.3);
  white-space: nowrap;
}

.add-patient-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(236, 72, 153, 0.4);
}

/* Table Container */
.table-container {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  display: flex;
  flex-direction: column;
  flex: 1;
  overflow: hidden;
}

.table-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid #e5e7eb;
}

.entries-control {
  display: flex;
  align-items: center;
  gap: 8px;
}

.entries-control input[type="checkbox"] {
  width: 16px;
  height: 16px;
  cursor: pointer;
}

.entries-control label {
  font-size: 13px;
  color: #64748b;
  cursor: pointer;
  font-weight: 500;
}

.results-info {
  font-size: 13px;
  color: #64748b;
  font-weight: 500;
}

.search-control {
  display: flex;
  align-items: center;
  gap: 10px;
}

.search-control label {
  font-size: 14px;
  color: #6b7280;
}

.search-control input {
  padding: 6px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 13px;
  width: 200px;
}

.search-control input:focus {
  outline: none;
  border-color: #6366f1;
}

/* Scrollable Table */
.table-scroll {
  flex: 1;
  overflow-y: auto;
  overflow-x: auto;
}

.patients-table {
  width: 100%;
  border-collapse: collapse;
}

.patients-table thead {
  position: sticky;
  top: 0;
  background: #f9fafb;
  z-index: 10;
}

.patients-table th {
  padding: 12px 16px;
  text-align: left;
  font-size: 12px;
  font-weight: 600;
  color: #374151;
  text-transform: uppercase;
  border-bottom: 2px solid #e5e7eb;
}

.patients-table tbody tr {
  transition: background 0.2s ease;
}

.patients-table tbody tr:hover {
  background: #f9fafb;
}

.patients-table tbody tr:nth-child(even) {
  background: #fafafa;
}

.patients-table tbody tr:nth-child(even):hover {
  background: #f3f4f6;
}

.patients-table td {
  padding: 14px 16px;
  font-size: 13px;
  color: #4b5563;
  border-bottom: 1px solid #e5e7eb;
}

.name-cell {
  font-weight: 500;
  color: #1f2937;
}

/* Status Badge */
.status-badge {
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  display: inline-block;
}

.status-badge.active {
  background: #10b981;
  color: white;
}

.status-badge.inactive {
  background: #ef4444;
  color: white;
}

/* View Button */
.view-btn {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  padding: 4px 8px;
  transition: transform 0.2s ease;
}

.view-btn:hover {
  transform: scale(1.2);
}

/* Responsive Design */
@media (max-width: 1200px) {
  .sidebar {
    width: 220px;
  }
  
  .main-content {
    margin-left: 220px;
  }

  .search-control-inline {
    min-width: 200px;
  }
}

@media (max-width: 968px) {
  .sidebar {
    width: 70px;
  }
  
  .main-content {
    margin-left: 70px;
  }
  
  .sidebar-title,
  .nav-item span {
    display: none;
  }
  
  .search-bar {
    width: 250px;
  }
  
  .user-greeting {
    display: none;
  }

  .page-header-section {
    flex-direction: column;
    align-items: stretch;
  }

  .header-actions {
    width: 100%;
    flex-direction: column;
  }

  .search-control-inline {
    width: 100%;
  }

  .add-patient-btn {
    width: 100%;
  }

  .filter-chips {
    overflow-x: auto;
    flex-wrap: nowrap;
    padding-bottom: 6px;
  }
}
</style>
