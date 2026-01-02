<template>
  <div class="signup-container">
    <!-- Notification Modal -->
    <NotificationModal 
      :show="showNotification" 
      :message="notificationMessage" 
      :type="notificationType"
      @close="showNotification = false" />
    
    <!-- Left side with logo and branding -->
    <div class="left-section">
      <div class="logo-circle">
        <div class="logo-content">
          <h2 class="logo-title">UIC-CMS</h2>
          <img src="@/assets/logo.png" alt="UIC CMS Logo" class="nurse-image" />
          <p class="since-text">Since 2025</p>
        </div>
      </div>
      <div class="branding">
        <h1>UIC - CLINIC</h1>
        <h1>MANAGEMENT SYSTEM</h1>
      </div>
    </div>

    <!-- Right side with signup form -->
    <div class="right-section">
      <div class="signup-card">
        <h2 class="title">Create Account</h2>

        <form @submit.prevent="handleSignup" class="signup-form">
          <!-- Account Type Selection -->
          <div class="form-group">
            <label>Account Type:</label>
            <div class="account-type-toggle">
              <button
                type="button"
                :class="['type-btn', { active: accountType === 'Student' }]"
                @click="accountType = 'Student'"
              >
                 Student
              </button>
              <button
                type="button"
                :class="['type-btn', { active: accountType === 'Admin' }]"
                @click="accountType = 'Admin'"
              >
                Admin
              </button>
            </div>
          </div>

          <!-- Role Selection (only for Admin) -->
          <div class="form-group" v-if="accountType === 'Admin'">
            <label for="role">Role: <span class="required">*</span></label>
            <select
              id="role"
              v-model="role"
              class="role-select"
              required
            >
              <option value="" disabled>Select your role</option>
              <option value="Nurse">Nurse</option>
              <option value="Staff">Staff</option>
             
            </select>
          </div>

          <div class="form-group">
            <label for="name">Name:</label>
            <input
              id="name"
              v-model="name"
              type="text"
              placeholder="Enter your full name"
              required
            />
          </div>

          <div class="form-group">
            <label for="email">Email Address:</label>
            <input
              id="email"
              v-model="email"
              type="email"
              placeholder="Enter your email"
              required
            />
          </div>

          <div class="form-group">
            <label for="schoolId">School ID:</label>
            <input
              id="schoolId"
              v-model="schoolId"
              type="text"
              placeholder="Enter your school ID"
              required
            />
          </div>

          <div class="form-group">
            <label for="password">Password:</label>
            <div class="input-wrapper">
              <input
                id="password"
                v-model="password"
                :type="showPassword ? 'text' : 'password'"
                placeholder="Enter your password"
                required
              />
              <button type="button" class="toggle-visibility" @click="togglePasswordVisibility">
                <span v-if="showPassword">👁️</span>
                <span v-else>👁️‍🗨️</span>
              </button>
            </div>
          </div>

          <div class="form-group">
            <label for="confirmPassword">Confirm Password:</label>
            <div class="input-wrapper">
              <input
                id="confirmPassword"
                v-model="confirmPassword"
                :type="showConfirmPassword ? 'text' : 'password'"
                placeholder="Confirm your password"
                required
              />
              <button type="button" class="toggle-visibility" @click="toggleConfirmPasswordVisibility">
                <span v-if="showConfirmPassword">👁️</span>
                <span v-else>👁️‍🗨️</span>
              </button>
            </div>
          </div>

          <button type="submit" class="signup-button" :disabled="isLoading">
            {{ isLoading ? 'Creating Account...' : 'Sign-Up' }}
          </button>

          <!-- Centered back-to-login text with a clickable Login link -->
          <div class="back-to-login">
            <span>Already have an account?</span>
            <router-link to="/login" class="back-login-link">Login</router-link>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
// Import Supabase client for authentication and database operations
import { supabase } from '@/lib/Supabase.js'
import NotificationModal from './NotificationModal.vue'

export default {
  name: 'SignUpPage',
  components: {
    NotificationModal
  },
  data() {
    return {
      accountType: 'Student', // Default to Student
      role: '', // Role for Admin users (Nurse, Staff, Admin)
      name: '',
      email: '',
      schoolId: '',
      password: '',
      confirmPassword: '',
      showPassword: false,
      showConfirmPassword: false,
      isLoading: false, // Track loading state during signup
      showNotification: false,
      notificationMessage: '',
      notificationType: 'info'
    }
  },
  methods: {
    togglePasswordVisibility() {
      this.showPassword = !this.showPassword
    },
    toggleConfirmPasswordVisibility() {
      this.showConfirmPassword = !this.showConfirmPassword
    },
    
    /**
     * Handle user sign-up with Supabase authentication and profile creation
     * This creates both an auth user and a profile record in the database
     */
    async handleSignup() {
      // ============================================
      // Step 1: Client-side validation
      // ============================================
      
      // Validate that all required fields are filled
      if (!this.name || !this.email || !this.schoolId || !this.password || !this.confirmPassword) {
        this.showNotificationModal('Please fill in all fields', 'warning')
        return
      }

      // Validate role selection for Admin accounts
      if (this.accountType === 'Admin' && !this.role) {
        this.showNotificationModal('Please select your role (Nurse, Staff, or Admin)', 'warning')
        return
      }

      // Validate passwords match
      if (this.password !== this.confirmPassword) {
        this.showNotificationModal('Passwords do not match!', 'warning')
        return
      }

      // Validate password strength (minimum 6 characters for Supabase)
      if (this.password.length < 6) {
        this.showNotificationModal('Password must be at least 6 characters long', 'warning')
        return
      }

      // Validate email format
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      if (!emailRegex.test(this.email)) {
        this.showNotificationModal('Please enter a valid email address', 'warning')
        return
      }

      // ============================================
      // Step 2: Clear any existing session and create auth user
      // ============================================
      
      try {
        this.isLoading = true // Show loading state
        
        // Clear any existing session first
        console.log('Clearing any existing session...')
        await supabase.auth.signOut()
        
        // Determine the role based on account type
        const userRole = this.accountType === 'Student' ? 'Student' : this.role
        
        console.log('Creating account with:', {
          accountType: this.accountType,
          role: userRole,
          name: this.name,
          email: this.email
        })
        
        // Create authentication user using Supabase Auth
        // Pass user metadata that will be used by the database trigger
        const { data: authData, error: authError } = await supabase.auth.signUp({
          email: this.email,
          password: this.password,
          options: {
            data: {
              full_name: this.name,
              school_id: this.schoolId,
              role: userRole // Student or Admin role (Nurse/Staff/Admin)
            }
          }
        })

        // Handle authentication errors
        if (authError) {
          console.error('Auth signup error:', authError)
          this.showNotificationModal(`Sign-up failed: ${authError.message}`, 'error')
          this.isLoading = false
          return
        }

        // Check if user was created successfully
        if (!authData.user) {
          this.showNotificationModal('Sign-up failed: No user data returned', 'error')
          this.isLoading = false
          return
        }

        console.log('Auth user created:', authData.user.id)
        console.log('Profile automatically created via database trigger')

        // ============================================
        // Step 3: Verify session is established
        // ============================================
        // Wait a moment for the profile to be created by the trigger
        await new Promise(resolve => setTimeout(resolve, 500))
        
        // Verify the session is active for the new user
        const { data: { session }, error: sessionError } = await supabase.auth.getSession()
        
        if (sessionError || !session) {
          console.error('Session verification failed:', sessionError)
          this.showNotificationModal('Account created but session failed. Please login.', 'warning')
          this.isLoading = false
          this.$router.push('/login')
          return
        }
        
        console.log('Session verified for user:', session.user.id)
        
        // ============================================
        // Step 4: Show success and redirect based on account type
        // ============================================
        
        this.showNotificationModal(`Account created successfully as ${this.accountType}!`, 'success')
        
        // Redirect based on account type after a brief delay
        setTimeout(() => {
          if (this.accountType === 'Student') {
            console.log('Redirecting to Student Home...')
            this.$router.push('/student-home')
          } else {
            // Admin (Nurse/Staff/Admin) goes to Dashboard
            console.log('Redirecting to Dashboard...')
            this.$router.push('/dashboard')
          }
        }, 1500)
        
        
      } catch (error) {
        // Handle any unexpected errors
        console.error('Unexpected error during signup:', error)
        this.showNotificationModal(`An unexpected error occurred: ${error.message}`, 'error')
      } finally {
        // Always reset loading state
        this.isLoading = false
      }
    },
    
    /**
     * Show notification modal
     */
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
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

.signup-container {
  display: flex;
  min-height: 100vh;
  background: #f5f7fa;
  font-family: 'Inter', 'Segoe UI', -apple-system, BlinkMacSystemFont, sans-serif;
}

/* Left Section - Professional Branding */
.left-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 30px;
  background: linear-gradient(135deg, #ec4899 0%, #d946ef 100%);
  position: relative;
  overflow: hidden;
}

.left-section::before {
  content: '';
  position: absolute;
  top: -50%;
  right: -50%;
  width: 200%;
  height: 200%;
  background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
  animation: pulse 15s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); opacity: 0.3; }
  50% { transform: scale(1.1); opacity: 0.5; }
}

.logo-circle {
  width: 240px;
  height: 240px;
  background: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3), 0 0 0 1px rgba(255, 255, 255, 0.1);
  margin-bottom: 30px;
  position: relative;
  z-index: 1;
  transition: transform 0.3s ease;
}

.logo-circle:hover {
  transform: scale(1.05);
}

.logo-content {
  text-align: center;
  padding: 20px;
}

.logo-title {
  font-size: 32px;
  font-weight: 800;
  color: #7c2d5e;
  margin: 0 0 10px 0;
  letter-spacing: 2px;
}

.nurse-image {
  width: 100px;
  height: auto;
  margin: 10px 0;
  object-fit: contain;
  filter: drop-shadow(0 4px 12px rgba(0, 0, 0, 0.1));
}

.since-text {
  font-size: 14px;
  color: #64748b;
  margin: 10px 0 0 0;
  font-weight: 500;
  letter-spacing: 1px;
}

.branding {
  position: relative;
  z-index: 1;
}

.branding h1 {
  color: white;
  font-size: 22px;
  font-weight: 700;
  margin: 6px 0;
  text-align: center;
  text-transform: uppercase;
  letter-spacing: 2px;
  text-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
  line-height: 1.3;
}

/* Right Section - Modern Form */
.right-section {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px 30px;
}

.signup-card {
  background: white;
  border-radius: 20px;
  padding: 36px 40px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.08), 0 2px 8px rgba(0, 0, 0, 0.04);
  max-width: 460px;
  width: 100%;
  border: 1px solid rgba(148, 163, 184, 0.1);
}

.title {
  font-size: 28px;
  font-weight: 700;
  color: #1e293b;
  margin: 0 0 6px 0;
  text-align: left;
}

.title::after {
  content: '';
  display: block;
  width: 50px;
  height: 3px;
  background: linear-gradient(90deg, #ec4899, #d946ef);
  margin-top: 12px;
  border-radius: 2px;
}

.signup-form {
  margin-top: 24px;
}

.form-group {
  margin-bottom: 14px;
}

.form-group label {
  display: block;
  font-size: 13px;
  font-weight: 600;
  color: #475569;
  margin-bottom: 6px;
  letter-spacing: 0.2px;
}

.form-group input,
.input-wrapper input {
  width: 100%;
  padding: 11px 14px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  font-size: 14px;
  background: #f8fafc;
  color: #1e293b;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  font-family: inherit;
}

.input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.input-wrapper input {
  padding-right: 50px;
}

.form-group input:hover,
.input-wrapper input:hover {
  border-color: #cbd5e1;
  background: white;
}

.form-group input:focus,
.input-wrapper input:focus {
  outline: none;
  background: white;
  border-color: #ec4899;
  box-shadow: 0 0 0 4px rgba(236, 72, 153, 0.1);
}

.form-group input::placeholder,
.input-wrapper input::placeholder {
  color: #94a3b8;
}

/* Account Type Toggle */
.account-type-toggle {
  display: flex;
  gap: 12px;
  margin-top: 6px;
}

.type-btn {
  flex: 1;
  padding: 12px 16px;
  border: 2px solid #e2e8f0;
  background: #f8fafc;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  color: #475569;
  cursor: pointer;
  transition: all 0.3s ease;
  font-family: inherit;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.type-btn:hover {
  border-color: #cbd5e1;
  background: white;
}

.type-btn.active {
  background: linear-gradient(135deg, #ec4899 0%, #d946ef 100%);
  color: white;
  border-color: #ec4899;
  box-shadow: 0 4px 12px rgba(236, 72, 153, 0.3);
}

/* Role Select Dropdown */
.role-select {
  width: 100%;
  padding: 11px 14px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  font-size: 14px;
  background: #f8fafc;
  color: #1e293b;
  font-family: inherit;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%2364748b' d='M6 9L1 4h10z'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 14px center;
  padding-right: 40px;
}

.role-select:hover {
  border-color: #cbd5e1;
  background-color: white;
}

.role-select:focus {
  outline: none;
  background-color: white;
  border-color: #ec4899;
  box-shadow: 0 0 0 4px rgba(236, 72, 153, 0.1);
}

.role-select option {
  background: white;
  color: #1e293b;
  padding: 10px;
}

.required {
  color: #ef4444;
  font-weight: 700;
}

.toggle-visibility {
  position: absolute;
  right: 14px;
  background: transparent;
  border: none;
  cursor: pointer;
  font-size: 18px;
  padding: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
  border-radius: 6px;
  color: #64748b;
}

.toggle-visibility:hover {
  background: #fce7f3;
  color: #ec4899;
}

.signup-button {
  width: 100%;
  padding: 13px;
  background: linear-gradient(135deg, #ec4899 0%, #d946ef 100%);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-top: 6px;
  letter-spacing: 0.5px;
  box-shadow: 0 4px 12px rgba(236, 72, 153, 0.3);
}

.signup-button:hover:not(:disabled) {
  background: linear-gradient(135deg, #d946ef 0%, #c026d3 100%);
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(236, 72, 153, 0.4);
}

.signup-button:active:not(:disabled) {
  transform: translateY(0);
}

.signup-button:disabled {
  background: #94a3b8;
  cursor: not-allowed;
  box-shadow: none;
  opacity: 0.6;
}

/* Back to login section */
.back-to-login {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin-top: 12px;
  font-size: 13px;
  color: #475569;
}

.back-login-link {
  color: #ec4899;
  font-weight: 700;
  text-decoration: none;
  padding: 6px 10px;
  border-radius: 6px;
  transition: all 0.15s ease-in-out;
}

.back-login-link:hover {
  background: rgba(217, 70, 239, 0.08);
  transform: translateY(-1px);
  text-decoration: underline;
}

/* Responsive Design */
@media (max-width: 1024px) {
  .signup-container {
    flex-direction: column;
  }
  
  .left-section {
    padding: 40px 30px;
    min-height: 40vh;
  }
  
  .logo-circle {
    width: 220px;
    height: 220px;
    margin-bottom: 30px;
  }
  
  .logo-title {
    font-size: 36px;
  }
  
  .nurse-image {
    width: 110px;
  }
  
  .branding h1 {
    font-size: 24px;
  }
  
  .right-section {
    padding: 40px 20px;
  }
  
  .signup-card {
    padding: 40px 30px;
  }
  
  .title {
    font-size: 28px;
  }
}

@media (max-width: 480px) {
  .signup-card {
    padding: 30px 24px;
  }
  
  .title {
    font-size: 24px;
  }
  
  .form-group {
    margin-bottom: 20px;
  }
}
</style>
