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
        <router-link to="/consultations" class="nav-item">
          <i class="icon" aria-hidden="true">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M19 3H5C3.89543 3 3 3.89543 3 5V19C3 20.1046 3.89543 21 5 21H19C20.1046 21 21 20.1046 21 19V5C21 3.89543 20.1046 3 19 3Z" stroke="currentColor" stroke-width="2" fill="none"/>
              <path d="M9 7H15M9 12H15M9 17H12" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
            </svg>
          </i>
          <span>Consultations</span>
        </router-link>
        <router-link to="/transactions" class="nav-item active">
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

      <!-- Add Transaction Modal -->
      <AddTransaction :show="showAddTransactionModal" @close="showAddTransactionModal = false" @add-transaction="handleAddTransaction" />

      <!-- Edit Transaction Modal -->
      <EditTransaction 
        :show="showEditTransactionModal" 
        :transaction="selectedTransaction" 
        @close="showEditTransactionModal = false" 
        @update-transaction="handleUpdateTransaction"
        @delete-transaction="handleDeleteTransaction"
      />

      <!-- Transactions Content -->
      <div class="page-content">
        <!-- Page Header with Title and Actions -->
        <div class="page-header-section">
          <div class="title-and-filters">
            <h2 class="page-title">Transactions</h2>
            <div class="filter-chips">
              <button class="filter-chip active" aria-label="Show all transactions">
                All
              </button>
            </div>
          </div>

          <div class="header-actions">
            <div class="search-control-inline">
              <i class="search-icon-inline">🔍</i>
              <input type="text" v-model="tableSearch" placeholder="Search transactions..." aria-label="Search transactions" />
            </div>
            <button class="add-transaction-btn" @click="addTransaction">
              + Add Transactions
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
              Showing {{ filteredTransactions.length }} transaction{{ filteredTransactions.length !== 1 ? 's' : '' }}
            </div>
          </div>

          <!-- Scrollable Table -->
          <div class="table-scroll">
            <table class="transactions-table">
              <thead>
                <tr>
                  <th>PATIENT</th>
                  <th>PURPOSE</th>
                  <th>DATE</th>
                  <th>TIME START</th>
                  <th>TIME END</th>
                  <th>TIME SPENT</th>
                  <th>STATUS</th>
                  <th>ACTION</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="transaction in filteredTransactions" :key="transaction.id">
                  <td>
                    <div class="patient-cell">
                      <img :src="transaction.patientAvatar" :alt="transaction.patientName" class="patient-avatar" />
                      <span>{{ transaction.patientName }}</span>
                    </div>
                  </td>
                  <td>{{ transaction.purpose }}</td>
                  <td>{{ transaction.date }}</td>
                  <td>{{ transaction.timeStart }}</td>
                  <td>{{ transaction.timeEnd }}</td>
                  <td>{{ transaction.timeSpent }}</td>
                  <td>
                    <span :class="['status-badge', transaction.status.toLowerCase()]">
                      {{ transaction.status }}
                    </span>
                  </td>
                  <td>
                    <div class="action-buttons">
                      <button class="action-btn view-btn" @click="viewTransaction(transaction)" title="View/Edit Details">
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
import AddTransaction from '../components/AddTransaction.vue'
import EditTransaction from '../components/EditTransaction.vue'
import NotificationModal from '../components/NotificationModal.vue'
import NurseProfileImg from '@/assets/NurseProfile.jpg'

export default {
  name: 'TransactionsPage',
  components: {
    Profile,
    AddTransaction,
    EditTransaction,
    NotificationModal
  },
  data() {
    return {
      globalSearch: '',
      tableSearch: '',
      showProfileModal: false,
      showAddTransactionModal: false,
      showEditTransactionModal: false,
      selectedTransaction: {},
      userName: 'User',
      transactions: [],
      isLoading: false,
      error: null,
      showNotification: false,
      notificationMessage: '',
      notificationType: 'info',
      dummyTransactions: [
        {
          id: 1,
          patientAvatar: NurseProfileImg,
          patientName: 'Ella Mai',
          purpose: 'Dental Check-Up & Treatment',
          date: '2024-09-10',
          timeStart: '12:30:11',
          timeEnd: '12:32:09',
          timeSpent: '2 Mins',
          status: 'Done'
        },
        {
          id: 2,
          patientAvatar: NurseProfileImg,
          patientName: 'Chris Brown',
          purpose: 'Dental Check-Up & Treatment',
          date: '2024-09-10',
          timeStart: '18:10:02',
          timeEnd: '18:20:10',
          timeSpent: '10 Mins',
          status: 'Done'
        },
        {
          id: 3,
          patientAvatar: NurseProfileImg,
          patientName: 'Olivia Rodrigo',
          purpose: 'Urinalysis Test',
          date: '2024-09-10',
          timeStart: '18:17:10',
          timeEnd: '18:30:10',
          timeSpent: '13 Mins',
          status: 'Done'
        },
        {
          id: 4,
          patientAvatar: NurseProfileImg,
          patientName: 'Central Cee',
          purpose: 'Medical Certificate Issuance',
          date: '2024-09-10',
          timeStart: '19:08:05',
          timeEnd: '20:02:05',
          timeSpent: '1 Hour',
          status: 'Done'
        },
        {
          id: 5,
          patientAvatar: NurseProfileImg,
          patientName: 'Sabrina Carpenter',
          purpose: 'Medical Consultation',
          date: '2024-09-10',
          timeStart: '20:13:15',
          timeEnd: '20:30:15',
          timeSpent: '7 Mins',
          status: 'Done'
        }
      ]
    }
  },
  async created() {
    await this.fetchUserData()
    await this.fetchTransactions()
  },
  methods: {
    async fetchUserData() {
      try {
        const { supabase } = await import('../supabaseClient')
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
    async fetchTransactions() {
      console.log('=== FETCHING TRANSACTIONS FROM SUPABASE ===')
      this.isLoading = true
      this.error = null
      
      try {
        const { supabase } = await import('../supabaseClient')
        const { data, error: fetchError } = await supabase
          .from('transactions')
          .select('*')
          .order('date', { ascending: false })
          .order('time_start', { ascending: false })
        
        if (fetchError) {
          console.error('❌ Error fetching transactions:', fetchError)
          this.error = fetchError.message
          throw fetchError
        }
        
        console.log(`✅ Successfully fetched ${data.length} transactions`)
        this.transactions = data.map(t => ({
          id: t.id,
          patientAvatar: NurseProfileImg,
          patientName: t.patient_name,
          purpose: t.purpose,
          date: t.date,
          timeStart: t.time_start,
          timeEnd: t.time_end,
          timeSpent: t.time_spent,
          status: t.status,
          notes: t.notes
        }))
      } catch (err) {
        console.error('❌ Failed to fetch transactions:', err)
        this.error = err.message
      } finally {
        this.isLoading = false
      }
    },
    
    async handleAddTransaction(newTransaction) {
      console.log('=== ADDING TRANSACTION TO SUPABASE ===')
      this.isLoading = true
      
      try {
        const { supabase } = await import('../supabaseClient')
        
        const transactionData = {
          patient_name: newTransaction.patientName,
          purpose: newTransaction.purpose,
          date: newTransaction.date,
          time_start: newTransaction.timeStart,
          time_end: newTransaction.timeEnd,
          time_spent: newTransaction.timeSpent,
          status: newTransaction.status || 'Done',
          notes: newTransaction.notes || ''
        }
        
        console.log('📤 Sending to Supabase:', transactionData)
        
        const { data, error: insertError } = await supabase
          .from('transactions')
          .insert([transactionData])
          .select()
        
        if (insertError) {
          console.error('❌ Error adding transaction:', insertError)
          throw insertError
        }
        
        console.log('✅ Transaction added successfully:', data)
        
        this.showNotificationModal('Transaction added successfully!', 'success')
        await this.fetchTransactions()
        this.showAddTransactionModal = false
      } catch (err) {
        console.error('❌ Failed to add transaction:', err)
        this.showNotificationModal(`Failed to add transaction: ${err.message}`, 'error')
      } finally {
        this.isLoading = false
      }
    },
    
    async handleUpdateTransaction(updatedTransaction) {
      console.log('=== UPDATING TRANSACTION IN SUPABASE ===')
      this.isLoading = true
      
      try {
        const { supabase } = await import('../supabaseClient')
        
        const transactionData = {
          patient_name: updatedTransaction.patientName,
          purpose: updatedTransaction.purpose,
          date: updatedTransaction.date,
          time_start: updatedTransaction.timeStart,
          time_end: updatedTransaction.timeEnd,
          time_spent: updatedTransaction.timeSpent,
          status: updatedTransaction.status,
          notes: updatedTransaction.notes || ''
        }
        
        console.log(`📤 Updating transaction ID ${updatedTransaction.id}:`, transactionData)
        
        const { data, error: updateError } = await supabase
          .from('transactions')
          .update(transactionData)
          .eq('id', updatedTransaction.id)
          .select()
        
        if (updateError) {
          console.error('❌ Error updating transaction:', updateError)
          throw updateError
        }
        
        console.log('✅ Transaction updated successfully:', data)
        
        this.showNotificationModal('Transaction updated successfully!', 'success')
        await this.fetchTransactions()
        this.showEditTransactionModal = false
      } catch (err) {
        console.error('❌ Failed to update transaction:', err)
        this.showNotificationModal(`Failed to update transaction: ${err.message}`, 'error')
      } finally {
        this.isLoading = false
      }
    },
    
    async handleDeleteTransaction(transactionId) {
      console.log(`=== DELETING TRANSACTION ID ${transactionId} FROM SUPABASE ===`)
      this.isLoading = true
      
      try {
        const { supabase } = await import('../supabaseClient')
        
        const { error: deleteError } = await supabase
          .from('transactions')
          .delete()
          .eq('id', transactionId)
        
        if (deleteError) {
          console.error('❌ Error deleting transaction:', deleteError)
          throw deleteError
        }
        
        console.log('✅ Transaction deleted successfully')
        
        this.showNotificationModal('Transaction deleted successfully!', 'success')
        await this.fetchTransactions()
        this.showEditTransactionModal = false
      } catch (err) {
        console.error('❌ Failed to delete transaction:', err)
        this.showNotificationModal(`Failed to delete transaction: ${err.message}`, 'error')
      } finally {
        this.isLoading = false
      }
    },
    
    viewTransaction(transaction) {
      this.selectedTransaction = { ...transaction }
      this.showEditTransactionModal = true
    },
    
    addTransaction() {
      this.showAddTransactionModal = true
    },
    
    showNotificationModal(message, type = 'info') {
      this.notificationMessage = message
      this.notificationType = type
      this.showNotification = true
    },
    async fetchUserData() {
      try {
        const { supabase } = await import('../supabaseClient')
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
    }
  },
  computed: {
    filteredTransactions() {
      let filtered = this.transactions

      // Filter by table search
      if (this.tableSearch.trim()) {
        const search = this.tableSearch.toLowerCase()
        filtered = filtered.filter(t => 
          t.patientName.toLowerCase().includes(search) ||
          t.purpose.toLowerCase().includes(search) ||
          t.date.includes(search) ||
          t.status.toLowerCase().includes(search)
        )
      }

      return filtered
    }
  },
  async created() {
    await this.fetchUserData()
    await this.fetchTransactions()
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
  border: 2px solid #e5e7eb;
  background: white;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  color: #64748b;
}

.filter-chip:hover {
  border-color: #cbd5e1;
  transform: translateY(-1px);
}

.filter-chip.active {
  background: linear-gradient(135deg, #ec4899 0%, #d946ef 100%);
  border-color: transparent;
  color: white;
  box-shadow: 0 4px 12px rgba(236, 72, 153, 0.25);
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
  border-color: #ec4899;
  box-shadow: 0 0 0 3px rgba(236, 72, 153, 0.1);
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

.add-transaction-btn {
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

.add-transaction-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(236, 72, 153, 0.4);
}

/* Filter Section - OLD, keeping for reference if needed */
.filter-section {
  display: none; /* Hidden in favor of filter-chips */
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

/* Page Header - OLD */
.page-header {
  display: none; /* Hidden in favor of page-header-section */
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
  accent-color: #ec4899;
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

.transactions-table {
  width: 100%;
  border-collapse: collapse;
}

.transactions-table thead {
  position: sticky;
  top: 0;
  background: #f9fafb;
  z-index: 10;
}

.transactions-table th {
  padding: 12px 16px;
  text-align: left;
  font-size: 12px;
  font-weight: 600;
  color: #374151;
  text-transform: uppercase;
  border-bottom: 2px solid #e5e7eb;
}

.transactions-table tbody tr {
  transition: background 0.2s ease;
}

.transactions-table tbody tr:hover {
  background: #f9fafb;
}

.transactions-table tbody tr:nth-child(even) {
  background: #fafafa;
}

.transactions-table tbody tr:nth-child(even):hover {
  background: #f3f4f6;
}

.transactions-table td {
  padding: 14px 16px;
  font-size: 13px;
  color: #4b5563;
  border-bottom: 1px solid #e5e7eb;
}

/* Patient Cell with Avatar */
.patient-cell {
  display: flex;
  align-items: center;
  gap: 10px;
}

.patient-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #ec4899;
}

.patient-cell span {
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

.status-badge.done {
  background: #10b981;
  color: white;
}

.status-badge.pending {
  background: #f59e0b;
  color: white;
}

.status-badge.cancelled {
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

  .title-and-filters {
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

  .filter-chips {
    overflow-x: auto;
    scrollbar-width: none;
    -ms-overflow-style: none;
  }

  .filter-chips::-webkit-scrollbar {
    display: none;
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

  .add-transaction-btn {
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
}
</style>
