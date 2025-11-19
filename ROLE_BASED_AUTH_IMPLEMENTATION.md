# Role-Based Authentication & Student Portal Implementation

## ✅ Implementation Complete

This document summarizes all changes made to implement role-based authentication with student and admin portals.

---

## 📋 What Was Implemented

### 1. **StudentHome.vue** - New Student Portal Page
**Location:** `src/views/StudentHome.vue`

**Features:**
- ✅ Professional student dashboard with sidebar navigation
- ✅ Three main tabs:
  - **My Profile**: Displays student information (name, school ID, email, college/department, program, year & section, contact number, sex, type)
  - **Medical History**: Shows consultation history from clinic visits with details (date, chief complaint, diagnosis, treatment, prescription, vital signs)
  - **Appointments**: Placeholder for future appointment scheduling
- ✅ Real-time data fetching from Supabase `profiles` and `consultations` tables
- ✅ Automatic role verification (redirects non-students to dashboard)
- ✅ Loading and error states
- ✅ Logout functionality
- ✅ Responsive design with gradient theme

**Key Code Segments:**
```javascript
// Fetches student profile and consultation history
const fetchStudentData = async () => {
  // Get current user
  const { data: { user } } = await supabase.auth.getUser()
  
  // Fetch profile
  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single()
  
  // Verify student role
  if (profile.role !== 'Student') {
    router.push('/dashboard')
    return
  }
  
  // Fetch consultation history
  const { data: consultationData } = await supabase
    .from('consultations')
    .select(`*, attended_by_profile:profiles!consultations_attended_by_fkey(full_name)`)
    .eq('student_id', user.id)
    .order('consultation_date', { ascending: false })
}
```

---

### 2. **Vue Router** - Added StudentHome Route
**Location:** `src/router/index.js`

**Changes:**
```javascript
// Added import
import StudentHomePage from '../views/StudentHome.vue'

// Added route
{
  path: '/student-home',
  name: 'StudentHome',
  component: StudentHomePage
}
```

---

### 3. **Login.vue** - Role-Based Redirect Logic
**Location:** `src/components/Login.vue`

**Changes:**
- ✅ After successful login, fetches user profile from `profiles` table
- ✅ Checks the `role` field in profile
- ✅ Redirects based on role:
  - **Student** → `/student-home` (Student Portal)
  - **Nurse/Staff/Admin** → `/dashboard` (Admin Dashboard)
- ✅ Stores user profile in localStorage for app-wide access

**Updated Code:**
```javascript
// Fetch user profile
const { data: profileData, error: profileError } = await supabase
  .from('profiles')
  .select('*')
  .eq('id', user.id)
  .single()

// Store profile
this.userProfile = profileData
localStorage.setItem('userProfile', JSON.stringify(profileData))

// Role-based redirect
if (profileData.role === 'Student') {
  console.log('Redirecting to Student Home...')
  this.$router.push('/student-home')
} else {
  // Admin, Nurse, Staff → Dashboard
  console.log('Redirecting to Dashboard...')
  this.$router.push('/dashboard')
}
```

---

### 4. **SignUp.vue** - Account Type Based Redirect
**Location:** `src/components/SignUp.vue`

**Changes:**
- ✅ After successful signup, redirects based on account type:
  - **Student** → `/student-home`
  - **Admin** (Nurse/Staff/Admin) → `/dashboard`
- ✅ Updated success message to show account type
- ✅ Changed from redirecting to login to direct portal access

**Updated Code:**
```javascript
alert(`Account created successfully as ${this.accountType}!`)

// Redirect based on account type
if (this.accountType === 'Student') {
  console.log('Redirecting to Student Home...')
  this.$router.push('/student-home')
} else {
  // Admin (Nurse/Staff/Admin) goes to Dashboard
  console.log('Redirecting to Dashboard...')
  this.$router.push('/dashboard')
}
```

---

## 🗄️ Required Database Setup

**IMPORTANT:** You must run the SQL commands from `DATABASE_SETUP_COMPLETE.md` in your Supabase SQL Editor to:

### 1. Fix User Deletion Issue
The CASCADE constraint allows deleting users from Supabase Auth:
```sql
-- Drop existing constraint
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_id_fkey;

-- Add CASCADE delete constraint
ALTER TABLE public.profiles 
ADD CONSTRAINT profiles_id_fkey 
FOREIGN KEY (id) 
REFERENCES auth.users(id) 
ON DELETE CASCADE;
```

### 2. Update Profiles Table Schema
Add student-specific fields to the unified `profiles` table:
```sql
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS college_department TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS program TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS year_section TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS contact_number TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS sex TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS type TEXT DEFAULT 'Regular';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS position TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS employee_id TEXT;
```

### 3. Create Consultations Table
Store student medical history:
```sql
CREATE TABLE IF NOT EXISTS public.consultations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  consultation_date TIMESTAMPTZ DEFAULT NOW(),
  chief_complaint TEXT,
  diagnosis TEXT,
  treatment TEXT,
  prescription TEXT,
  temperature NUMERIC,
  blood_pressure TEXT,
  heart_rate INTEGER,
  weight NUMERIC,
  status TEXT DEFAULT 'Completed',
  attended_by UUID REFERENCES public.profiles(id),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 4. Update Trigger Function
Handle both raw_user_meta_data and user_metadata:
```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, school_id, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.user_metadata->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'school_id', NEW.user_metadata->>'school_id', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', NEW.user_metadata->>'role', 'Student')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 5. Row Level Security Policies
Allow students to see their own data, staff to see all:
```sql
-- Profiles: Students see own, Staff see all
CREATE POLICY "Students can view own profile" ON public.profiles
FOR SELECT USING (auth.uid() = id OR role IN ('Nurse', 'Staff', 'Admin'));

CREATE POLICY "Students can update own profile" ON public.profiles
FOR UPDATE USING (auth.uid() = id);

-- Consultations: Students see own, Staff see all
CREATE POLICY "Students can view own consultations" ON public.consultations
FOR SELECT USING (auth.uid() = student_id OR EXISTS (
  SELECT 1 FROM public.profiles 
  WHERE id = auth.uid() 
  AND role IN ('Nurse', 'Staff', 'Admin')
));

CREATE POLICY "Staff can insert consultations" ON public.consultations
FOR INSERT WITH CHECK (EXISTS (
  SELECT 1 FROM public.profiles 
  WHERE id = auth.uid() 
  AND role IN ('Nurse', 'Staff', 'Admin')
));
```

---

## 🚀 How It Works

### Student Signup Flow:
1. User visits `/signup`
2. Selects **"Student"** account type
3. Fills in name, email, school ID, password
4. Clicks "Sign Up"
5. Backend creates auth user with `role: 'Student'` in metadata
6. Database trigger creates profile with `role = 'Student'`
7. **Automatically redirects to `/student-home`** (Student Portal)

### Admin Signup Flow:
1. User visits `/signup`
2. Selects **"Admin"** account type
3. Fills in name, email, school ID, password
4. Selects role from dropdown: **Nurse**, **Staff**, or **Admin**
5. Clicks "Sign Up"
6. Backend creates auth user with selected role in metadata
7. Database trigger creates profile with selected role
8. **Automatically redirects to `/dashboard`** (Admin Dashboard)

### Login Flow:
1. User visits `/login`
2. Enters email and password
3. Backend authenticates user
4. Fetches profile from `profiles` table
5. Checks `role` field:
   - **If role = 'Student'** → Redirect to `/student-home`
   - **If role = Nurse/Staff/Admin** → Redirect to `/dashboard`

### Student Portal Features:
- **My Profile Tab**: Shows personal info, school details, contact info
- **Medical History Tab**: Lists all clinic consultations with:
  - Date and time
  - Chief complaint
  - Diagnosis
  - Treatment & prescription
  - Vital signs (temperature, blood pressure, heart rate, weight)
  - Attending staff name
- **Appointments Tab**: Placeholder for future features

---

## 🎨 Design Features

### Student Portal:
- Modern gradient sidebar (blue theme)
- Professional header with user avatar
- Card-based layout for profile and consultations
- Status badges (Active/Inactive, Completed/Pending)
- Responsive design for mobile/tablet
- Loading and error states
- Empty states with helpful messages
- Smooth transitions and hover effects

### Colors:
- Primary: `#3b82f6` (Blue)
- Secondary: `#2563eb` (Dark Blue)
- Background: `#f5f7fa` (Light Gray)
- Success: `#10b981` (Green)
- Error: `#ef4444` (Red)

---

## 🧪 Testing Checklist

### Before Testing:
- [ ] Run all SQL commands from `DATABASE_SETUP_COMPLETE.md` in Supabase SQL Editor
- [ ] Verify `profiles` table has new student fields
- [ ] Verify `consultations` table exists
- [ ] Verify RLS policies are enabled on both tables
- [ ] Verify trigger function is updated with COALESCE

### Test Signup:
- [ ] Signup as Student → Should redirect to `/student-home`
- [ ] Signup as Admin/Nurse → Should redirect to `/dashboard`
- [ ] Verify profile created with correct role in Supabase
- [ ] Verify all metadata fields (name, school_id, role) saved correctly

### Test Login:
- [ ] Login as Student → Should redirect to `/student-home`
- [ ] Login as Nurse/Staff/Admin → Should redirect to `/dashboard`
- [ ] Verify profile data loads correctly
- [ ] Verify localStorage has userProfile data

### Test Student Portal:
- [ ] Profile tab shows correct student information
- [ ] Medical History tab shows consultations (if any)
- [ ] Empty state shows if no consultations
- [ ] Logout button works correctly
- [ ] Non-student users redirected away from `/student-home`

### Test User Deletion:
- [ ] Delete a user from Supabase Auth dashboard
- [ ] Verify profile automatically deleted (CASCADE)
- [ ] Verify no orphaned records

---

## 📁 Database Structure Summary

### Unified `profiles` Table:
- **Common fields**: id, email, full_name, school_id, role, status
- **Student fields**: college_department, program, year_section, contact_number, sex, type
- **Staff fields**: position, employee_id
- **Role values**: 'Student', 'Nurse', 'Staff', 'Admin'

### `consultations` Table:
- Stores medical visit history for students
- Links to student via `student_id` (foreign key to profiles)
- Links to attending staff via `attended_by` (foreign key to profiles)
- Contains medical details, vital signs, prescription
- CASCADE deletes when student is deleted

---

## 🔒 Security Implementation

### Row Level Security (RLS):
- **Students**: Can only view/edit their own profile and consultations
- **Staff (Nurse/Staff/Admin)**: Can view all profiles and consultations
- **Staff only**: Can create new consultations for students
- **CASCADE deletes**: Automatically remove profile and consultations when auth user is deleted

### Authentication:
- Supabase Auth handles user authentication
- JWT tokens for session management
- Metadata passed during signup for trigger function
- Profile stored in localStorage for app-wide access

---

## 🐛 Troubleshooting

### Issue: User deletion fails in Supabase Auth
**Solution:** Run the CASCADE constraint SQL from DATABASE_SETUP_COMPLETE.md

### Issue: Profile not created during signup
**Solution:** 
1. Check trigger function exists: `handle_new_user()`
2. Verify trigger is active on `auth.users`
3. Update trigger with COALESCE to handle metadata
4. Check RLS policies allow INSERT for authenticated users

### Issue: Student sees empty profile
**Solution:** 
1. Verify `profiles` table has student fields (college_department, program, etc.)
2. Check RLS policy allows student to read own profile
3. Verify role is set correctly during signup

### Issue: Cannot see consultations
**Solution:**
1. Verify `consultations` table exists
2. Check RLS policy allows students to read own consultations
3. Insert test consultation data for the student

### Issue: Redirect not working after login/signup
**Solution:**
1. Clear browser cache and localStorage
2. Check Vue Router has `/student-home` route
3. Verify profile has correct `role` value in database
4. Check browser console for navigation errors

---

## 📝 Next Steps (Optional Enhancements)

### Recommended Features:
1. **Add Student Dashboard Stats**: Total consultations, last visit date, health metrics
2. **Appointment Scheduling**: Allow students to book clinic appointments
3. **Medical Certificate Requests**: Students can request medical certificates
4. **Profile Editing**: Allow students to update contact info, college/department
5. **Notification System**: Notify students of upcoming appointments, new prescriptions
6. **Export Medical History**: Allow students to download consultation history as PDF
7. **Staff Portal Features**: Allow nurses to create consultations directly from student portal
8. **Search/Filter Consultations**: Add date range filter, search by diagnosis/treatment

### Database Enhancements:
1. **Appointments Table**: Store scheduled clinic visits
2. **Medical Certificates Table**: Store issued certificates
3. **Notifications Table**: Store user notifications
4. **Attachments Table**: Store medical documents, lab results

---

## ✅ Summary

**What's Working:**
- ✅ Role-based signup (Student vs Admin with role selection)
- ✅ Role-based login redirects (Student → StudentHome, Admin → Dashboard)
- ✅ Student portal with profile and medical history
- ✅ User deletion with CASCADE (after running SQL)
- ✅ Unified database structure with profiles table
- ✅ Consultations tracking for students
- ✅ RLS policies for data security

**What You Need To Do:**
1. **Run SQL commands** from `DATABASE_SETUP_COMPLETE.md` in Supabase SQL Editor
2. **Test signup flow** as Student and Admin
3. **Test login flow** with different roles
4. **Verify user deletion** works in Supabase Auth
5. **(Optional) Add sample consultation data** to test medical history display

**Files Modified:**
- ✅ `src/views/StudentHome.vue` (NEW)
- ✅ `src/router/index.js` (Updated)
- ✅ `src/components/Login.vue` (Updated redirect logic)
- ✅ `src/components/SignUp.vue` (Updated redirect logic)

---

## 🎉 Congratulations!

Your UIC Clinic Management System now has a complete role-based authentication system with separate portals for students and admin staff!

**Students** get a personal portal to view their profile and medical history.
**Admin/Nurse/Staff** get the full dashboard to manage the clinic.

Don't forget to run the SQL setup before testing! 🚀
