# Testing Supabase Authentication

This guide explains how to test the login and signup functionality with Supabase authentication.

---

## 🔐 What Was Implemented

### SignUp Page (`src/components/SignUp.vue`)
- ✅ Creates new user accounts using `supabase.auth.signUp()`
- ✅ Stores user metadata (name, school_id, role) in auth system
- ✅ Automatically creates profile record via database trigger
- ✅ Validates email format and password strength
- ✅ Checks password confirmation match
- ✅ Shows loading state during signup
- ✅ Redirects to login page after successful signup

### Login Page (`src/components/Login.vue`)
- ✅ Authenticates users using `supabase.auth.signInWithPassword()`
- ✅ Fetches user profile data from `profiles` table after login
- ✅ Validates email format before submitting
- ✅ Shows user-friendly error messages for common issues
- ✅ Displays loading state during authentication
- ✅ Redirects to dashboard (`/dashboard`) on successful login
- ✅ Stores user profile data in component state

---

## 🧪 How to Test Locally

### Prerequisites
Make sure your Supabase project is set up correctly:

1. **Database Trigger for Profile Creation** (required for signup to work):
   - Go to your Supabase Dashboard → SQL Editor
   - Run this SQL to create the automatic profile creation trigger:

```sql
-- Create a trigger function to automatically create a profile when a user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, school_id, role, email)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'school_id',
    COALESCE(NEW.raw_user_meta_data->>'role', 'user'),
    NEW.email
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

2. **Check RLS Policies**:
   - Ensure your `profiles` table has proper Row Level Security policies
   - Users should be able to read their own profile after authentication

---

### Test Scenario 1: Create a New Account

1. **Start your development server**:
   ```bash
   npm run dev
   ```

2. **Navigate to the SignUp page**:
   - Open your browser to `http://localhost:3000/signup` (or your dev server URL)

3. **Fill out the signup form**:
   - **Name**: John Doe
   - **Email**: johndoe@example.com (use a real email if you want to test email verification)
   - **School ID**: 2025-12345
   - **Password**: password123 (minimum 6 characters)
   - **Confirm Password**: password123

4. **Click "Sign-Up"**:
   - ✅ You should see: "Account created successfully! Please check your email to verify your account."
   - ✅ You'll be redirected to the login page (`/login`)
   - ✅ Check the browser console for: "Auth user created: [user-id]" and "Profile automatically created via database trigger"

5. **Verify in Supabase Dashboard**:
   - Go to Authentication → Users
   - You should see the new user with the email you entered
   - Go to Table Editor → profiles
   - You should see a profile record with the same user ID, name, and school_id

---

### Test Scenario 2: Login with Valid Credentials

1. **Navigate to the Login page**:
   - Open `http://localhost:3000/login`

2. **Enter the credentials** you just created:
   - **Email**: johndoe@example.com
   - **Password**: password123

3. **Click "Login"**:
   - ✅ You should see: "Login successful! Redirecting to dashboard..."
   - ✅ You'll be redirected to `/dashboard`
   - ✅ Check the browser console for:
     - "Login successful! User ID: [user-id]"
     - "User email: johndoe@example.com"
     - "User profile loaded: {...}" (with your profile data)

---

### Test Scenario 3: Login with Invalid Credentials

1. **Navigate to the Login page**:
   - Open `http://localhost:3000/login`

2. **Enter incorrect credentials**:
   - **Email**: wrong@example.com
   - **Password**: wrongpassword

3. **Click "Login"**:
   - ❌ You should see an alert: "Invalid email or password. Please try again."
   - ❌ The page should NOT redirect
   - ✅ The error is logged in the browser console

---

### Test Scenario 4: Validation Errors

#### Test 4a: Empty Fields
1. Leave email or password blank and click "Login"
2. Expected: "Please enter both email and password"

#### Test 4b: Invalid Email Format
1. Enter email: `notanemail`
2. Enter password: `password123`
3. Click "Login"
4. Expected: "Please enter a valid email address"

#### Test 4c: Weak Password (SignUp)
1. Go to SignUp page
2. Enter password: `12345` (less than 6 characters)
3. Expected: "Password must be at least 6 characters long"

#### Test 4d: Password Mismatch (SignUp)
1. Enter password: `password123`
2. Enter confirm password: `password456`
3. Expected: "Passwords do not match!"

---

## 🔍 Debugging Tips

### Check Browser Console
Open Developer Tools (F12) → Console tab to see detailed logs:
- Authentication attempts
- User IDs
- Profile data
- Error messages

### Check Network Tab
Open Developer Tools (F12) → Network tab:
- Filter by "Fetch/XHR"
- Look for requests to your Supabase API
- Check request/response data for authentication calls

### Check Supabase Dashboard
1. **Authentication → Users**: See all registered users
2. **Table Editor → profiles**: Verify profile records
3. **Logs → Database**: See database trigger execution
4. **Authentication → Policies**: Check RLS policies

---

## 🚨 Common Issues & Solutions

### Issue 1: "RLS policy violation" when creating profile
**Cause**: Row Level Security blocking profile creation  
**Solution**: The database trigger runs with `SECURITY DEFINER`, so it bypasses RLS. Make sure the trigger is created correctly.

### Issue 2: "Email not confirmed" error on login
**Cause**: Supabase requires email verification by default  
**Solution**: 
- Option A: Disable email confirmation in Supabase Dashboard → Authentication → Settings → Email Auth → Disable "Confirm email"
- Option B: Check your email inbox and click the verification link

### Issue 3: Profile data not loading after login
**Cause**: RLS policy blocking profile read  
**Solution**: Add a policy to allow users to read their own profile:
```sql
CREATE POLICY "Users can read own profile"
ON profiles FOR SELECT
USING (auth.uid() = id);
```

### Issue 4: "Invalid login credentials" even with correct password
**Cause**: User account may not exist or email not verified  
**Solution**: 
1. Check Supabase Dashboard → Authentication → Users
2. Verify the user exists
3. Check if email is confirmed (if required)

---

## 📝 Code Flow Summary

### SignUp Flow:
1. User fills form → clicks "Sign-Up"
2. Validation (email format, password length, passwords match)
3. `supabase.auth.signUp()` creates auth user
4. Database trigger automatically creates profile record
5. Success alert → redirect to `/login`

### Login Flow:
1. User fills form → clicks "Login"
2. Validation (email format, fields not empty)
3. `supabase.auth.signInWithPassword()` authenticates user
4. If successful, fetch profile from `profiles` table
5. Store profile data in component state
6. Success alert → redirect to `/dashboard`

---

## 🎯 Next Steps

After testing authentication:

1. **Persist Authentication State**:
   - Consider using Vuex or Pinia to store user session globally
   - Add authentication guards to routes (protect dashboard pages)

2. **Session Management**:
   - Implement auto-logout on token expiration
   - Add "Remember Me" functionality
   - Handle session refresh

3. **User Profile Management**:
   - Add profile editing functionality
   - Allow users to update their information
   - Add avatar upload feature

4. **Password Reset**:
   - Implement "Forgot Password" flow
   - Use `supabase.auth.resetPasswordForEmail()`

5. **Protected Routes**:
   - Add navigation guards in `src/router/index.js`
   - Redirect unauthenticated users to login page

---

## ✅ Testing Checklist

- [ ] Can create a new account with valid data
- [ ] Can see profile created in Supabase dashboard
- [ ] Can login with correct credentials
- [ ] Redirected to dashboard after successful login
- [ ] See error message with wrong password
- [ ] See error message with invalid email format
- [ ] See error message when fields are empty
- [ ] See loading state during login/signup
- [ ] Profile data loads after login (check console)
- [ ] Can logout (if implemented)

---

**Need Help?** Check the browser console for detailed error messages and verify your Supabase configuration.
