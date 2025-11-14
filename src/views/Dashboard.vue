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
        <router-link to="/consultations" class="nav-item">
          <i class="icon" aria-hidden="true">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" fill="currentColor" />
            </svg>
          </i>
          <span>Consultations</span>
        </router-link>
      </nav>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
      <!-- Header -->
      <header class="header">
        <div class="search-bar">
          <i class="search-icon">🔍</i>
          <input type="text" placeholder="Search..." v-model="searchQuery" />
        </div>
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
          <h2 class="chart-title">No. Of Patients Per Month In Year 2025</h2>
          
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
  async created() {
    // Get initial user data
    await this.fetchUserData()
  },
  data() {
    return {
      searchQuery: '',
      activeTab: 'patients',
      showProfileModal: false,
      stats: {
        activePatients: 13,
        staffUsers: 2,
        medicine: 36,
        transactions: 3
      },
      chart: null,
      userName: 'User',
      userAvatar: null
    }
  },
  mounted() {
    this.$nextTick(() => {
      this.initChart()
    })
  },
  beforeUnmount() {
    if (this.chart) {
      this.chart.destroy()
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
    
    updateUserName(newName) {
      this.userName = newName
    },
    initChart() {
      if (!this.$refs.chartCanvas) {
        console.error('Chart canvas not found')
        return
      }
      
      const ctx = this.$refs.chartCanvas.getContext('2d')
      
      this.chart = new Chart(ctx, {
        type: 'line',
        data: {
          labels: ['January', 'February', 'March', 'April', 'May', 'June', 'July'],
          datasets: [
            {
              label: 'Students',
              data: [20, 35, 55, 60, 48, 22, 15],
              backgroundColor: 'rgba(255, 127, 80, 0.1)',
              borderColor: 'rgb(255, 127, 80)',
              borderWidth: 3,
              fill: true,
              tension: 0.4,
              pointRadius: 5,
              pointHoverRadius: 7,
              pointBackgroundColor: 'rgb(255, 127, 80)',
              pointBorderColor: '#fff',
              pointBorderWidth: 2,
              pointHoverBackgroundColor: '#fff',
              pointHoverBorderColor: 'rgb(255, 127, 80)',
              pointHoverBorderWidth: 2
            },
            {
              label: 'Faculties',
              data: [25, 40, 65, 70, 58, 28, 20],
              backgroundColor: 'rgba(50, 205, 50, 0.1)',
              borderColor: 'rgb(50, 205, 50)',
              borderWidth: 3,
              fill: true,
              tension: 0.4,
              pointRadius: 5,
              pointHoverRadius: 7,
              pointBackgroundColor: 'rgb(50, 205, 50)',
              pointBorderColor: '#fff',
              pointBorderWidth: 2,
              pointHoverBackgroundColor: '#fff',
              pointHoverBorderColor: 'rgb(50, 205, 50)',
              pointHoverBorderWidth: 2
            },
            {
              label: 'Staffs',
              data: [30, 48, 75, 82, 68, 35, 25],
              backgroundColor: 'rgba(30, 144, 255, 0.1)',
              borderColor: 'rgb(30, 144, 255)',
              borderWidth: 3,
              fill: true,
              tension: 0.4,
              pointRadius: 5,
              pointHoverRadius: 7,
              pointBackgroundColor: 'rgb(30, 144, 255)',
              pointBorderColor: '#fff',
              pointBorderWidth: 2,
              pointHoverBackgroundColor: '#fff',
              pointHoverBorderColor: 'rgb(30, 144, 255)',
              pointHoverBorderWidth: 2
            }
          ]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              display: true,
              position: 'top',
              align: 'end',
              labels: {
                usePointStyle: true,
                padding: 20,
                font: {
                  size: 13,
                  weight: '500',
                  family: "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif"
                },
                boxWidth: 10,
                boxHeight: 10,
                color: '#64748b'
              }
            },
            tooltip: {
              enabled: true,
              mode: 'index',
              intersect: false,
              backgroundColor: 'rgba(0, 0, 0, 0.85)',
              titleColor: '#fff',
              bodyColor: '#fff',
              padding: 12,
              cornerRadius: 8,
              displayColors: true,
              titleFont: {
                size: 14,
                weight: 'bold'
              },
              bodyFont: {
                size: 13
              }
            }
          },
          scales: {
            y: {
              beginAtZero: true,
              max: 100,
              ticks: {
                stepSize: 20,
                font: {
                  size: 12
                },
                color: '#64748b',
                callback: function(value) {
                  return value
                }
              },
              grid: {
                color: 'rgba(100, 116, 139, 0.1)',
                drawBorder: false
              },
              border: {
                display: false
              }
            },
            x: {
              ticks: {
                font: {
                  size: 12
                },
                color: '#64748b'
              },
              grid: {
                display: false
              },
              border: {
                display: false
              }
            }
          },
          interaction: {
            mode: 'index',
            intersect: false
          }
        }
      })
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
  justify-content: space-between;
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

.chart-title {
  font-size: 16px;
  color: #1e293b;
  margin-bottom: 14px;
  font-weight: 600;
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
}
</style>
