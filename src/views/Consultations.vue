<template>
  <div class="consultations-container">
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
        <router-link to="/patient-record" class="nav-item">
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
              <rect x="3" y="3" width="10" height="6" rx="3" transform="rotate(45 3 3)" fill="currentColor" />
            </svg>
          </i>
          <span>Medicine</span>
        </router-link>
        <router-link to="/consultations" class="nav-item active">
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
              <path d="M3 19C3 16.7909 4.79086 15 7 15H9C11.2091 15 13 16.7909 13 19" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" />
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
      <Profile 
        :show="showProfileModal" 
        @close="showProfileModal = false"
        @update:userName="updateUserName" />

      <!-- Notification Modal -->
      <NotificationModal 
        :show="showNotification" 
        :message="notificationMessage" 
        :type="notificationType"
        @close="showNotification = false" />

      <!-- Consultations Content -->
      <div class="consultations-content">
        <!-- Add Consultation Section -->
        <div class="add-consultation-section">
          <div class="section-header">
            <div class="header-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M12 4.5v15m7.5-7.5h-15" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
              </svg>
            </div>
            <h2 class="section-title">Add Consultation</h2>
          </div>
          
          <form @submit.prevent="handleAddConsultation" class="consultation-form">
            <!-- Patient and Medicine Search Row -->
            <div class="search-row">
              <div class="form-group search-field">
                <label class="field-label">
                  <span class="label-icon">👤</span>
                  Search by Name  <span class="required-mark">*</span>
                </label>
                <div class="input-wrapper">
                  <input 
                    v-model="newConsultation.searchPatient"
                    @input="searchPatients"
                    @focus="isPatientSearchFocused = true"
                    @blur="handlePatientSearchBlur"
                    type="text" 
                    placeholder="Type patient name or ID number..."
                    autocomplete="off"
                    class="search-input"
                    :class="{ 'has-selection': newConsultation.student_id }"
                  />
                  <div class="search-icon-container">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <circle cx="11" cy="11" r="8" stroke="currentColor" stroke-width="2"/>
                      <path d="M21 21l-4.35-4.35" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                    </svg>
                  </div>
                </div>
                <!-- Patient Dropdown -->
                <transition name="dropdown-fade">
                  <div v-if="(patientResults.length > 0 || (isSearchingPatients === false && newConsultation.searchPatient.trim().length > 0 && patientResults.length === 0)) && isPatientSearchFocused" class="dropdown-menu patient-dropdown">
                    <div class="dropdown-header" v-if="patientResults.length > 0">
                      <span>{{ patientResults.length }} patient(s) found</span>
                    </div>
                    <div class="dropdown-list" v-if="patientResults.length > 0">
                      <div 
                        v-for="patient in patientResults" 
                        :key="patient.id"
                        @mousedown="selectPatient(patient)"
                        class="dropdown-item patient-item"
                      >
                        <div class="item-icon">👤</div>
                        <div class="item-details">
                          <div class="item-name">{{ patient.full_name }}</div>
                          <div class="item-meta">ID: {{ patient.school_id }} • {{ patient.role }}</div>
                        </div>
                      </div>
                    </div>
                    <div v-else class="dropdown-empty">
                      <div class="empty-icon">🔍</div>
                      <div class="empty-text">No existing patient found</div>
                      <div class="empty-hint">You can still add consultation for this name</div>
                      <button 
                        type="button"
                        @mousedown="useCustomPatientName"
                        class="use-name-btn"
                      >
                        ✓ Use "{{ newConsultation.searchPatient }}" anyway
                      </button>
                    </div>
                  </div>
                </transition>
                <div v-if="isSearchingPatients" class="search-loader">
                  <div class="mini-spinner"></div>
                  Searching patients...
                </div>
              </div>

              <div class="form-group search-field">
                <label class="field-label">
                  <span class="label-icon">💊</span>
                  Search Medicine
                </label>
                <div class="input-wrapper">
                  <input 
                    v-model="newConsultation.searchMedicine"
                    @input="searchMedicines"
                    @focus="isMedicineSearchFocused = true"
                    @blur="handleMedicineSearchBlur"
                    type="text" 
                    placeholder="Type medicine name..."
                    autocomplete="off"
                    class="search-input"
                    :class="{ 'has-selection': newConsultation.prescription }"
                  />
                  <div class="search-icon-container">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <circle cx="11" cy="11" r="8" stroke="currentColor" stroke-width="2"/>
                      <path d="M21 21l-4.35-4.35" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                    </svg>
                  </div>
                </div>
                <!-- Medicine Dropdown -->
                <transition name="dropdown-fade">
                  <div v-if="(medicineResults.length > 0 || (isSearchingMedicines === false && newConsultation.searchMedicine.trim().length > 0 && medicineResults.length === 0)) && isMedicineSearchFocused" class="dropdown-menu medicine-dropdown">
                    <div class="dropdown-header" v-if="medicineResults.length > 0">
                      <span>{{ medicineResults.length }} medicine(s) available</span>
                    </div>
                    <div class="dropdown-list" v-if="medicineResults.length > 0">
                      <div 
                        v-for="medicine in medicineResults" 
                        :key="medicine.id"
                        @mousedown="selectMedicine(medicine)"
                        class="dropdown-item medicine-item"
                      >
                        <div class="item-icon">💊</div>
                        <div class="item-details">
                          <div class="item-name">{{ medicine.medicine_name }}</div>
                          <div class="item-meta" v-if="medicine.stock_quantity !== undefined">
                            Stock: {{ medicine.stock_quantity }} {{ medicine.unit || 'pcs' }}
                          </div>
                        </div>
                      </div>
                    </div>
                    <div v-else class="dropdown-empty">
                      <div class="empty-icon">🔍</div>
                      <div class="empty-text">No medicines found</div>
                      <div class="empty-hint">Try searching by medicine name</div>
                    </div>
                  </div>
                </transition>
                <div v-if="isSearchingMedicines" class="search-loader">
                  <div class="mini-spinner"></div>
                  Searching medicines...
                </div>
              </div>

              <div class="form-group compact-field">
                <label class="field-label">
                  <span class="label-icon">🔢</span>
                  Quantity
                </label>
                <input 
                  v-model.number="newConsultation.quantity"
                  type="number" 
                  placeholder="0"
                  min="1"
                  class="number-input"
                />
              </div>
            </div>

            <!-- Diagnosis Row -->
            <div class="full-row">
              <div class="form-group">
                <label class="field-label">
                  <span class="label-icon">📋</span>
                  Diagnosis <span class="required-mark">*</span>
                </label>
                <textarea 
                  v-model="newConsultation.diagnosis"
                  placeholder="Type the diagnosis (e.g., Hypertension, Common Cold, etc.)"
                  rows="3"
                  required
                  class="textarea-input"
                ></textarea>
              </div>
            </div>

            <!-- Notes and Remarks Row -->
            <div class="notes-row">
              <div class="form-group">
                <label class="field-label">
                  <span class="label-icon">📝</span>
                  Notes
                </label>
                <textarea 
                  v-model="newConsultation.notes"
                  placeholder="Enter any notes regarding the treatment (optional)"
                  rows="3"
                  class="textarea-input"
                ></textarea>
              </div>

              <div class="form-group">
                <label class="field-label">
                  <span class="label-icon">⚠️</span>
                  Remarks
                </label>
                <textarea 
                  v-model="newConsultation.remarks"
                  placeholder="Enter any important remarks (e.g., follow-up needed)"
                  rows="3"
                  class="textarea-input"
                ></textarea>
              </div>
            </div>

            <div class="form-actions">
              <button type="button" @click="clearForm" class="btn-clear" :disabled="isSaving">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M3 6h18M8 6V4a2 2 0 012-2h4a2 2 0 012 2v2m3 0v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6h14z" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                </svg>
                Clear
              </button>
              <button type="submit" class="btn-submit" :disabled="isSaving">
                <svg v-if="!isSaving" width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M5 13l4 4L19 7" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                <div v-else class="btn-spinner"></div>
                {{ isSaving ? 'Submitting...' : 'Submit' }}
              </button>
            </div>
          </form>
        </div>

        <div class="header-section">
           <h1 class="page-title">Consultations List</h1>

            <div class="search-box">
            <label>Search:</label>
            <input 
              v-model="searchQuery" 
              type="text" 
              placeholder="Search consultations..."
            />
          </div>
        </div>
       

        <!-- Controls -->
        <div class="controls-row">
          <!-- <div class="show-entries">
            <label>Show</label>
            <select v-model="entriesPerPage" @change="updatePagination">
              <option :value="10">10</option>
              <option :value="25">25</option>
              <option :value="50">50</option>
              <option :value="100">100</option>
            </select>
            <label>entries</label>
          </div> -->

        
        </div>

        <!-- Table -->
        <div class="table-container">
          <table class="consultations-table">
            <thead>
              <tr>
                <th @click="sortBy('name')">
                  NAME: 
                  <span class="sort-icon">{{ getSortIcon('name') }}</span>
                </th>
                <th @click="sortBy('diagnosis')">
                  DIAGNOSIS 
                  <span class="sort-icon">{{ getSortIcon('diagnosis') }}</span>
                </th>
                <th @click="sortBy('prescribed_medicine')">
                  PRESCRIBED MEDICINE: 
                  <span class="sort-icon">{{ getSortIcon('prescribed_medicine') }}</span>
                </th>
                <th @click="sortBy('quantity')">
                  QUANTITY: 
                  <span class="sort-icon">{{ getSortIcon('quantity') }}</span>
                </th>
                <th @click="sortBy('notes')">
                  NOTES: 
                  <span class="sort-icon">{{ getSortIcon('notes') }}</span>
                </th>
                <th @click="sortBy('remark')">
                  REMARK 
                  <span class="sort-icon">{{ getSortIcon('remark') }}</span>
                </th>
                <th @click="sortBy('date')">
                  DATE 
                  <span class="sort-icon">{{ getSortIcon('date') }}</span>
                </th>
                <th>ACTION</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="loading">
                <td colspan="8" class="loading-cell">
                  <div class="spinner"></div>
                  Loading consultations...
                </td>
              </tr>
              <tr v-else-if="paginatedConsultations.length === 0">
                <td colspan="8" class="empty-cell">No consultations found</td>
              </tr>
              <tr v-else v-for="consultation in paginatedConsultations" :key="consultation.id">
                <td>{{ consultation.patient_name }}</td>
                <td>{{ consultation.diagnosis || 'N/A' }}</td>
                <td>{{ consultation.prescription || 'N/A' }}</td>
                <td>{{ consultation.quantity || '-' }}</td>
                <td>{{ consultation.notes || '-' }}</td>
                <td>{{ consultation.treatment || '-' }}</td>
                <td>{{ formatDate(consultation.consultation_date) }}</td>
                <td>
                  <button @click="viewConsultation(consultation)" class="action-btn view-btn" title="View">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M15 12C15 13.6569 13.6569 15 12 15C10.3431 15 9 13.6569 9 12C9 10.3431 10.3431 9 12 9C13.6569 9 15 10.3431 15 12Z" stroke="currentColor" stroke-width="2"/>
                      <path d="M12 5C7 5 2.73 8.11 1 12.5C2.73 16.89 7 20 12 20C17 20 21.27 16.89 23 12.5C21.27 8.11 17 5 12 5Z" stroke="currentColor" stroke-width="2"/>
                    </svg>
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Pagination Info -->
        <div class="pagination-info">
          <p>Showing {{ startEntry }} to {{ endEntry }} of {{ filteredConsultations.length }} entries</p>
        </div>
      </div>
    </main>

    <!-- View Consultation Modal -->
    <ViewConsultation
      :show="showViewModal"
      :consultation="selectedConsultation"
      @close="showViewModal = false"
    />
  </div>
</template>

<script>
import { supabase } from '@/lib/Supabase.js'
import Profile from '../components/Profile.vue'
import ViewConsultation from '../components/ViewConsultation.vue'
import NotificationModal from '../components/NotificationModal.vue'
import EditConsultation from '../components/EditConsultation.vue'


export default {
  name: 'ConsultationsPage',
  components: {
    Profile,
    ViewConsultation,
    EditConsultation,
    NotificationModal
  },
  data() {
    return {
      consultations: [],
      loading: false,
      showProfileModal: false,
      showViewModal: false,
      selectedConsultation: null,
      userName: 'User',
      searchQuery: '',
      showNotification: false,
      showEditModal: false,
      notificationMessage: '',
      notificationType: 'info',
      entriesPerPage: 10,
      currentPage: 1,
      sortColumn: 'date',
      sortDirection: 'desc',
      isSaving: false,
      newConsultation: {
        searchPatient: '',
        student_id: null,
        selectedPatientData: null,
        customPatientName: null,
        diagnosis: '',
        searchMedicine: '',
        prescription: '',
        selectedMedicineData: null,
        quantity: null,
        notes: '',
        remarks: ''
      },
      patientResults: [],
      medicineResults: [],
      searchTimeout: null,
      isPatientSearchFocused: false,
      isMedicineSearchFocused: false,
      isSearchingPatients: false,
      isSearchingMedicines: false,
      
      
    }
  },
  async created() {
    console.log('🚀 Consultations component created')
    console.log('📡 Supabase client:', supabase ? 'initialized' : 'NOT initialized')
    
    // Test database connectivity
    try {
      console.log('🧪 Testing database connectivity...')
      
      // Test patients table
      const { data: patientsTest, error: patientsError } = await supabase
        .from('patients')
        .select('*')
        .limit(5)
      
      console.log('👥 Patients table test:', {
        success: !patientsError,
        count: patientsTest?.length || 0,
        sample: patientsTest?.[0] || 'No data',
        error: patientsError
      })
      
      // Test medicine table
      const { data: medicineTest, error: medicineError } = await supabase
        .from('medicine')
        .select('*')
        .limit(5)
      
      console.log('💊 Medicine table test:', {
        success: !medicineError,
        count: medicineTest?.length || 0,
        sample: medicineTest?.[0] || 'No data',
        error: medicineError
      })
      
    } catch (err) {
      console.error('❌ Database connectivity test failed:', err)
    }
    
    await this.fetchUserData()
    await this.fetchConsultations()
  },
  computed: {
    filteredConsultations() {
      let filtered = this.consultations

      if (this.searchQuery) {
        const query = this.searchQuery.toLowerCase()
        filtered = filtered.filter(c => 
          c.patient_name?.toLowerCase().includes(query) ||
          c.diagnosis?.toLowerCase().includes(query) ||
          c.prescription?.toLowerCase().includes(query) ||
          c.notes?.toLowerCase().includes(query) ||
          c.treatment?.toLowerCase().includes(query)
        )
      }

      // Sort
      return filtered.sort((a, b) => {
        let aVal = a[this.sortColumn]
        let bVal = b[this.sortColumn]

        if (this.sortColumn === 'date') {
          aVal = new Date(a.consultation_date)
          bVal = new Date(b.consultation_date)
        }

        if (aVal === null || aVal === undefined) return 1
        if (bVal === null || bVal === undefined) return -1

        if (this.sortDirection === 'asc') {
          return aVal > bVal ? 1 : -1
        } else {
          return aVal < bVal ? 1 : -1
        }
      })
    },
    paginatedConsultations() {
      const start = (this.currentPage - 1) * this.entriesPerPage
      const end = start + this.entriesPerPage
      return this.filteredConsultations.slice(start, end)
    },
    startEntry() {
      return this.filteredConsultations.length === 0 ? 0 : (this.currentPage - 1) * this.entriesPerPage + 1
    },
    endEntry() {
      const end = this.currentPage * this.entriesPerPage
      return end > this.filteredConsultations.length ? this.filteredConsultations.length : end
    }
  },



  methods: {
    async fetchUserData() {
      try {
        const { data: { session }, error: sessionErr } = await supabase.auth.getSession()
        if (sessionErr) throw sessionErr
        
        if (session?.user) {
          const { data: profile } = await supabase
            .from('profiles')
            .select('full_name')
            .eq('id', session.user.id)
            .single()
            
          this.userName = profile?.full_name || session.user.email?.split('@')[0] || 'User'
        }
      } catch (err) {
        console.error('Error fetching user data:', err)
      }
    },
    
    async fetchConsultations() {
      try {
        this.loading = true
        
        // Fetch consultations
        const { data: consultationsData, error } = await supabase
          .from('consultations')
          .select('*')
          .order('consultation_date', { ascending: false })
        
        if (error) throw error
        
        // Fetch patient names from patients table for each consultation
        const consultationsWithPatients = await Promise.all(
          consultationsData.map(async (consultation) => {
            if (consultation.student_id) {
              const { data: patientData } = await supabase
                .from('patients')
                .select('full_name')
                .eq('id', consultation.student_id)
                .single()
              
              return {
                ...consultation,
                patient_name: patientData?.full_name || 'Unknown Patient',
                quantity: null
              }
            }
            return {
              ...consultation,
              patient_name: 'Unknown Patient',
              quantity: null
            }
          })
        )
        
        this.consultations = consultationsWithPatients
        
      } catch (err) {
        console.error('Error fetching consultations:', err)
      } finally {
        this.loading = false
      }
    },
    
    formatDate(dateString) {
      if (!dateString) return 'N/A'
      const date = new Date(dateString)
      return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit'
      })
    },
    
    sortBy(column) {
      if (this.sortColumn === column) {
        this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc'
      } else {
        this.sortColumn = column
        this.sortDirection = 'asc'
      }
    },
    
    getSortIcon(column) {
      if (this.sortColumn !== column) return '↕'
      return this.sortDirection === 'asc' ? '↑' : '↓'
    },
    
    updatePagination() {
      this.currentPage = 1
    },
    
    viewConsultation(consultation) {
      this.selectedConsultation = consultation
      this.showViewModal = true
    },
    
    updateUserName(newName) {
      this.userName = newName
    },

    editConsultation(consultation) {
  this.selectedConsultation = consultation
  this.showEditModal = true
},

handleConsultationUpdated(updatedConsultation) {
  const index = this.consultations.findIndex(c => c.id === updatedConsultation.id)
  if (index !== -1) {
    this.consultations[index] = { ...this.consultations[index], ...updatedConsultation }
  }
  this.showNotificationModal('Consultation updated successfully!', 'success')
},
    
    // Patient search with instant recommendations - searches from patients table
    // Shows recommendations from first letter typed
    searchPatients() {
      clearTimeout(this.searchTimeout)
      
      // Clear results if search is empty
      if (!this.newConsultation.searchPatient || this.newConsultation.searchPatient.trim().length < 1) {
        this.patientResults = []
        this.isSearchingPatients = false
        return
      }
      
      this.isSearchingPatients = true
      
      // Faster response time - 150ms debounce
      this.searchTimeout = setTimeout(async () => {
        try {
          const query = this.newConsultation.searchPatient.trim()
          console.log('🔍 Searching patients with query:', query)
          
          // Search in patients table by FULL_NAME column
          const { data, error } = await supabase
            .from('patients')
            .select('*')
            .ilike('full_name', `%${query}%`)
            .order('full_name')
            .limit(15)
          
          if (error) {
            console.error('❌ Supabase error:', error)
            throw error
          }
          
          console.log('✅ Raw patient data:', data)
          console.log('📊 Number of patients found:', data?.length || 0)
          
          if (data && data.length > 0) {
            console.log('📋 First patient structure:', data[0])
          }
          
          // Map to consistent format
          this.patientResults = (data || []).map(patient => ({
            id: patient.id,
            full_name: patient.full_name,
            school_id: patient.school_id,
            role: patient.type || patient.role || 'Student',
            date_of_birth: patient.date_of_birth || patient.birthdate,
            address: patient.address
          }))
          
          console.log('📝 Mapped patient results:', this.patientResults)
          
          // If no results found, show helpful message
          if (this.patientResults.length === 0) {
            console.log('⚠️ No patients found for query:', query)
          }
        } catch (err) {
          console.error('❌ Error searching patients:', err)
          console.error('Error message:', err.message)
          this.patientResults = []
        } finally {
          this.isSearchingPatients = false
        }
      }, 150)
    },
    
    selectPatient(patient) {
      this.newConsultation.student_id = patient.id
      this.newConsultation.searchPatient = `${patient.full_name} (${patient.school_id})`
      this.newConsultation.selectedPatientData = patient
      this.newConsultation.customPatientName = null // Clear custom name if selecting from DB
      this.patientResults = []
      this.isPatientSearchFocused = false
    },
    
    useCustomPatientName() {
      // Allow using a custom patient name that doesn't exist in the database
      const customName = this.newConsultation.searchPatient.trim()
      if (customName) {
        this.newConsultation.student_id = null // No existing patient ID
        this.newConsultation.customPatientName = customName
        this.newConsultation.selectedPatientData = {
          full_name: customName,
          school_id: 'N/A',
          role: 'Unknown'
        }
        console.log('✅ Using custom patient name:', customName)
        this.isPatientSearchFocused = false
        this.patientResults = []
      }
    },
    
    handlePatientSearchBlur() {
      setTimeout(() => {
        this.isPatientSearchFocused = false
      }, 200)
    },
    
    // Medicine search with instant recommendations - searches from medicine table
    // Shows recommendations from first letter typed
    searchMedicines() {
      clearTimeout(this.searchTimeout)
      
      // Clear results if search is empty
      if (!this.newConsultation.searchMedicine || this.newConsultation.searchMedicine.trim().length < 1) {
        this.medicineResults = []
        this.isSearchingMedicines = false
        return
      }
      
      this.isSearchingMedicines = true
      
      // Faster response time - 150ms debounce
      this.searchTimeout = setTimeout(async () => {
        try {
          const query = this.newConsultation.searchMedicine.trim()
          console.log('💊 Searching medicines with query:', query)
          
          // Search in medicine table by NAME column
          const { data, error } = await supabase
            .from('medicine')
            .select('*')
            .ilike('name', `%${query}%`)
            .order('name')
            .limit(15)
          
          if (error) {
            console.error('❌ Supabase error:', error)
            throw error
          }
          
          console.log('✅ Raw medicine data:', data)
          console.log('📊 Number of medicines found:', data?.length || 0)
          
          if (data && data.length > 0) {
            console.log('📋 First medicine structure:', data[0])
          }
          
          // Map to ensure consistent structure
          this.medicineResults = (data || []).map(medicine => ({
            id: medicine.id,
            medicine_name: medicine.name,
            stock_quantity: medicine.quantity || 0,
            unit: medicine.unit || 'pcs',
            category: medicine.category || 'General'
          }))
          
          console.log('📝 Mapped medicine results:', this.medicineResults)
          
          // If no results found, show helpful message
          if (this.medicineResults.length === 0) {
            console.log('⚠️ No medicines found for query:', query)
          }
        } catch (err) {
          console.error('❌ Error searching medicines:', err)
          console.error('Error message:', err.message)
          this.medicineResults = []
        } finally {
          this.isSearchingMedicines = false
        }
      }, 150)
    },
    
    selectMedicine(medicine) {
      this.newConsultation.prescription = medicine.medicine_name
      this.newConsultation.searchMedicine = medicine.medicine_name
      this.newConsultation.selectedMedicineData = medicine
      this.medicineResults = []
      this.isMedicineSearchFocused = false
    },
    
    handleMedicineSearchBlur() {
      setTimeout(() => {
        this.isMedicineSearchFocused = false
      }, 200)
    },
    
    async handleAddConsultation() {
      try {
        // Validation - require either existing patient or custom name
        if (!this.newConsultation.student_id && !this.newConsultation.customPatientName) {
          this.showNotificationModal('Please enter or select a patient name', 'warning')
          return
        }
        
        if (!this.newConsultation.diagnosis) {
          this.showNotificationModal('Please enter a diagnosis', 'warning')
          return
        }
        
        this.isSaving = true
        
        // Get current user as attended_by
        const { data: { session } } = await supabase.auth.getSession()
        
        let patientId = this.newConsultation.student_id
        let patientName = this.newConsultation.selectedPatientData?.full_name
        
        // If no existing patient (custom name), create a new patient record
        if (!patientId && this.newConsultation.customPatientName) {
          console.log('📝 Creating new patient record for:', this.newConsultation.customPatientName)
          
          const newPatientData = {
            full_name: this.newConsultation.customPatientName,
            school_id: `TEMP-${Date.now()}`, // Temporary ID
            email: 'N/A',
            contact_number: 'N/A',
            college_department: 'N/A',
            program: 'N/A',
            year_section: 'N/A',
            sex: 'Male', // Default
            type: 'Student', // Default
            created_by: session?.user?.id
          }
          
          const { data: newPatient, error: patientError } = await supabase
            .from('patients')
            .insert([newPatientData])
            .select()
            .single()
          
          if (patientError) {
            console.error('Error creating patient:', patientError)
            throw new Error('Failed to create patient record: ' + patientError.message)
          }
          
          patientId = newPatient.id
          patientName = newPatient.full_name
          console.log('✅ New patient created:', newPatient)
        }
        
        // Prepare consultation data
        const consultationData = {
          student_id: patientId,
          diagnosis: this.newConsultation.diagnosis,
          prescription: this.newConsultation.prescription || null,
          notes: this.newConsultation.notes || null,
          remarks: this.newConsultation.remarks || null,
          quantity: this.newConsultation.quantity || null,
          attended_by: session?.user?.id,
          attended_by_name: this.userName || null,
          status: 'Completed',
          consultation_date: new Date().toISOString()
        }
        
        console.log('Inserting consultation:', consultationData)
        
        const { data, error } = await supabase
          .from('consultations')
          .insert([consultationData])
          .select()
          .single()
        
        if (error) {
          console.error('Insert error:', error)
          throw error
        }
        
        console.log('Consultation inserted:', data)
        
        // Deduct medicine quantity from inventory if prescription was given
        if (this.newConsultation.selectedMedicineData && this.newConsultation.quantity > 0) {
          const medicineId = this.newConsultation.selectedMedicineData.id
          const dispensedQty = this.newConsultation.quantity
          
          console.log(`💊 Deducting ${dispensedQty} units from medicine ID ${medicineId}`)
          
          // Get current medicine quantity
          const { data: currentMedicine, error: fetchError } = await supabase
            .from('medicine')
            .select('quantity, name')
            .eq('id', medicineId)
            .single()
          
          if (fetchError) {
            console.error('Error fetching medicine:', fetchError)
          } else if (currentMedicine) {
            const newQuantity = currentMedicine.quantity - dispensedQty
            
            if (newQuantity < 0) {
              console.warn('⚠️ Warning: Medicine stock will be negative!')
              this.showNotificationModal(`Warning: ${currentMedicine.name} stock is insufficient (${currentMedicine.quantity} available, ${dispensedQty} dispensed)`, 'warning')
            }
            
            // Update medicine quantity
            const { error: updateError } = await supabase
              .from('medicine')
              .update({ quantity: Math.max(0, newQuantity) }) // Don't allow negative
              .eq('id', medicineId)
            
            if (updateError) {
              console.error('Error updating medicine stock:', updateError)
            } else {
              console.log(`✅ Medicine stock updated: ${currentMedicine.quantity} → ${newQuantity}`)
              
              // Create transaction record for inventory tracking
              const transactionData = {
                patient_id: patientId,
                consultation_id: data.id,
                medicine_id: medicineId,
                quantity: -dispensedQty, // Negative for dispensed
                type: 'Dispensed',
                description: `Dispensed ${dispensedQty} ${currentMedicine.name} during consultation`,
                notes: `Prescribed for: ${this.newConsultation.diagnosis}`,
                performed_by: session?.user?.id,
                performed_by_name: this.userName || null
              }
              
              const { error: txError } = await supabase
                .from('transactions')
                .insert([transactionData])
              
              if (txError) {
                console.error('Error creating transaction record:', txError)
              } else {
                console.log('✅ Transaction record created for medicine dispensing')
              }
            }
          }
        }
        
        // Add to consultations list with patient name
        const newConsultation = {
          ...data,
          patient_name: patientName || 'Unknown Patient',
          quantity: this.newConsultation.quantity
        }
        
        this.consultations.unshift(newConsultation)
        
        // Clear form
        this.clearForm()
        
        const stockMessage = this.newConsultation.selectedMedicineData && this.newConsultation.quantity > 0
          ? ` Medicine stock updated.`
          : ''
        this.showNotificationModal(`Consultation added successfully!${stockMessage}`, 'success')
        
      } catch (err) {
        console.error('Error adding consultation:', err)
        this.showNotificationModal('Failed to add consultation: ' + err.message, 'error')
      } finally {
        this.isSaving = false
      }
    },
    
    clearForm() {
      this.newConsultation = {
        searchPatient: '',
        student_id: null,
        selectedPatientData: null,
        customPatientName: null,
        diagnosis: '',
        searchMedicine: '',
        prescription: '',
        selectedMedicineData: null,
        quantity: null,
        notes: '',
        remarks: ''
      }
      this.patientResults = []
      this.medicineResults = []
      this.isPatientSearchFocused = false
      this.isMedicineSearchFocused = false
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
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

.consultations-container {
  display: flex;
  min-height: 100vh;
  background: #f5f7fa;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

/* Sidebar - Same as Dashboard */
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
}

.header {
  background: white;
  padding: 12px 24px;
  display: flex;
  justify-content: flex-end;
  align-items: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  position: sticky;
  top: 0;
  z-index: 100;
}

.user-profile {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-avatar {
  width: 38px;
  height: 38px;
  border-radius: 50%;
  border: 2px solid #ec4899;
  object-fit: cover;
}

.user-greeting {
  font-size: 16px;
  color: #333;
}

.user-greeting strong {
  color: #ec4899;
  font-weight: 600;
}

/* Content */
.consultations-content {
  padding: 24px 32px;
  flex: 1;
}

.page-title {
   font-size: 28px;
  color: #1e293b;
  font-weight: 700;
  margin: 0;
  letter-spacing: -0.5px;
}

/* Add Consultation Section */
.add-consultation-section {
  background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
  border-radius: 16px;
  padding: 0;
  margin-bottom: 32px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid #e5e7eb;
  overflow: hidden;
}

.section-header {
  background: linear-gradient(135deg, #ec4899 0%, #d946ef 100%);
  padding: 20px 32px;
  display: flex;
  align-items: center;
  gap: 12px;
  border-bottom: 3px solid rgba(255, 255, 255, 0.2);
}

.header-icon {
  width: 40px;
  height: 40px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.section-title {
  font-size: 24px;
  color: white;
  font-weight: 700;
  margin: 0;
  letter-spacing: -0.5px;
}

.consultation-form {
  padding: 32px;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.search-row {
  display: grid;
  grid-template-columns: 2fr 2fr 1fr;
  gap: 20px;
}

.full-row {
  display: grid;
  grid-template-columns: 1fr;
}

.notes-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 10px;
  position: relative;
}

.search-field {
  position: relative;
}

.compact-field {
  min-width: 140px;
}

.field-label {
  font-size: 13px;
  font-weight: 700;
  color: #1e293b;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  display: flex;
  align-items: center;
  gap: 6px;
}

.label-icon {
  font-size: 16px;
}

.required-mark {
  color: #ef4444;
  font-size: 14px;
  margin-left: 2px;
}

.input-wrapper {
  position: relative;
}

.search-input,
.number-input,
.textarea-input {
  width: 100%;
  padding: 14px 42px 14px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 10px;
  font-size: 14px;
  font-family: inherit;
  transition: all 0.3s ease;
  background: white;
  color: #1e293b;
}

.number-input {
  padding: 14px 16px;
  text-align: center;
  font-weight: 600;
  font-size: 16px;
}

.textarea-input {
  padding: 14px 16px;
  resize: vertical;
  min-height: 100px;
  line-height: 1.6;
}

.search-input:focus,
.number-input:focus,
.textarea-input:focus {
  outline: none;
  border-color: #ec4899;
  box-shadow: 0 0 0 4px rgba(236, 72, 153, 0.1);
  background: white;
}

.search-input::placeholder,
.textarea-input::placeholder {
  color: #94a3b8;
}

.search-input.has-selection {
  border-color: #10b981;
  background: #f0fdf4;
  font-weight: 500;
}

.search-icon-container {
  position: absolute;
  right: 14px;
  top: 50%;
  transform: translateY(-50%);
  color: #94a3b8;
  pointer-events: none;
}

/* Search Loader */
.search-loader {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: #64748b;
  margin-top: 6px;
  padding-left: 4px;
}

.mini-spinner {
  width: 14px;
  height: 14px;
  border: 2px solid #e2e8f0;
  border-top-color: #ec4899;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

/* Dropdown Styles */
.dropdown-menu {
  position: absolute;
  top: calc(100% + 8px);
  left: 0;
  right: 0;
  background: white;
  border: 2px solid #e5e7eb;
  border-radius: 12px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
  max-height: 320px;
  overflow: hidden;
  z-index: 50;
}

.dropdown-header {
  padding: 10px 16px;
  background: #f8fafc;
  border-bottom: 1px solid #e5e7eb;
  font-size: 11px;
  font-weight: 600;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.dropdown-list {
  max-height: 280px;
  overflow-y: auto;
}

.dropdown-item {
  padding: 14px 16px;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  gap: 12px;
  border-bottom: 1px solid #f1f5f9;
}

.dropdown-item:last-child {
  border-bottom: none;
}

.dropdown-item:hover {
  background: linear-gradient(90deg, #fdf4ff 0%, #fce7f3 100%);
  padding-left: 20px;
}

.item-icon {
  width: 36px;
  height: 36px;
  background: linear-gradient(135deg, #fdf2f8 0%, #fce7f3 100%);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  flex-shrink: 0;
}

.item-details {
  flex: 1;
  min-width: 0;
}

.item-name {
  font-size: 14px;
  font-weight: 600;
  color: #1e293b;
  margin-bottom: 2px;
}

.item-meta {
  font-size: 12px;
  color: #64748b;
  font-weight: 500;
}

/* Dropdown Empty State */
.dropdown-empty {
  padding: 32px 20px;
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.empty-icon {
  font-size: 32px;
  opacity: 0.5;
  margin-bottom: 4px;
}

.empty-text {
  font-size: 14px;
  font-weight: 600;
  color: #64748b;
}

.empty-hint {
  font-size: 12px;
  color: #94a3b8;
  margin-bottom: 12px;
}

.use-name-btn {
  margin-top: 8px;
  padding: 10px 20px;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3);
}

.use-name-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.4);
}

.use-name-btn:active {
  transform: translateY(0);
}

/* Dropdown Animation */
.dropdown-fade-enter-active,
.dropdown-fade-leave-active {
  transition: all 0.2s ease;
}

.dropdown-fade-enter-from {
  opacity: 0;
  transform: translateY(-10px);
}

.dropdown-fade-leave-to {
  opacity: 0;
  transform: translateY(-5px);
}

/* Form Actions */
.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding-top: 16px;
  border-top: 2px solid #f1f5f9;
  margin-top: 8px;
}

.btn-submit,
.btn-clear {
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

.btn-submit {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  box-shadow: 0 4px 14px rgba(16, 185, 129, 0.4);
}

.btn-submit:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(16, 185, 129, 0.5);
}

.btn-submit:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.btn-clear {
  background: #64748b;
  color: white;
  box-shadow: 0 4px 14px rgba(100, 116, 139, 0.3);
}

.btn-clear:hover:not(:disabled) {
  background: #475569;
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(100, 116, 139, 0.4);
}

.btn-clear:disabled {
  opacity: 0.5;
  cursor: not-allowed;
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

/* Controls */
.controls-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  flex-wrap: wrap;
  gap: 16px;
}

.show-entries {
  display: flex;
  align-items: center;
  gap: 8px;
}

.header-section{
    display:flex;
    justify-content:space-between
}

.search-box {
  display: flex;
  align-items: center;
  gap: 8px;
}

.search-box label {
  font-size: 14px;
  color: #64748b;
}

.search-box input {
  padding: 8px 16px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 14px;
  width: 250px;
}

/* Table */
.table-container {
  background: white;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  margin-bottom: 16px;
}

.consultations-table {
  width: 100%;
  border-collapse: collapse;
}

.consultations-table thead {
  background: #f8fafc;
  border-bottom: 2px solid #e2e8f0;
}

.consultations-table th {
  padding: 14px 16px;
  text-align: left;
  font-size: 12px;
  font-weight: 700;
  color: #475569;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  cursor: pointer;
  user-select: none;
}

.consultations-table th:hover {
  background: #f1f5f9;
}

.sort-icon {
  margin-left: 4px;
  color: #94a3b8;
}

.consultations-table tbody tr {
  border-bottom: 1px solid #f1f5f9;
  transition: background 0.2s ease;
}

.consultations-table tbody tr:hover {
  background: #f8fafc;
}

.consultations-table td {
  padding: 14px 16px;
  font-size: 14px;
  color: #1e293b;
}

.loading-cell,
.empty-cell {
  text-align: center;
  padding: 40px 20px;
  color: #64748b;
  font-size: 14px;
}

.spinner {
  width: 32px;
  height: 32px;
  border: 3px solid #e2e8f0;
  border-top-color: #ec4899;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin: 0 auto 12px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Action Buttons */
.action-btn {
  padding: 6px 10px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s ease;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.view-btn {
  background: #3b82f6;
  color: white;
}

.view-btn:hover {
  background: #2563eb;
  transform: translateY(-1px);
}

/* Pagination */
.pagination-info {
  padding: 12px 16px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.pagination-info p {
  font-size: 14px;
  color: #64748b;
}

/* Responsive */
@media (max-width: 1024px) {
  .search-row {
    grid-template-columns: 1fr 1fr;
  }
  
  .compact-field {
    grid-column: span 2;
  }
}

@media (max-width: 768px) {
  .main-content {
    margin-left: 0;
  }

  .sidebar {
    display: none;
  }

  .consultations-content {
    padding: 16px;
  }

  .add-consultation-section {
    border-radius: 12px;
  }

  .section-header {
    padding: 16px 20px;
  }

  .consultation-form {
    padding: 20px;
  }

  .search-row {
    grid-template-columns: 1fr;
  }

  .compact-field {
    grid-column: span 1;
  }

  .notes-row {
    grid-template-columns: 1fr;
  }

  .form-actions {
    flex-direction: column-reverse;
  }

  .btn-submit,
  .btn-clear {
    width: 100%;
    justify-content: center;
  }

  .table-container {
    overflow-x: auto;
  }

  .controls-row {
    flex-direction: column;
    align-items: stretch;
  }

  .search-box input {
    width: 100%;
  }
}
</style>
