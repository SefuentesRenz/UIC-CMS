# Complete Role-Based Authentication Database Setup

## 🔵 Recommended Database Structure

### Strategy: Use ONE unified `profiles` table with role-based filtering

**Why?** 
- Simpler to maintain
- Single source of truth for all users
- Easy role-based queries with `.eq('role', 'Student')` or `.in('role', ['Nurse', 'Staff'])`
- No need for complex joins or duplicate data

---

## 🔵 Step 1: Fix User Deletion Issue

### Enable Cascade Delete from Auth to Profiles

```sql
-- Ensure profiles are deleted when auth user is deleted
ALTER TABLE public.profiles
DROP CONSTRAINT IF EXISTS profiles_id_fkey;

ALTER TABLE public.profiles
ADD CONSTRAINT profiles_id_fkey
FOREIGN KEY (id) REFERENCES auth.users(id)
ON DELETE CASCADE;

-- Now when you delete a user from auth.users, 
-- the profile record will automatically be deleted
```

### Delete Users via SQL (if dashboard doesn't work)

```sql
-- Delete specific user by email
DELETE FROM auth.users WHERE email = 'user@example.com';

-- Delete specific user by ID
DELETE FROM auth.users WHERE id = 'user-uuid-here';

-- This will CASCADE delete the profile automatically
```

---

## 🔵 Step 2: Complete Profiles Table Schema

```sql
-- Create or update profiles table with all necessary fields
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  school_id TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'Student' CHECK (role IN ('Student', 'Nurse', 'Staff', 'Admin')),
  
  -- Student-specific fields
  college_department TEXT,
  program TEXT,
  year_section TEXT,
  contact_number TEXT,
  sex TEXT,
  type TEXT, -- Regular or Scholar
  
  -- Admin/Staff specific fields (optional, NULL for students)
  position TEXT,
  employee_id TEXT,
  
  -- Common fields
  status TEXT DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive')),
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_school_id ON public.profiles(school_id);
CREATE INDEX IF NOT EXISTS idx_profiles_status ON public.profiles(status);

-- Add trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_updated_at ON public.profiles;
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
```

---

## 🔵 Step 3: Update Signup Trigger (Robust Version)

This handles both old and new Supabase client metadata formats:

```sql
-- Enhanced trigger function to create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (
    id, 
    full_name, 
    email, 
    school_id, 
    role,
    college_department,
    program,
    year_section,
    contact_number,
    sex,
    type,
    status
  )
  VALUES (
    NEW.id,
    COALESCE(
      NEW.raw_user_meta_data->>'full_name',
      NEW.user_metadata->>'full_name',
      'Unknown User'
    ),
    NEW.email,
    COALESCE(
      NEW.raw_user_meta_data->>'school_id',
      NEW.user_metadata->>'school_id',
      'N/A'
    ),
    COALESCE(
      NEW.raw_user_meta_data->>'role',
      NEW.user_metadata->>'role',
      'Student'
    ),
    NEW.raw_user_meta_data->>'college_department',
    NEW.raw_user_meta_data->>'program',
    NEW.raw_user_meta_data->>'year_section',
    NEW.raw_user_meta_data->>'contact_number',
    NEW.raw_user_meta_data->>'sex',
    NEW.raw_user_meta_data->>'type',
    'Active'
  );
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log error but don't block user creation
    RAISE WARNING 'Failed to create profile for user %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

---

## 🔵 Step 4: Row Level Security (RLS) Policies

```sql
-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to start fresh
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Allow authenticated users to read all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Allow profile creation via trigger" ON public.profiles;

-- 1. Allow users to view their own profile
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- 2. Allow Admin/Nurse/Staff to view all profiles
CREATE POLICY "Staff can view all profiles"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role IN ('Admin', 'Nurse', 'Staff')
    )
  );

-- 3. Allow users to update their own profile
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- 4. Allow profile creation (for trigger function)
CREATE POLICY "Allow profile creation"
  ON public.profiles FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- 5. Allow Admin to delete profiles
CREATE POLICY "Admin can delete profiles"
  ON public.profiles FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role = 'Admin'
    )
  );
```

---

## 🔵 Step 5: Student Consultation History Table

```sql
-- Create consultations table for student medical history
CREATE TABLE IF NOT EXISTS public.consultations (
  id BIGSERIAL PRIMARY KEY,
  student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  consultation_date TIMESTAMPTZ DEFAULT NOW(),
  
  -- Medical details
  chief_complaint TEXT NOT NULL,
  diagnosis TEXT,
  treatment TEXT,
  prescription TEXT,
  
  -- Vital signs
  temperature DECIMAL(4,1),
  blood_pressure TEXT,
  heart_rate INTEGER,
  weight DECIMAL(5,2),
  
  -- Staff who handled
  attended_by UUID REFERENCES public.profiles(id),
  
  -- Follow-up
  follow_up_date DATE,
  notes TEXT,
  status TEXT DEFAULT 'Completed' CHECK (status IN ('Pending', 'In Progress', 'Completed')),
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for fast queries
CREATE INDEX IF NOT EXISTS idx_consultations_student_id ON public.consultations(student_id);
CREATE INDEX IF NOT EXISTS idx_consultations_date ON public.consultations(consultation_date DESC);
CREATE INDEX IF NOT EXISTS idx_consultations_status ON public.consultations(status);

-- RLS Policies for consultations
ALTER TABLE public.consultations ENABLE ROW LEVEL SECURITY;

-- Students can view their own consultations
CREATE POLICY "Students can view own consultations"
  ON public.consultations FOR SELECT
  TO authenticated
  USING (student_id = auth.uid());

-- Staff can view all consultations
CREATE POLICY "Staff can view all consultations"
  ON public.consultations FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role IN ('Admin', 'Nurse', 'Staff')
    )
  );

-- Staff can insert/update consultations
CREATE POLICY "Staff can insert consultations"
  ON public.consultations FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role IN ('Admin', 'Nurse', 'Staff')
    )
  );

CREATE POLICY "Staff can update consultations"
  ON public.consultations FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role IN ('Admin', 'Nurse', 'Staff')
    )
  );
```

---

## 🔵 Step 6: Test Queries

### Query 1: Get all students
```sql
SELECT * FROM public.profiles
WHERE role = 'Student'
ORDER BY full_name;
```

### Query 2: Get all staff (Nurse + Staff only)
```sql
SELECT * FROM public.profiles
WHERE role IN ('Nurse', 'Staff')
ORDER BY full_name;
```

### Query 3: Get student with consultation history
```sql
SELECT 
  p.full_name,
  p.school_id,
  p.email,
  COUNT(c.id) as total_consultations
FROM public.profiles p
LEFT JOIN public.consultations c ON p.id = c.student_id
WHERE p.role = 'Student'
GROUP BY p.id, p.full_name, p.school_id, p.email
ORDER BY p.full_name;
```

### Query 4: Get recent consultations for a specific student
```sql
SELECT 
  c.*,
  s.full_name as attended_by_name
FROM public.consultations c
LEFT JOIN public.profiles s ON c.attended_by = s.id
WHERE c.student_id = 'student-uuid-here'
ORDER BY c.consultation_date DESC
LIMIT 10;
```

---

## 🔵 Summary of Database Structure

### Tables:
1. **auth.users** (managed by Supabase Auth)
   - Contains: id, email, encrypted_password, email_confirmed_at, etc.
   - Purpose: Authentication only

2. **public.profiles** (unified user table)
   - Contains: All users (Students, Nurse, Staff, Admin)
   - Role field determines user type
   - Students have: college_department, program, year_section, etc.
   - Staff have: position, employee_id (optional fields)

3. **public.consultations** (student medical history)
   - Contains: Medical visits, diagnoses, prescriptions
   - Linked to student via student_id → profiles.id
   - Linked to staff via attended_by → profiles.id

### Benefits:
- ✅ Single source of truth for all users
- ✅ Easy role-based filtering
- ✅ Simple queries (no complex joins)
- ✅ Proper RLS for security
- ✅ Cascade delete works properly
- ✅ Students can view their own data
- ✅ Staff can manage all data

---

## 🔵 Next Steps (After Running SQL)

1. **Test user deletion**:
   - Try deleting a user from Dashboard → Authentication → Users
   - Should now work with cascade delete to profiles

2. **Test signup**:
   - Sign up as Student → check profiles table has role='Student'
   - Sign up as Admin/Nurse → check profiles table has correct role

3. **Verify RLS**:
   - Login as student → can only see own profile and consultations
   - Login as nurse → can see all profiles and consultations

4. **Update Vue components**:
   - Login.vue → redirect based on role
   - SignUp.vue → redirect based on account type
   - Create StudentHome.vue for student portal
