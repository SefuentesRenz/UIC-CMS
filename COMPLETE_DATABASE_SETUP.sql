-- ============================================
-- UIC-CMS COMPLETE DATABASE SETUP
-- Two-Mode System: Student & Admin/Staff
-- ============================================

-- ============================================
-- PART 1: PROFILES TABLE (Unified User Table)
-- ============================================

-- Ensure profiles table has all necessary columns
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS full_name TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS school_id TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'Student';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'Active';

-- Student-specific fields
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS college_department TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS program TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS year_section TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS contact_number TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS sex TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS type TEXT;

-- Staff-specific fields
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS position TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS employee_id TEXT;

-- Common fields
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Add CASCADE delete from auth.users to profiles
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_id_fkey;
ALTER TABLE public.profiles
ADD CONSTRAINT profiles_id_fkey
FOREIGN KEY (id) REFERENCES auth.users(id)
ON DELETE CASCADE;

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_school_id ON public.profiles(school_id);
CREATE INDEX IF NOT EXISTS idx_profiles_status ON public.profiles(status);

-- ============================================
-- PART 2: CONSULTATIONS TABLE (Student Medical History)
-- ============================================

CREATE TABLE IF NOT EXISTS public.consultations (
  id BIGSERIAL PRIMARY KEY,
  student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  consultation_date TIMESTAMPTZ DEFAULT NOW(),
  
  -- Medical details
  chief_complaint TEXT,
  diagnosis TEXT,
  treatment TEXT,
  prescription TEXT,
  
  -- Vital signs
  temperature NUMERIC(4,1),
  blood_pressure TEXT,
  heart_rate INTEGER,
  weight NUMERIC(5,2),
  
  -- Staff information
  attended_by UUID REFERENCES public.profiles(id),
  
  -- Follow-up and status
  follow_up_date DATE,
  notes TEXT,
  status TEXT DEFAULT 'Completed' CHECK (status IN ('Pending', 'In Progress', 'Completed')),
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for consultations
CREATE INDEX IF NOT EXISTS idx_consultations_student_id ON public.consultations(student_id);
CREATE INDEX IF NOT EXISTS idx_consultations_date ON public.consultations(consultation_date DESC);
CREATE INDEX IF NOT EXISTS idx_consultations_status ON public.consultations(status);
CREATE INDEX IF NOT EXISTS idx_consultations_attended_by ON public.consultations(attended_by);

-- ============================================
-- PART 3: FIX PATIENTS TABLE (Prevent FK Conflicts)
-- ============================================

-- Option A: Change created_by to reference profiles instead of auth.users
-- This is recommended if patients should persist when auth user changes
ALTER TABLE public.patients DROP CONSTRAINT IF EXISTS patients_created_by_fkey;
ALTER TABLE public.patients
ADD CONSTRAINT patients_created_by_fkey
FOREIGN KEY (created_by) REFERENCES public.profiles(id)
ON DELETE SET NULL;  -- Or CASCADE if you want to delete patients when creator is deleted

-- If patients table doesn't have updated_by, you may want to add it
ALTER TABLE public.patients ADD COLUMN IF NOT EXISTS updated_by UUID REFERENCES public.profiles(id);
ALTER TABLE public.patients ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ;

-- ============================================
-- PART 4: SIGNUP TRIGGER (Auto-create Profile)
-- ============================================

-- Drop existing trigger and function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

-- Create robust trigger function that handles metadata properly
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Log the signup attempt
  RAISE LOG 'Creating profile for user % (email: %)', NEW.id, NEW.email;
  
  -- Insert profile with metadata from signup
  INSERT INTO public.profiles (
    id,
    email,
    full_name,
    school_id,
    role,
    status,
    created_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.user_metadata->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'school_id', NEW.user_metadata->>'school_id', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', NEW.user_metadata->>'role', 'Student'),
    'Active',
    NOW()
  );
  
  RAISE LOG 'Profile created successfully for user %', NEW.id;
  RETURN NEW;
  
EXCEPTION WHEN OTHERS THEN
  -- Log error with full details
  RAISE WARNING 'ERROR in handle_new_user for % (email: %): % [%]', 
    NEW.id, NEW.email, SQLERRM, SQLSTATE;
  -- Re-raise to prevent user creation if profile creation fails
  RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger on auth.users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- PART 5: ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Drop all existing policies to start fresh
DROP POLICY IF EXISTS "Allow insert for signup" ON public.profiles;
DROP POLICY IF EXISTS "Enable insert during signup" ON public.profiles;
DROP POLICY IF EXISTS "Enable profile creation" ON public.profiles;
DROP POLICY IF EXISTS "Users view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Staff view all" ON public.profiles;
DROP POLICY IF EXISTS "Staff can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users update own" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admin can delete profiles" ON public.profiles;

-- PROFILES POLICIES

-- 1. Allow INSERT for signup (trigger runs as anon during signup)
CREATE POLICY "Enable insert during signup"
  ON public.profiles FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- 2. Students can view their own profile
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- 3. Staff/Admin can view all profiles
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

-- 4. Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- 5. Admin can delete profiles
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

-- CONSULTATIONS POLICIES

ALTER TABLE public.consultations ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Students can view own consultations" ON public.consultations;
DROP POLICY IF EXISTS "Staff can view all consultations" ON public.consultations;
DROP POLICY IF EXISTS "Staff can insert consultations" ON public.consultations;
DROP POLICY IF EXISTS "Staff can update consultations" ON public.consultations;
DROP POLICY IF EXISTS "Staff can delete consultations" ON public.consultations;

-- 1. Students can view their own consultations
CREATE POLICY "Students can view own consultations"
  ON public.consultations FOR SELECT
  TO authenticated
  USING (student_id = auth.uid());

-- 2. Staff can view all consultations
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

-- 3. Staff can insert consultations
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

-- 4. Staff can update consultations
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

-- 5. Staff can delete consultations
CREATE POLICY "Staff can delete consultations"
  ON public.consultations FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() 
      AND role = 'Admin'
    )
  );

-- ============================================
-- PART 6: PATIENTS TABLE RLS (if needed)
-- ============================================

ALTER TABLE public.patients ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Staff can view all patients" ON public.patients;
DROP POLICY IF EXISTS "Staff can insert patients" ON public.patients;
DROP POLICY IF EXISTS "Staff can update patients" ON public.patients;
DROP POLICY IF EXISTS "Staff can delete patients" ON public.patients;

-- Staff can view all patients
CREATE POLICY "Staff can view all patients"
  ON public.patients FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() 
      AND role IN ('Admin', 'Nurse', 'Staff')
    )
  );

-- Staff can insert patients
CREATE POLICY "Staff can insert patients"
  ON public.patients FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() 
      AND role IN ('Admin', 'Nurse', 'Staff')
    )
  );

-- Staff can update patients
CREATE POLICY "Staff can update patients"
  ON public.patients FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() 
      AND role IN ('Admin', 'Nurse', 'Staff')
    )
  );

-- Staff can delete patients (Admin only)
CREATE POLICY "Staff can delete patients"
  ON public.patients FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() 
      AND role = 'Admin'
    )
  );

-- ============================================
-- PART 7: MEDICINE TABLE RLS
-- ============================================

ALTER TABLE public.medicine ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Staff can view all medicine" ON public.medicine;
DROP POLICY IF EXISTS "Staff can manage medicine" ON public.medicine;

-- Staff can view all medicine
CREATE POLICY "Staff can view all medicine"
  ON public.medicine FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() 
      AND role IN ('Admin', 'Nurse', 'Staff')
    )
  );

-- Staff can insert, update, delete medicine
CREATE POLICY "Staff can manage medicine"
  ON public.medicine FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() 
      AND role IN ('Admin', 'Nurse', 'Staff')
    )
  );

-- ============================================
-- PART 8: VERIFICATION QUERIES
-- ============================================

-- Check trigger exists
SELECT 
  'Trigger Check' AS test,
  t.tgname AS trigger_name,
  CASE WHEN t.tgenabled = 'O' THEN 'Enabled' ELSE 'Disabled' END AS status,
  p.proname AS function_name
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE t.tgname = 'on_auth_user_created';

-- Check RLS is enabled
SELECT 
  'RLS Check' AS test,
  schemaname,
  tablename,
  CASE WHEN rowsecurity THEN 'Enabled' ELSE 'Disabled' END AS rls_status
FROM pg_tables
WHERE tablename IN ('profiles', 'consultations', 'patients', 'medicine')
ORDER BY tablename;

-- Check policies count
SELECT 
  'Policies Check' AS test,
  tablename,
  COUNT(*) AS policy_count
FROM pg_policies
WHERE tablename IN ('profiles', 'consultations', 'patients', 'medicine')
GROUP BY tablename
ORDER BY tablename;

-- Check foreign key constraints
SELECT
  'Foreign Keys Check' AS test,
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table,
  ccu.column_name AS foreign_column,
  rc.update_rule,
  rc.delete_rule
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.referential_constraints rc 
  ON tc.constraint_name = rc.constraint_name
JOIN information_schema.constraint_column_usage ccu 
  ON rc.unique_constraint_name = ccu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_name IN ('profiles', 'consultations', 'patients')
ORDER BY tc.table_name, kcu.column_name;

-- Show sample profiles structure
SELECT 
  'Sample Profile Structure' AS test,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'profiles'
ORDER BY ordinal_position;

-- ============================================
-- SETUP COMPLETE!
-- ============================================

SELECT '✅ Database setup complete!' AS status,
       'Run signup test to verify trigger creates profiles' AS next_step;
