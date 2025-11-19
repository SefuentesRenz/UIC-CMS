<template>
  <div class="login-container">
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

    <!-- Right side with login form -->
    <div class="right-section">
      <div class="login-card">
        <h2 class="welcome-title">Welcome {{ accountType }}!</h2>
        <p class="subtitle">Login To Continue</p>

        <!-- Account Type Selection -->
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

        <form @submit.prevent="handleLogin" class="login-form">
          <div class="form-group">
            <label for="email">Email:</label>
            <div class="input-wrapper">
              <input
                id="email"
                v-model="email"
                type="email"
                placeholder="Enter your email"
                required
              />
              <button type="button" class="toggle-visibility" @click="toggleEmailVisibility">
                <span v-if="showEmail">👁️</span>
                <span v-else>👁️‍🗨️</span>
              </button>
            </div>
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

          <!-- Error message display -->
          <div v-if="errorMessage" class="error-message">
            {{ errorMessage }}
          </div>

          <button type="submit" class="login-button" :disabled="isLoading">
            {{ isLoading ? 'Logging in...' : 'Login' }}
          </button>
        </form>

        <p class="signup-text">
          If You Didn't Have Account 
          <a href="#" @click.prevent="goToSignup" class="signup-link">Sign-Up</a>
        </p>
      </div>
    </div>
  </div>
</template>

<script>
// Import Supabase client for authentication
import { supabase } from '@/lib/Supabase.js'

export default {
  name: 'LoginPage',
  data() {
    return {
      email: '',
      password: '',
      accountType: 'Student', // Default to Student login
      showPassword: false,
      showEmail: false,
      isLoading: false, // Track loading state during login
      errorMessage: '', // Store error messages
      userProfile: null // Store user profile data after successful login
    }
  },
  methods: {
    /**
     * Toggle password visibility in the password input field
     */
    togglePasswordVisibility() {
      this.showPassword = !this.showPassword
    },
    
    /**
     * Toggle email visibility in the email input field
     */
    toggleEmailVisibility() {
      this.showEmail = !this.showEmail
    },
    
    /**
     * Handle user login with Supabase authentication
     * This authenticates the user and fetches their profile data
     */
    async handleLogin() {
      // ============================================
      // Step 1: Client-side validation
      // ============================================
      
      // Clear any previous error messages
      this.errorMessage = ''
      
      // Validate that both email and password are provided
      if (!this.email || !this.password) {
        this.errorMessage = 'Please enter both email and password'
        return
      }

      // Validate email format
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      if (!emailRegex.test(this.email)) {
        this.errorMessage = 'Please enter a valid email address'
        return
      }

      // ============================================
      // Step 2: Authenticate with Supabase
      // ============================================
      
      try {
        this.isLoading = true // Show loading state (can be used to disable button)
        
        // Attempt to sign in with email and password using Supabase Auth
        const { data: { session }, error: authError } = await supabase.auth.signInWithPassword({
          email: this.email,
          password: this.password
        })

        if (authError) {
          throw authError
        }

        if (!session) {
          throw new Error('Failed to create session')
        }

        // Check if profile exists
        const { error: checkError } = await supabase
          .from('profiles')
          .select('id')
          .eq('id', session.user.id)
          .single()

        if (checkError && checkError.code === 'PGRST116') {
          // Profile doesn't exist, create it
          try {
            const { error: createError } = await supabase
              .from('profiles')
              .insert([
                { 
                  id: session.user.id,
                  email: session.user.email,
                  full_name: '',
                  school_id: '',
                  role: ''
                }
              ])

            if (createError) throw createError
          } catch (createErr) {
            // Common cause: row-level security (RLS) policy prevents insert
            console.error('Error creating profile:', createErr)
            if (createErr?.message?.includes('row-level security') || createErr?.code === 'PGRST116') {
              this.errorMessage = 'Unable to create profile due to database security rules (RLS). Please check your Supabase RLS policy for `profiles`.'
            } else {
              this.errorMessage = `Failed to create profile: ${createErr.message || createErr}`
            }
            this.isLoading = false
            return
          }
        }

        // Ensure the Supabase client has the session set for subsequent requests
        try {
          await supabase.auth.setSession({
            access_token: session.access_token,
            refresh_token: session.refresh_token
          })
        } catch (setErr) {
          // Non-fatal: continue but log it
          console.warn('supabase.auth.setSession failed:', setErr)
        }

        const user = session?.user
        if (!user) {
          this.errorMessage = 'Login failed: No user data returned'
          this.isLoading = false
          return
        }

        console.log('Login successful! User ID:', user.id)
        console.log('User email:', user.email)

        // ============================================
        // Step 3: Fetch user profile from database
        // ============================================
        
        // Fetch the user's profile data from the profiles table
        const { data: profileData, error: profileError } = await supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .single()

        if (profileError) {
          console.warn('Profile fetch error:', profileError)
          // If the profile fetch failed due to auth/session issues, show a message
          if (profileError?.message?.includes('row-level security')) {
            this.errorMessage = 'Cannot read profile due to database security rules (RLS). Please ensure authenticated access.'
          } else {
            console.log('Continuing with login despite profile fetch error')
          }
          // Default to dashboard if profile fetch fails
          this.$router.push('/dashboard')
          return
        }

        // Store profile data for use in the application
        this.userProfile = profileData
        console.log('User profile loaded:', profileData)
        
        // You can store this in Vuex/Pinia store or localStorage if needed
        localStorage.setItem('userProfile', JSON.stringify(profileData))

        // ============================================
        // Step 4: Account type based redirect
        // ============================================
        
        console.log('Selected account type:', this.accountType)
        console.log('User role from database:', profileData.role)
        
        // Redirect based on selected account type
        if (this.accountType === 'Student') {
          // Verify user is actually a student
          if (profileData.role !== 'Student') {
            this.errorMessage = 'This account is not a student account. Please select Admin mode.'
            this.isLoading = false
            return
          }
          console.log('Redirecting to Student Home...')
          this.$router.push('/student-home')
        } else {
          // Admin mode - verify user is staff/nurse/admin
          if (profileData.role === 'Student') {
            this.errorMessage = 'This is a student account. Please select Student mode to login.'
            this.isLoading = false
            return
          }
          console.log('Redirecting to Dashboard...')
          this.$router.push('/dashboard')
        }
        
      } catch (error) {
        // Handle any unexpected errors
        console.error('Unexpected error during login:', error)
        this.errorMessage = `An unexpected error occurred: ${error.message}`
        alert(this.errorMessage)
      } finally {
        // Always reset loading state
        this.isLoading = false
      }
    },
    
    /**
     * Navigate to the signup page
     */
    goToSignup() {
      this.$router.push('/signup')
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

.login-container {
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
  padding: 60px 40px;
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
  width: 350px;
  height: 350px;
  background: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3), 0 0 0 1px rgba(255, 255, 255, 0.1);
  margin-bottom: 50px;
  position: relative;
  z-index: 1;
  transition: transform 0.3s ease;
}

.logo-circle:hover {
  transform: scale(1.05);
}

.logo-content {
  text-align: center;
  padding: 30px;
}

.logo-title {
  font-size: 42px;
  font-weight: 800;
  color: #7c2d5e;
  margin: 0 0 15px 0;
  letter-spacing: 3px;
}

.nurse-image {
  width: 140px;
  height: auto;
  margin: 15px 0;
  object-fit: contain;
  filter: drop-shadow(0 4px 12px rgba(0, 0, 0, 0.1));
}

.since-text {
  font-size: 16px;
  color: #64748b;
  margin: 15px 0 0 0;
  font-weight: 500;
  letter-spacing: 1px;
}

.branding {
  position: relative;
  z-index: 1;
}

.branding h1 {
  color: white;
  font-size: 28px;
  font-weight: 700;
  margin: 10px 0;
  text-align: center;
  text-transform: uppercase;
  letter-spacing: 2px;
  text-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
  line-height: 1.4;
}

/* Right Section - Modern Form */
.right-section {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 60px 40px;
}

.login-card {
  background: white;
  border-radius: 24px;
  padding: 50px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.08), 0 2px 8px rgba(0, 0, 0, 0.04);
  max-width: 480px;
  width: 100%;
  border: 1px solid rgba(148, 163, 184, 0.1);
}

.welcome-title {
  font-size: 32px;
  font-weight: 700;
  color: #1e293b;
  margin: 0 0 8px 0;
  text-align: left;
}

.welcome-title::after {
  content: '';
  display: block;
  width: 60px;
  height: 4px;
  background: linear-gradient(90deg, #ec4899, #d946ef);
  margin-top: 16px;
  border-radius: 2px;
}

.subtitle {
  font-size: 16px;
  color: #64748b;
  margin: 16px 0 0 0;
  text-align: left;
  font-weight: 500;
}

/* Account Type Toggle */
.account-type-toggle {
  display: flex;
  gap: 12px;
  margin: 24px 0;
  padding: 6px;
  background: #f1f5f9;
  border-radius: 12px;
}

.type-btn {
  flex: 1;
  padding: 12px 24px;
  background: transparent;
  border: none;
  border-radius: 8px;
  font-size: 15px;
  font-weight: 600;
  color: #64748b;
  cursor: pointer;
  transition: all 0.3s ease;
}

.type-btn:hover {
  color: #475569;
  background: rgba(255, 255, 255, 0.5);
}

.type-btn.active {
  background: linear-gradient(135deg, #ec4899 0%, #d946ef 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(236, 72, 153, 0.3);
}

.login-form {
  margin-top: 32px;
  margin-bottom: 24px;
}

.form-group {
  margin-bottom: 24px;
}

.form-group label {
  display: block;
  font-size: 14px;
  font-weight: 600;
  color: #475569;
  margin-bottom: 8px;
  letter-spacing: 0.3px;
}

.input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.input-wrapper input {
  width: 100%;
  padding: 13px 50px 13px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 10px;
  font-size: 15px;
  background: #f8fafc;
  color: #1e293b;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  font-family: inherit;
}

.input-wrapper input:hover {
  border-color: #cbd5e1;
  background: white;
}

.input-wrapper input:focus {
  outline: none;
  background: white;
  border-color: #ec4899;
  box-shadow: 0 0 0 4px rgba(236, 72, 153, 0.1);
}

.input-wrapper input::placeholder {
  color: #94a3b8;
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

/* Error message */
.error-message {
  background: #fee2e2;
  border: 1px solid #fca5a5;
  color: #dc2626;
  padding: 12px 16px;
  border-radius: 8px;
  font-size: 14px;
  margin-bottom: 16px;
  text-align: left;
  font-weight: 500;
}

.login-button {
  width: 100%;
  padding: 15px;
  background: linear-gradient(135deg, #ec4899 0%, #d946ef 100%);
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-top: 8px;
  letter-spacing: 0.5px;
  box-shadow: 0 4px 12px rgba(236, 72, 153, 0.3);
}

.login-button:hover {
  background: linear-gradient(135deg, #d946ef 0%, #c026d3 100%);
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(236, 72, 153, 0.4);
}

.login-button:active {
  transform: translateY(0);
}

.login-button:disabled {
  background: #94a3b8;
  cursor: not-allowed;
  box-shadow: none;
  opacity: 0.6;
  transform: none;
}

.signup-text {
  text-align: center;
  font-size: 14px;
  color: #64748b;
  margin: 0;
}

.signup-link {
  color: #ec4899;
  font-weight: 600;
  text-decoration: none;
  transition: color 0.2s ease;
}

.signup-link:hover {
  color: #d946ef;
  text-decoration: underline;
}

/* Responsive Design */
@media (max-width: 1024px) {
  .login-container {
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
  
  .login-card {
    padding: 40px 30px;
  }
  
  .welcome-title {
    font-size: 28px;
  }
}

@media (max-width: 480px) {
  .login-card {
    padding: 30px 24px;
  }
  
  .welcome-title {
    font-size: 24px;
  }
  
  .form-group {
    margin-bottom: 20px;
  }
}
</style>
