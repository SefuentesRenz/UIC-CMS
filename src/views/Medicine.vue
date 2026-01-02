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
        <router-link to="/medicine" class="nav-item active">
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

      <!-- Notification Modal -->
      <NotificationModal 
        :show="showNotification" 
        :message="notificationMessage" 
        :type="notificationType"
        @close="showNotification = false" />
      
      <!-- Profile Modal -->
      <Profile :show="showProfileModal" @close="showProfileModal = false" />

      <!-- Add Medicine Modal -->
      <AddMedicine :show="showAddMedicineModal" @close="showAddMedicineModal = false" @add-medicine="addMedicine" />
      
      <!-- View Medicine Modal -->
      <ViewMedicine
        :show="showViewMedicineModal"
        :medicine="selectedMedicine"
        @close="closeViewMedicineModal"
        @update-medicine="updateMedicine"
        @validation-error="showValidationError"
      />

      <!-- Medicine Stock Content -->
      <div class="page-content">
        <!-- Page Header with Title and Actions -->
        <div class="page-header-section">
          <div class="title-section">
            <h2 class="page-title">Medicine Stock</h2>
            <p class="page-subtitle">Manage and track medicine inventory</p>
          </div>

          <div class="header-actions">
            <div class="search-control-inline">
              <i class="search-icon-inline">🔍</i>
              <input type="text" v-model="tableSearch" placeholder="Search medicines..." aria-label="Search medicines" />
            </div>
            <button class="add-medicine-btn" @click="openAddMedicineModal" :disabled="loading">
              {{ loading ? '⏳ Loading...' : '+ Add Medicines' }}
            </button>
          </div>
        </div>

        <!-- Table Section -->
        <!-- Loading State -->
        <div v-if="loading" class="loading-state" style="text-align: center; padding: 40px; color: #64748b;">
          <div style="font-size: 48px; margin-bottom: 16px;">⏳</div>
          <p style="font-size: 18px; font-weight: 600;">Loading medicines...</p>
        </div>

        <!-- Error State -->
        <div v-else-if="error" class="error-state" style="text-align: center; padding: 40px; color: #ef4444;">
          <div style="font-size: 48px; margin-bottom: 16px;">❌</div>
          <p style="font-size: 18px; font-weight: 600;">Error loading medicines</p>
          <p style="color: #64748b; margin-top: 8px;">{{ error }}</p>
          <button @click="getMedicines" style="margin-top: 16px; padding: 10px 20px; background: #3b82f6; color: white; border: none; border-radius: 8px; cursor: pointer;">
            Retry
          </button>
        </div>

        <div v-else class="table-container">
          <div class="table-controls">
            <div class="entries-control">
              <input type="checkbox" id="entries-checkbox" />
              <label for="entries-checkbox">Show entries</label>
            </div>
            <div class="results-info">
              Showing {{ filteredMedicines.length }} medicine{{ filteredMedicines.length !== 1 ? 's' : '' }}
            </div>
          </div>

          <!-- Scrollable Table -->
          <div class="table-scroll">
            <table class="medicine-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>NAME</th>
                  <th>QUANTITY</th>
                  <th>DATE ADDED</th>
                  <th>EXPIRATION DATE</th>
                  <th>STATUS</th>
                  <th>ACTION</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="filteredMedicines.length === 0">
                  <td colspan="7" style="text-align: center; padding: 40px; color: #94a3b8;">
                    <div style="font-size: 48px; margin-bottom: 12px;">💊</div>
                    <p style="font-size: 16px; font-weight: 600;">No medicines found</p>
                    <p style="font-size: 14px; margin-top: 8px;">Add your first medicine to get started</p>
                  </td>
                </tr>
                <tr v-for="medicine in filteredMedicines" :key="medicine.id" v-else>
                  <td>{{ medicine.id }}</td>
                  <td class="name-cell">{{ medicine.name }}</td>
                  <td>{{ medicine.quantity }}</td>
                  <td>{{ medicine.date_added }}</td>
                  <td>{{ medicine.expiration_date }}</td>
                  <td>
                    <span :class="['status-badge', medicine.status.toLowerCase()]">
                      {{ medicine.status }}
                    </span>
                  </td>
                  <td>
                    <button class="action-btn" @click="viewMedicine(medicine)" title="View/Edit Details" :disabled="loading">
                      📝
                    </button>
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
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../supabaseClient'
import Profile from '../components/Profile.vue'
import AddMedicine from '../components/AddMedicine.vue'
import ViewMedicine from '../components/ViewMedicine.vue'
import NotificationModal from '../components/NotificationModal.vue'

export default {
  name: 'MedicinePage',
  components: {
    Profile,
    AddMedicine,
    ViewMedicine,
    NotificationModal
  },
  setup() {
    // Reactive state
    const globalSearch = ref('')
    const tableSearch = ref('')
    const showProfileModal = ref(false)
    const showAddMedicineModal = ref(false)
    const showViewMedicineModal = ref(false)
    const selectedMedicine = ref(null)
    const medicines = ref([])
    const loading = ref(false)
    const error = ref(null)
    const showNotification = ref(false)
    const notificationMessage = ref('')
    const notificationType = ref('info')
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

    // 🟢 FETCH MEDICINES FROM SUPABASE
    const getMedicines = async () => {
      console.log('=== FETCHING MEDICINES FROM SUPABASE ===')
      loading.value = true
      error.value = null

      try {
        const { data, error: fetchError } = await supabase
          .from('medicine')
          .select('*')
          .order('id', { ascending: true })

        if (fetchError) {
          console.error('❌ Error fetching medicines:', fetchError)
          error.value = fetchError.message
          throw fetchError
        }

        console.log(`✅ Successfully fetched ${data.length} medicines`)
        console.table(data)
        medicines.value = data
      } catch (err) {
        console.error('❌ Failed to fetch medicines:', err)
        showNotificationModal(`Failed to fetch medicines: ${err.message}`, 'error')
      } finally {
        loading.value = false
      }
    }

    // 🟢 ADD MEDICINE TO SUPABASE
    const addMedicine = async (newMedicine) => {
      console.log('=== ADDING MEDICINE TO SUPABASE ===')
      console.log('New medicine data:', JSON.stringify(newMedicine, null, 2))
      loading.value = true

      try {
        // Prepare data for Supabase (convert field names if needed)
        const medicineData = {
          name: newMedicine.name,
          quantity: parseInt(newMedicine.quantity),
          date_added: newMedicine.dateAdded || new Date().toISOString().split('T')[0],
          expiration_date: newMedicine.expirationDate,
          status: newMedicine.status || 'Active'
        }

        console.log('📤 Sending to Supabase:', medicineData)

        const { data, error: insertError } = await supabase
          .from('medicine')
          .insert([medicineData])
          .select()

        if (insertError) {
          console.error('❌ Error adding medicine:', insertError)
          throw insertError
        }

        console.log('✅ Medicine added successfully:', data)
        
        // Refresh the medicines list
        await getMedicines()
        
        // Close modal
        showAddMedicineModal.value = false
        
        showNotificationModal(`Medicine "${newMedicine.name}" added successfully!`, 'success')
      } catch (err) {
        console.error('❌ Failed to add medicine:', err)
        showNotificationModal(`Failed to add medicine: ${err.message}`, 'error')
      } finally {
        loading.value = false
      }
    }

    // 🟢 UPDATE MEDICINE IN SUPABASE
    const updateMedicine = async (updatedMedicine) => {
      console.log('=== UPDATING MEDICINE IN SUPABASE ===')
      console.log('Updated medicine data:', JSON.stringify(updatedMedicine, null, 2))
      loading.value = true

      try {
        // Prepare data for Supabase
        const medicineData = {
          name: updatedMedicine.name,
          quantity: parseInt(updatedMedicine.quantity),
          date_added: updatedMedicine.dateAdded || updatedMedicine.date_added,
          expiration_date: updatedMedicine.expirationDate || updatedMedicine.expiration_date,
          status: updatedMedicine.status || 'Active'
        }

        console.log(`📤 Updating medicine ID ${updatedMedicine.id} in Supabase:`, medicineData)

        const { data, error: updateError } = await supabase
          .from('medicine')
          .update(medicineData)
          .eq('id', updatedMedicine.id)
          .select()

        if (updateError) {
          console.error('❌ Error updating medicine:', updateError)
          throw updateError
        }

        if (!data || data.length === 0) {
          console.warn('⚠️ Update returned no rows. Possible RLS policy issue.')
          throw new Error('Update did not return any rows. Check RLS policies.')
        }

        console.log('✅ Medicine updated successfully:', data)
        
        // Refresh the medicines list
        await getMedicines()
        
        // Close modal
        closeViewMedicineModal()
        
        showNotificationModal(`Medicine "${updatedMedicine.name}" updated successfully!`, 'success')
      } catch (err) {
        console.error('❌ Failed to update medicine:', err)
        showNotificationModal(`Failed to update medicine: ${err.message}`, 'error')
      } finally {
        loading.value = false
      }
    }

    // 🟢 DELETE MEDICINE FROM SUPABASE (Optional - if you want delete functionality)
    const deleteMedicine = async (medicineId) => {
      console.log(`=== DELETING MEDICINE ID ${medicineId} FROM SUPABASE ===`)
      loading.value = true

      try {
        const { error: deleteError } = await supabase
          .from('medicine')
          .delete()
          .eq('id', medicineId)

        if (deleteError) {
          console.error('❌ Error deleting medicine:', deleteError)
          throw deleteError
        }

        console.log('✅ Medicine deleted successfully')
        
        // Refresh the medicines list
        await getMedicines()
        
        showNotificationModal('Medicine deleted successfully!', 'success')
      } catch (err) {
        console.error('❌ Failed to delete medicine:', err)
        showNotificationModal(`Failed to delete medicine: ${err.message}`, 'error')
      } finally {
        loading.value = false
      }
    }

    // Modal handlers
    const openAddMedicineModal = () => {
      showAddMedicineModal.value = true
    }

    const viewMedicine = (medicine) => {
      console.log('=== VIEW MEDICINE CLICKED ===')
      console.log('Medicine data:', medicine)
      
      // Convert snake_case to camelCase for the modal
      selectedMedicine.value = {
        id: medicine.id,
        name: medicine.name,
        quantity: medicine.quantity,
        dateAdded: medicine.date_added,
        expirationDate: medicine.expiration_date,
        status: medicine.status
      }
      
      showViewMedicineModal.value = true
    }

    const closeViewMedicineModal = () => {
      console.log('=== CLOSE VIEW MEDICINE MODAL ===')
      showViewMedicineModal.value = false
      selectedMedicine.value = null
    }

    const showValidationError = (message) => {
      console.log('❌ Validation error:', message)
      showNotificationModal(message, 'warning')
    }
    
    const showNotificationModal = (message, type = 'info') => {
      notificationMessage.value = message
      notificationType.value = type
      showNotification.value = true
    }

    // Computed property for filtered medicines
    const filteredMedicines = computed(() => {
      let filtered = medicines.value

      // Apply table search
      if (tableSearch.value) {
        const search = tableSearch.value.toLowerCase()
        filtered = filtered.filter(m =>
          m.name.toLowerCase().includes(search) ||
          m.id.toString().includes(search) ||
          m.status.toLowerCase().includes(search)
        )
      }

      return filtered
    })

    // Fetch medicines on component mount
    onMounted(async () => {
      console.log('=== MEDICINE COMPONENT MOUNTED ===')
      await fetchUserData()
      await getMedicines()
    })

    // Return everything for the template
    return {
      globalSearch,
      tableSearch,
      showProfileModal,
      showAddMedicineModal,
      showViewMedicineModal,
      selectedMedicine,
      medicines,
      loading,
      error,
      filteredMedicines,
      getMedicines,
      addMedicine,
      updateMedicine,
      deleteMedicine,
      openAddMedicineModal,
      viewMedicine,
      closeViewMedicineModal,
      showValidationError,
      showNotification,
      notificationMessage,
      notificationType,
      userName
    }
  },
  // Setup-based component - reactive state and computed properties are returned from setup()
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
  border-color: #10b981;
  box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
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

.add-medicine-btn {
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

.add-medicine-btn:hover {
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
  accent-color: #10b981;
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
  width: 250px;
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

.medicine-table {
  width: 100%;
  border-collapse: collapse;
}

.medicine-table thead {
  position: sticky;
  top: 0;
  background: #f9fafb;
  z-index: 10;
}

.medicine-table th {
  padding: 12px 16px;
  text-align: left;
  font-size: 12px;
  font-weight: 600;
  color: #374151;
  text-transform: uppercase;
  border-bottom: 2px solid #e5e7eb;
}

.medicine-table tbody tr {
  transition: background 0.2s ease;
}

.medicine-table tbody tr:hover {
  background: #f9fafb;
}

.medicine-table tbody tr:nth-child(even) {
  background: #fafafa;
}

.medicine-table tbody tr:nth-child(even):hover {
  background: #f3f4f6;
}

.medicine-table td {
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

.status-badge.low {
  background: #f59e0b;
  color: white;
}

/* Action Button */
.action-btn {
  background: none;
  border: none;
  font-size: 20px;
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

  .add-medicine-btn {
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
