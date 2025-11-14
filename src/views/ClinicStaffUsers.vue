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
        <router-link to="/staff-users" class="nav-item active">
          <i class="icon" aria-hidden="true">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M16 11C17.6569 11 19 9.65685 19 8C19 6.34315 17.6569 5 16 5C14.3431 5 13 6.34315 13 8C13 9.65685 14.3431 11 16 11Z" fill="currentColor" />
              <path d="M8 11C9.65685 11 11 9.65685 11 8C11 6.34315 9.65685 5 8 5C6.34315 5 5 6.34315 5 8C5 9.65685 6.34315 11 8 11Z" fill="currentColor" />
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
          <input type="text" placeholder="Search..." v-model="globalSearch" />
        </div>
        <div class="user-profile" @click="showProfileModal = true" style="cursor: pointer;">
          <img src="@/assets/NurseProfile.jpg" alt="Admin" class="user-avatar" />
          <span class="user-greeting">Hi, <strong>Admin</strong></span>
        </div>
      </header>

      <!-- Profile Modal -->
      <Profile :show="showProfileModal" @close="showProfileModal = false" />

      <!-- Add Staff Modal -->
      <AddStaff :show="showAddStaffModal" @close="showAddStaffModal = false" @add-staff="handleAddStaff" />

      <!-- Clinic Staff Users Content -->
      <div class="page-content">
        <!-- Page Header with Title and Actions -->
        <div class="page-header-section">
          <div class="title-section">
            <h2 class="page-title">Clinic Staff Users</h2>
            <p class="page-subtitle">Manage clinic staff members and their roles</p>
          </div>

          <div class="header-actions">
            <div class="search-control-inline">
              <i class="search-icon-inline">🔍</i>
              <input type="text" v-model="tableSearch" placeholder="Search staff..." aria-label="Search staff" />
            </div>
            <button class="add-staff-btn" @click="addStaff">
              + Add Staff
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
              Showing {{ filteredStaff.length }} staff member{{ filteredStaff.length !== 1 ? 's' : '' }}
            </div>
          </div>

          <!-- Scrollable Table -->
          <div class="table-scroll">
            <table class="staff-table">
              <thead>
                <tr>
                  <th>NAME</th>
                  <th>EMAIL</th>
                  <th>ROLE</th>
                  <th>SEX</th>
                  <th>STATUS</th>
                  <th>ACTION</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="staff in filteredStaff" :key="staff.id">
                  <td>
                    <div class="name-cell">
                      <img :src="staff.avatar" :alt="staff.name" class="staff-avatar" />
                      <span>{{ staff.name }}</span>
                    </div>
                  </td>
                  <td>{{ staff.email }}</td>
                  <td>{{ staff.role }}</td>
                  <td>{{ staff.sex }}</td>
                  <td>
                    <span :class="['status-badge', staff.status.toLowerCase()]">
                      {{ staff.status }}
                    </span>
                  </td>
                  <td>
                    <div class="action-buttons">
                      <button class="action-btn edit-btn" @click="editStaff(staff)" title="Edit">
                        ✏️
                      </button>
                      <button class="action-btn view-btn" @click="viewStaff(staff)" title="View Details">
                        👁️
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import Profile from '../components/Profile.vue'
import AddStaff from '../components/AddStaff.vue'
import NurseProfileImg from '@/assets/NurseProfile.jpg'

export default {
  name: 'ClinicStaffUsersPage',
  components: {
    Profile,
    AddStaff
  },
  data() {
    return {
      globalSearch: '',
      tableSearch: '',
      showProfileModal: false,
      showAddStaffModal: false,
      staff: [
        {
          id: 1,
          avatar: NurseProfileImg,
          name: 'Renz Angelo Sefuentes',
          email: 'Sefuentesrenz31@Gmail.Com',
          role: 'Admin',
          sex: 'Male',
          status: 'Active'
        },
        {
          id: 2,
          avatar: NurseProfileImg,
          name: 'Maria Santos',
          email: 'maria.santos@uic.edu.ph',
          role: 'Nurse',
          sex: 'Female',
          status: 'Active'
        },
        {
          id: 3,
          avatar: NurseProfileImg,
          name: 'John Dela Cruz',
          email: 'john.delacruz@uic.edu.ph',
          role: 'Nurse',
          sex: 'Male',
          status: 'Active'
        },
        {
          id: 4,
          avatar: NurseProfileImg,
          name: 'Anna Marie Lopez',
          email: 'anna.lopez@uic.edu.ph',
          role: 'Nurse',
          sex: 'Female',
          status: 'Active'
        },
        {
          id: 5,
          avatar: NurseProfileImg,
          name: 'Carlos Reyes',
          email: 'carlos.reyes@uic.edu.ph',
          role: 'Nurse',
          sex: 'Male',
          status: 'Inactive'
        }
      ]
    }
  },
  computed: {
    filteredStaff() {
      let filtered = this.staff

      // Filter by table search
      if (this.tableSearch.trim()) {
        const search = this.tableSearch.toLowerCase()
        filtered = filtered.filter(s => 
          s.name.toLowerCase().includes(search) ||
          s.email.toLowerCase().includes(search) ||
          s.role.toLowerCase().includes(search) ||
          s.status.toLowerCase().includes(search)
        )
      }

      return filtered
    }
  },
  methods: {
    addStaff() {
      this.showAddStaffModal = true
    },
    handleAddStaff(newStaff) {
      // Add new staff to the list
      const staffMember = {
        id: this.staff.length + 1,
        avatar: newStaff.profileFile ? URL.createObjectURL(newStaff.profileFile) : NurseProfileImg,
        name: newStaff.name,
        email: newStaff.email,
        role: newStaff.role,
        sex: 'N/A', // Can be added to form if needed
        status: newStaff.status
      }
      this.staff.push(staffMember)
      alert(`Staff user ${newStaff.name} has been added successfully!`)
    },
    editStaff(staff) {
      console.log('Edit staff:', staff)
      alert(`Editing staff user: ${staff.name}`)
      // TODO: Implement edit staff modal/form
    },
    viewStaff(staff) {
      console.log('View staff:', staff)
      alert(`Viewing details for staff user: ${staff.name} - ${staff.role}`)
      // TODO: Implement view staff details modal/page
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

.title-section {
  display: flex;
  flex-direction: column;
  gap: 4px;
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

.page-subtitle {
  font-size: 14px;
  color: #64748b;
  margin: 0;
  font-weight: 500;
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
  border-color: #8b5cf6;
  box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.1);
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

.add-staff-btn {
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

.add-staff-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(236, 72, 153, 0.4);
}

/* Page Header - OLD */
.page-header {
  display: none;
}

/* Filter Section */
.filter-section {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
}

.filter-btn {
  padding: 10px 24px;
  border: none;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  background: #d1d5db;
  color: #374151;
}

.filter-btn:hover {
  background: #9ca3af;
  color: white;
}

.filter-btn.active {
  background: #6366f1;
  color: white;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
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
  gap: 12px;
  flex-wrap: wrap;
}

.entries-control {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #64748b;
  font-size: 14px;
}

.entries-control input[type="checkbox"] {
  width: 18px;
  height: 18px;
  cursor: pointer;
  accent-color: #8b5cf6;
}

.entries-control label {
  font-weight: 500;
  cursor: pointer;
}

.results-info {
  color: #64748b;
  font-size: 14px;
  font-weight: 500;
}

.search-control {
  display: none; /* Hidden in favor of inline search */
}

/* Scrollable Table */
.table-scroll {
  flex: 1;
  overflow-y: auto;
  overflow-x: auto;
}

.staff-table {
  width: 100%;
  border-collapse: collapse;
}

.staff-table thead {
  position: sticky;
  top: 0;
  background: #f9fafb;
  z-index: 10;
}

.staff-table th {
  padding: 12px 16px;
  text-align: left;
  font-size: 12px;
  font-weight: 600;
  color: #374151;
  text-transform: uppercase;
  border-bottom: 2px solid #e5e7eb;
}

.staff-table tbody tr {
  transition: background 0.2s ease;
}

.staff-table tbody tr:hover {
  background: #f9fafb;
}

.staff-table tbody tr:nth-child(even) {
  background: #fafafa;
}

.staff-table tbody tr:nth-child(even):hover {
  background: #f3f4f6;
}

.staff-table td {
  padding: 14px 16px;
  font-size: 13px;
  color: #4b5563;
  border-bottom: 1px solid #e5e7eb;
}

/* Name Cell with Avatar */
.name-cell {
  display: flex;
  align-items: center;
  gap: 10px;
}

.staff-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #ec4899;
}

.name-cell span {
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

/* Action Buttons */
.action-buttons {
  display: flex;
  gap: 8px;
  align-items: center;
}

.action-btn {
  background: none;
  border: none;
  font-size: 18px;
  cursor: pointer;
  padding: 4px 8px;
  transition: transform 0.2s ease;
}

.action-btn:hover {
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

  .page-header-section {
    flex-direction: column;
    align-items: stretch;
  }

  .title-section {
    min-width: auto;
  }

  .header-actions {
    justify-content: flex-end;
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
    gap: 16px;
  }

  .header-actions {
    width: 100%;
    flex-direction: column;
    align-items: stretch;
  }

  .search-control-inline {
    width: 100%;
    min-width: auto;
  }

  .add-staff-btn {
    width: 100%;
    text-align: center;
  }

  .table-controls {
    flex-direction: column;
    align-items: flex-start;
  }

  .results-info {
    align-self: flex-end;
  }
}

@media (max-width: 768px) {
  .page-content {
    padding: 16px;
  }

  .page-title {
    font-size: 24px;
  }

  .page-subtitle {
    font-size: 13px;
  }
}
</style>
