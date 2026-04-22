<template>
  <div class="dashboard-container">
    <!-- Sidebar -->
    <aside class="sidebar">
      <div class="sidebar-header">
        <img src="@/assets/logo.png" alt="UIC-CMS Logo" class="sidebar-logo" />
        <h2 class="sidebar-title">UIC-CMS</h2>
      </div>
      
      <nav class="sidebar-nav">
        <router-link to="/dashboard" class="nav-item active">
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
              <circle cx="12" cy="13" r="1.5" fill="#fff" opacity="0" />
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

      <!-- Dashboard Content -->
      <div class="dashboard-content">
        <h1 class="page-title">Dashboard</h1>

        <!-- Stats Cards -->
        <div class="stats-grid">
          <div class="stat-card active-patients">
            <div class="stat-icon">👥</div>
            <div class="stat-info">
              <p class="stat-label">Active Patients</p>
              <p class="stat-value">{{ stats.activePatients }}</p>
            </div>
          </div>

          <div class="stat-card staff-users">
            <div class="stat-icon">👤</div>
            <div class="stat-info">
              <p class="stat-label">Staff Users</p>
              <p class="stat-value">{{ stats.staffUsers }}</p>
            </div>
          </div>

          <div class="stat-card medicine">
            <div class="stat-icon">💊</div>
            <div class="stat-info">
              <p class="stat-label">Medicine</p>
              <p class="stat-value">{{ stats.medicine }}</p>
            </div>
          </div>

          <div class="stat-card transactions">
            <div class="stat-icon">📝</div>
            <div class="stat-info">
              <p class="stat-label">Transactions</p>
              <p class="stat-value">{{ stats.transactions }}</p>
            </div>
          </div>
        </div>

        <!-- Chart Section -->
        <div class="chart-section">
          <div class="chart-header-row">
            <h2 class="chart-title">{{ chartTitle }}</h2>
            <div class="year-filter" v-if="availableYears.length > 0">
              <label for="chartYear">Year:</label>
              <select id="chartYear" v-model.number="currentYear" @change="handleYearChange">
                <option v-for="year in availableYears" :key="year" :value="year">{{ year }}</option>
              </select>
            </div>
          </div>
          
          <!-- Tab Navigation -->
          <div class="chart-tabs">
            <button 
              :class="['tab-btn', { active: activeTab === 'patients' }]"
              @click="activeTab = 'patients'"
            >
              Patients
            </button>
            <button 
              :class="['tab-btn', { active: activeTab === 'diseases' }]"
              @click="activeTab = 'diseases'"
            >
              Diseases
            </button>
            <button 
              :class="['tab-btn', { active: activeTab === 'medicines' }]"
              @click="activeTab = 'medicines'"
            >
              Medicines
            </button>
          </div>

          <!-- Chart -->
          <div class="chart-container">
            <canvas ref="chartCanvas"></canvas>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import { Chart, registerables } from 'chart.js'
import Profile from '../components/Profile.vue'
import { supabase } from '@/lib/Supabase.js'

Chart.register(...registerables)

export default {
  name: 'DashboardPage',
  components: {
    Profile
  },
  data() {
    return {
      searchQuery: '',
      activeTab: 'patients',
      currentYear: new Date().getFullYear(),
      availableYears: [],
      showProfileModal: false,
      stats: {
        activePatients: 0,
        staffUsers: 0,
        medicine: 0,
        transactions: 0
      },
      chart: null,
      userName: 'User',
      userAvatar: null,
      chartData: {
        students: [0,0,0,0,0,0,0,0,0,0,0,0],
        faculties: [0,0,0,0,0,0,0,0,0,0,0,0],
        staffs: [0,0,0,0,0,0,0,0,0,0,0,0],
        diseases: [],
        medicines: []
      },
      isDataLoaded: false,
      realtimeChannel: null,
      isRefreshing: false,
      refreshIntervalId: null
    }
  },
  computed: {
    chartLabels() {
      return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    },
    chartTitle() {
      switch (this.activeTab) {
        case 'patients':
          return `No. Of Patients Per Month In Year ${this.currentYear}`
        case 'diseases':
          return `No. Of Diseases Per Month In Year ${this.currentYear}`
        case 'medicines':
          return `No. Of Medicines Dispensed Per Month In Year ${this.currentYear}`
        default:
          return `Statistics For Year ${this.currentYear}`
      }
    }
  },
  async created() {
    await this.fetchUserData()
    await this.fetchAvailableYears()
    await this.refreshDashboardData()
    this.setupRealtimeUpdates()
    this.isDataLoaded = true
  },
  mounted() {
    this.$nextTick(() => {
      if (this.isDataLoaded) {
        this.initChart()
      }
    })
  },
  beforeUnmount() {
    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
    if (this.realtimeChannel) {
      supabase.removeChannel(this.realtimeChannel)
      this.realtimeChannel = null
    }
    if (this.refreshIntervalId) {
      clearInterval(this.refreshIntervalId)
      this.refreshIntervalId = null
    }
    window.removeEventListener('focus', this.handleWindowFocus)
    document.removeEventListener('visibilitychange', this.handleVisibilityChange)
  },
  watch: {
  activeTab(newTab, oldTab) {
    if (newTab !== oldTab && this.isDataLoaded) {
      this.$nextTick(() => {
        this.updateChartForTab(newTab)
      })
    }
  },
  isDataLoaded(newVal) {
    if (newVal && this.$refs.chartCanvas && !this.chart) {
      this.$nextTick(() => {
        this.initChart()
      })
    }
  }
},
  methods: {
    async refreshDashboardData() {
      if (this.isRefreshing) return

      this.isRefreshing = true
      try {
        await this.fetchAvailableYears()
        if (!this.availableYears.includes(this.currentYear)) {
          this.currentYear = this.availableYears[0] || new Date().getFullYear()
        }

        await Promise.all([this.fetchStats(), this.fetchChartData()])

        if (this.chart) {
          this.updateChartForTab(this.activeTab)
        }
      } finally {
        this.isRefreshing = false
      }
    },

    setupRealtimeUpdates() {
      if (this.realtimeChannel) {
        supabase.removeChannel(this.realtimeChannel)
      }

      this.realtimeChannel = supabase
        .channel('dashboard-live-updates')
        .on(
          'postgres_changes',
          { event: '*', schema: 'public', table: 'patients' },
          async () => {
            await this.refreshDashboardData()
          }
        )
        .subscribe()

      this.refreshIntervalId = setInterval(() => {
        this.refreshDashboardData()
      }, 30000)

      window.addEventListener('focus', this.handleWindowFocus)
      document.addEventListener('visibilitychange', this.handleVisibilityChange)
    },

    async handleWindowFocus() {
      await this.refreshDashboardData()
    },

    async handleVisibilityChange() {
      if (document.visibilityState === 'visible') {
        await this.refreshDashboardData()
      }
    },

    getYearRangeIso(year) {
      const start = new Date(Date.UTC(year, 0, 1, 0, 0, 0, 0)).toISOString()
      const end = new Date(Date.UTC(year + 1, 0, 1, 0, 0, 0, 0)).toISOString()
      return { start, end }
    },

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
    
    async fetchStats() {
      try {
        const { count: patientsCount } = await supabase
          .from('patients')
          .select('*', { count: 'exact', head: true })
        this.stats.activePatients = patientsCount || 0

        const { count: staffCount } = await supabase
          .from('profiles')
          .select('*', { count: 'exact', head: true })
          .in('role', ['Nurse', 'Staff', 'Admin'])
        this.stats.staffUsers = staffCount || 0

        const { count: medicineCount } = await supabase
          .from('medicine')
          .select('*', { count: 'exact', head: true })
        this.stats.medicine = medicineCount || 0

        const { count: transactionsCount } = await supabase
          .from('transactions')
          .select('*', { count: 'exact', head: true })
        this.stats.transactions = transactionsCount || 0

      } catch (err) {
        console.error('Error fetching stats:', err)
      }
    },
    
    async fetchChartData() {
      try {
        await this.fetchPatientsData(this.currentYear)
        await this.fetchDiseasesData(this.currentYear)
        await this.fetchMedicinesData(this.currentYear)
      } catch (err) {
        console.error('Error fetching chart data:', err)
      }
    },

    async handleYearChange() {
      await this.fetchChartData()
      if (this.chart) {
        this.updateChartForTab(this.activeTab)
      }
    },

    extractYearFromDate(dateValue) {
      const date = new Date(dateValue)
      if (Number.isNaN(date.getTime())) return null
      return date.getUTCFullYear()
    },

    async fetchDistinctYearsFromTable(tableName, dateColumn) {
      const years = new Set()
      const pageSize = 1000
      let from = 0

      while (true) {
        const to = from + pageSize - 1
        const { data, error } = await supabase
          .from(tableName)
          .select(dateColumn)
          .order(dateColumn, { ascending: false })
          .range(from, to)

        if (error) throw error

        const rows = data || []
        rows.forEach((row) => {
          const year = this.extractYearFromDate(row[dateColumn])
          if (year) years.add(year)
        })

        if (rows.length < pageSize) {
          break
        }

        from += pageSize
      }

      return years
    },

    async fetchAvailableYears() {
      try {
        const [patientYears, consultationYears, medicineYears, transactionYears] = await Promise.all([
          this.fetchDistinctYearsFromTable('patients', 'created_at'),
          this.fetchDistinctYearsFromTable('consultations', 'consultation_date'),
          this.fetchDistinctYearsFromTable('medicine', 'created_at'),
          this.fetchDistinctYearsFromTable('transactions', 'created_at')
        ])

        const mergedYears = new Set([
          ...patientYears,
          ...consultationYears,
          ...medicineYears,
          ...transactionYears,
          new Date().getFullYear()
        ])

        this.availableYears = Array.from(mergedYears).sort((a, b) => b - a)
      } catch (err) {
        console.error('Error loading chart years:', err)
        this.availableYears = [new Date().getFullYear()]
      }
    },

    normalizePatientType(rawType) {
      const normalized = (rawType || '').trim().toLowerCase()

      if (normalized.startsWith('student')) return 'student'
      if (normalized.startsWith('faculty')) return 'faculty'
      if (normalized.startsWith('staff') || normalized.startsWith('nurse')) return 'staff'

      return null
    },

    async fetchPatientsData(year) {
      try {
        const studentCounts = [0,0,0,0,0,0,0,0,0,0,0,0]
        const facultyCounts = [0,0,0,0,0,0,0,0,0,0,0,0]
        const staffCounts = [0,0,0,0,0,0,0,0,0,0,0,0]
        const { start, end } = this.getYearRangeIso(year)

        const { data: patients, error } = await supabase
          .from('patients')
          .select('created_at, type')
          .gte('created_at', start)
          .lt('created_at', end)

        if (error) throw error
        
        patients?.forEach(patient => {
          const createdAt = new Date(patient.created_at)
          if (Number.isNaN(createdAt.getTime())) return

          const month = createdAt.getUTCMonth()
          const type = this.normalizePatientType(patient.type)
          
          if (type === 'student') studentCounts[month]++
          else if (type === 'faculty') facultyCounts[month]++
          else if (type === 'staff') staffCounts[month]++
        })
        
        this.chartData.students = studentCounts
        this.chartData.faculties = facultyCounts
        this.chartData.staffs = staffCounts
        
        console.log('✅ Patients data loaded:', { studentCounts, facultyCounts, staffCounts })
        
      } catch (err) {
        console.error('❌ Error fetching patients data:', err)
      }
    },

    async fetchDiseasesData(year) {
  try {
    const diseaseCounts = {}
    const monthlyData = {}
        const { start, end } = this.getYearRangeIso(year)
    
    const { data: consultations, error } = await supabase
      .from('consultations')
      .select('consultation_date, diagnosis')
          .gte('consultation_date', start)
          .lt('consultation_date', end)
    
    if (error) throw error
    
    console.log('📊 Raw consultations data:', consultations)
    
    if (!consultations || consultations.length === 0) {
      this.chartData.diseases = [
        { label: 'No Consultations Data', data: [0,0,0,0,0,0,0,0,0,0,0,0] }
      ]
      console.log('⚠️ No consultations found for year', year)
      return
    }
    
    consultations?.forEach(consultation => {
      if (!consultation.diagnosis || consultation.diagnosis.trim() === '') return
      
      const consultDate = new Date(consultation.consultation_date)
      if (Number.isNaN(consultDate.getTime())) return

      const month = consultDate.getUTCMonth()
      const diagnosis = consultation.diagnosis.trim()
      
      if (!monthlyData[diagnosis]) {
        monthlyData[diagnosis] = [0,0,0,0,0,0,0,0,0,0,0,0]
      }
      monthlyData[diagnosis][month]++
      diseaseCounts[diagnosis] = (diseaseCounts[diagnosis] || 0) + 1
    })
    
    console.log('📊 Disease counts:', diseaseCounts)
    console.log('📊 Monthly disease data:', monthlyData)
    
    const topDiseases = Object.entries(diseaseCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([disease]) => disease)
    
    if (topDiseases.length === 0) {
      this.chartData.diseases = [
        { label: 'No Diseases Recorded', data: [0,0,0,0,0,0,0,0,0,0,0,0] }
      ]
    } else {
      this.chartData.diseases = topDiseases.map(disease => ({
        label: disease,
        data: [...monthlyData[disease]]
      }))
    }
    
    console.log('✅ Diseases data loaded:', this.chartData.diseases)
    
  } catch (err) {
    console.error('❌ Error fetching diseases data:', err)
    this.chartData.diseases = [{ label: 'Error Loading Data', data: [0,0,0,0,0,0,0,0,0,0,0,0] }]
  }
},

async fetchMedicinesData(year) {
  try {
    const medicineCounts = {}
    const monthlyData = {}
    const { start, end } = this.getYearRangeIso(year)
    
    // Option 1: Get all transactions and check description/notes for medicine names
    const { data: transactions, error: transError } = await supabase
      .from('transactions')
      .select('*')
      .eq('type', 'Dispensed')
      .gte('created_at', start)
      .lt('created_at', end)
    
    if (transError) {
      console.error('Transaction error:', transError)
      
      // Fallback: Show medicines added to inventory instead
      console.log('💊 Falling back to showing medicines added to inventory...')
      
      const { data: medicines, error: medError } = await supabase
        .from('medicine')
        .select('id, name, created_at')
        .gte('created_at', start)
        .lt('created_at', end)
      
      if (medError) throw medError
      
      console.log('💊 Medicines from inventory:', medicines)
      
      if (!medicines || medicines.length === 0) {
        this.chartData.medicines = [
          { label: 'No Medicines Added', data: [0,0,0,0,0,0,0,0,0,0,0,0] }
        ]
        return
      }
      
      medicines?.forEach(medicine => {
        const createdAt = new Date(medicine.created_at)
        if (Number.isNaN(createdAt.getTime())) return

        const month = createdAt.getUTCMonth()
        const medicineName = medicine.name?.trim() || 'Unknown'
        
        if (!monthlyData[medicineName]) {
          monthlyData[medicineName] = [0,0,0,0,0,0,0,0,0,0,0,0]
        }
        monthlyData[medicineName][month]++
        medicineCounts[medicineName] = (medicineCounts[medicineName] || 0) + 1
      })
      
    } else {
      console.log('💊 Raw transactions data:', transactions)
      
      if (!transactions || transactions.length === 0) {
        this.chartData.medicines = [
          { label: 'No Medicines Dispensed', data: [0,0,0,0,0,0,0,0,0,0,0,0] }
        ]
        return
      }
      
      transactions?.forEach(transaction => {
        const createdAt = new Date(transaction.created_at)
        if (Number.isNaN(createdAt.getTime())) return

        const month = createdAt.getUTCMonth()
        
        // Extract medicine name from description or notes
        let medicineName = 'Unknown Medicine'
        
        if (transaction.description && transaction.description.trim() !== '') {
          medicineName = transaction.description.trim()
        } else if (transaction.notes && transaction.notes.trim() !== '') {
          medicineName = transaction.notes.trim()
        }
        
        if (!monthlyData[medicineName]) {
          monthlyData[medicineName] = [0,0,0,0,0,0,0,0,0,0,0,0]
        }
        monthlyData[medicineName][month]++
        medicineCounts[medicineName] = (medicineCounts[medicineName] || 0) + 1
      })
    }
    
    console.log('💊 Medicine counts:', medicineCounts)
    console.log('💊 Monthly medicine data:', monthlyData)
    
    const topMedicines = Object.entries(medicineCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([medicine]) => medicine)
    
    if (topMedicines.length === 0) {
      this.chartData.medicines = [
        { label: 'No Data Available', data: [0,0,0,0,0,0,0,0,0,0,0,0] }
      ]
    } else {
      this.chartData.medicines = topMedicines.map(medicine => ({
        label: medicine,
        data: [...monthlyData[medicine]]
      }))
    }
    
    console.log('✅ Medicines data loaded:', this.chartData.medicines)
    
  } catch (err) {
    console.error('❌ Error fetching medicines data:', err)
    this.chartData.medicines = [{ label: 'Error Loading Data', data: [0,0,0,0,0,0,0,0,0,0,0,0] }]
  }
},
    
   updateChartForTab(tab) {
  if (!this.chart) {
    console.warn('⚠️ Chart not initialized yet')
    return
  }
  
  console.log('🔄 Switching to tab:', tab)
  
  // Destroy the existing chart to prevent corruption
  if (this.chart) {
    this.chart.destroy()
    this.chart = null
  }
  
  // Wait for DOM to update
  this.$nextTick(() => {
    if (!this.$refs.chartCanvas) {
      console.error('❌ Chart canvas not found')
      return
    }
    
    const ctx = this.$refs.chartCanvas.getContext('2d')
    
    const colors = [
      { bg: 'rgba(255, 127, 80, 0.2)', border: 'rgb(255, 127, 80)' },
      { bg: 'rgba(50, 205, 50, 0.2)', border: 'rgb(50, 205, 50)' },
      { bg: 'rgba(30, 144, 255, 0.2)', border: 'rgb(30, 144, 255)' }
    ]
    
    let datasets = []
    
    if (tab === 'patients') {
      datasets = [
        {
          label: 'Students',
          data: [...this.chartData.students],
          backgroundColor: colors[0].bg,
          borderColor: colors[0].border,
          borderWidth: 2,
          fill: true,
          tension: 0.4
        },
        {
          label: 'Faculties',
          data: [...this.chartData.faculties],
          backgroundColor: colors[1].bg,
          borderColor: colors[1].border,
          borderWidth: 2,
          fill: true,
          tension: 0.4
        },
        {
          label: 'Staffs',
          data: [...this.chartData.staffs],
          backgroundColor: colors[2].bg,
          borderColor: colors[2].border,
          borderWidth: 2,
          fill: true,
          tension: 0.4
        }
      ]
      console.log('📊 Patients datasets:', datasets)
    } else if (tab === 'diseases') {
      datasets = this.chartData.diseases.map((disease, index) => ({
        label: disease.label,
        data: [...disease.data],
        backgroundColor: colors[index % 3].bg,
        borderColor: colors[index % 3].border,
        borderWidth: 2,
        fill: true,
        tension: 0.4
      }))
      console.log('📊 Diseases datasets:', datasets)
    } else if (tab === 'medicines') {
      datasets = this.chartData.medicines.map((medicine, index) => ({
        label: medicine.label,
        data: [...medicine.data],
        backgroundColor: colors[index % 3].bg,
        borderColor: colors[index % 3].border,
        borderWidth: 2,
        fill: true,
        tension: 0.4
      }))
      console.log('📊 Medicines datasets:', datasets)
    }
    
    // Create new chart with fresh data
    this.chart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: this.chartLabels,
        datasets: datasets
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: true,
            position: 'top'
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              stepSize: 5
            }
          }
        }
      }
    })
    
    console.log('✅ Chart recreated successfully for tab:', tab)
  })
},
    
    updateUserName(newName) {
      this.userName = newName
    },
    
    initChart() {
      if (!this.$refs.chartCanvas) {
        console.error('Chart canvas not found')
        return
      }
      
      if (this.chart) {
        this.chart.destroy()
      }
      
      const ctx = this.$refs.chartCanvas.getContext('2d')
      
      this.chart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: this.chartLabels,
          datasets: [
            {
              label: 'Students',
              data: [...this.chartData.students],
              backgroundColor: 'rgba(255, 127, 80, 0.2)',
              borderColor: 'rgb(255, 127, 80)',
              borderWidth: 2,
              fill: true,
              tension: 0.4
            },
            {
              label: 'Faculties',
              data: [...this.chartData.faculties],
              backgroundColor: 'rgba(50, 205, 50, 0.2)',
              borderColor: 'rgb(50, 205, 50)',
              borderWidth: 2,
              fill: true,
              tension: 0.4
            },
            {
              label: 'Staffs',
              data: [...this.chartData.staffs],
              backgroundColor: 'rgba(30, 144, 255, 0.2)',
              borderColor: 'rgb(30, 144, 255)',
              borderWidth: 2,
              fill: true,
              tension: 0.4
            }
          ]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              display: true,
              position: 'top'
            }
          },
          scales: {
            y: {
              beginAtZero: true,
              ticks: {
                stepSize: 5
              }
            }
          }
        }
      })
      
      console.log('✅ Chart initialized')
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

.dashboard-container {
  display: flex;
  min-height: 100vh;
  background: #f5f7fa;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

/* Sidebar Styles */
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

/* Header */
.header {
  background: white;
  padding: 12px 24px;
  display: flex;
  
  align-items: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  position: sticky;
  top: 0;
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
  font-size: 18px;
  color: #666;
}

.search-bar input {
  border: none;
  background: none;
  outline: none;
  font-size: 15px;
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
  font-size: 16px;
  color: #333;
}

.user-greeting strong {
  color: #ec4899;
  font-weight: 600;
}

/* Dashboard Content */
.dashboard-content {
  padding: 16px 24px;
  flex: 1;
}

.page-title {
  font-size: 22px;
  color: #2c3e50;
  margin-bottom: 16px;
  font-weight: 600;
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 14px;
  margin-bottom: 18px;
}

.stat-card {
  background: white;
  border-radius: 10px;
  padding: 14px 16px;
  display: flex;
  align-items: center;
  gap: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  transition: all 0.3s ease;
  border: 1px solid #f0f0f0;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  border-color: #e5e7eb;
}

.stat-icon {
  font-size: 24px;
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 8px;
  flex-shrink: 0;
}

.active-patients .stat-icon {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
}

.staff-users .stat-icon {
  background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%);
  box-shadow: 0 4px 12px rgba(139, 92, 246, 0.3);
}

.medicine .stat-icon {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

.transactions .stat-icon {
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
  box-shadow: 0 4px 12px rgba(245, 158, 11, 0.3);
}

.stat-info {
  flex: 1;
  min-width: 0;
}

.stat-label {
  font-size: 11px;
  color: #64748b;
  margin-bottom: 3px;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.3px;
}

.stat-value {
  font-size: 18px;
  font-weight: 700;
  color: #1e293b;
  line-height: 1;
}

/* Chart Section */
.chart-section {
  background: white;
  border-radius: 10px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  border: 1px solid #f0f0f0;
}

.chart-header-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 14px;
}

.chart-title {
  font-size: 16px;
  color: #1e293b;
  margin-bottom: 0;
  font-weight: 600;
}

.year-filter {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #64748b;
}

.year-filter select {
  padding: 6px 10px;
  border-radius: 8px;
  border: 1px solid #d1d5db;
  background: #fff;
  color: #111827;
}

.year-filter select:focus {
  outline: none;
  border-color: #ec4899;
  box-shadow: 0 0 0 3px rgba(236, 72, 153, 0.15);
}

.chart-tabs {
  display: flex;
  gap: 6px;
  margin-bottom: 14px;
  border-bottom: 2px solid #f1f5f9;
  padding-bottom: 2px;
}

.tab-btn {
  padding: 8px 16px;
  background: none;
  border: none;
  font-size: 13px;
  color: #64748b;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 500;
  border-bottom: 3px solid transparent;
  margin-bottom: -2px;
  border-radius: 6px 6px 0 0;
}

.tab-btn:hover {
  color: #3b82f6;
  background: #f8fafc;
}

.tab-btn.active {
  color: #3b82f6;
  border-bottom-color: #3b82f6;
  font-weight: 600;
  background: #f8fafc;
}

.chart-container {
  height: 320px;
  position: relative;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .sidebar {
    width: 220px;
  }
  
  .main-content {
    margin-left: 220px;
  }
  
  .header {
    padding: 16px 24px;
  }
  
  .search-bar {
    width: 300px;
  }
  
  .dashboard-content {
    padding: 24px;
  }

  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
  }
}

@media (max-width: 968px) {
  .sidebar {
    width: 200px;
  }
  
  .main-content {
    margin-left: 200px;
  }
  
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .sidebar-title {
    font-size: 20px;
  }
  
  .nav-item {
    font-size: 14px;
    padding: 14px 20px;
  }

  .chart-container {
    height: 350px;
  }
}

@media (max-width: 768px) {
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
  
  .sidebar-header {
    justify-content: center;
  }
  
  .nav-item {
    justify-content: center;
  }
  
  .search-bar {
    width: 200px;
  }
  
  .user-greeting {
    display: none;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
    gap: 12px;
  }

  .stat-card {
    padding: 16px;
  }

  .stat-icon {
    width: 40px;
    height: 40px;
    font-size: 24px;
  }

  .stat-value {
    font-size: 20px;
  }

  .chart-container {
    height: 300px;
  }

  .chart-section {
    padding: 20px;
  }

  .chart-header-row {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>
