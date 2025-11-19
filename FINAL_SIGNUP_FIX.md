# 🔴 FINAL FIX: Signup Database Error

## Run This Complete SQL Script

Copy and paste this **entire block** into your Supabase SQL Editor and run it all at once:

```sql
-- ============================================
-- STEP 1: Make NOT NULL columns nullable
-- ============================================
ALTER TABLE public.profiles 
ALTER COLUMN full_name DROP NOT NULL;

ALTER TABLE public.profiles 
ALTER COLUMN school_id DROP NOT NULL;

ALTER TABLE public.profiles 
ALTER COLUMN role DROP NOT NULL;

-- ============================================
-- STEP 2: Add missing columns
-- ============================================
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS college_department TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS program TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS year_section TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS contact_number TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS sex TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS type TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS position TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS employee_id TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'Active';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- ============================================
-- STEP 3: Drop and recreate trigger function
-- ============================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  user_full_name TEXT;
  user_school_id TEXT;
  user_role TEXT;
BEGIN
  -- Extract metadata with fallbacks
  user_full_name := COALESCE(
    NEW.raw_user_meta_data->>'full_name',
    NEW.user_metadata->>'full_name',
    ''
  );
  
  user_school_id := COALESCE(
    NEW.raw_user_meta_data->>'school_id',
    NEW.user_metadata->>'school_id',
    ''
  );
  
  user_role := COALESCE(
    NEW.raw_user_meta_data->>'role',
    NEW.user_metadata->>'role',
    'Student'
  );

  -- Insert only essential fields
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
    user_full_name,
    user_school_id,
    user_role,
    'Active',
    NOW()
  );
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log detailed error
    RAISE WARNING 'Error in handle_new_user for user % (email: %): %', NEW.id, NEW.email, SQLERRM;
    -- Re-raise to see the error in Supabase logs
    RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- STEP 4: Recreate trigger
-- ============================================
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- STEP 5: Fix CASCADE delete constraint
-- ============================================
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_id_fkey;
ALTER TABLE public.profiles
ADD CONSTRAINT profiles_id_fkey
FOREIGN KEY (id) REFERENCES auth.users(id)
ON DELETE CASCADE;

-- ============================================
-- STEP 6: Update RLS policies
-- ============================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Drop all existing policies
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Staff can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Allow profile creation" ON public.profiles;
DROP POLICY IF EXISTS "Enable profile creation during signup" ON public.profiles;
DROP POLICY IF EXISTS "Admin can delete profiles" ON public.profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.profiles;

-- Create new policies
-- 1. Allow profile creation (MUST use anon for signup trigger)
CREATE POLICY "Enable profile creation"
  ON public.profiles FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- 2. Users can view own profile
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- 3. Staff can view all profiles
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

-- 4. Users can update own profile
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

-- ============================================
-- STEP 7: Verify setup
-- ============================================
SELECT 
  'Trigger exists' AS check_type,
  COUNT(*) AS result
FROM pg_trigger 
WHERE tgname = 'on_auth_user_created';

SELECT 
  'RLS enabled' AS check_type,
  relrowsecurity AS result
FROM pg_class 
WHERE relname = 'profiles';

SELECT 
  'Policies count' AS check_type,
  COUNT(*) AS result
FROM pg_policies 
WHERE tablename = 'profiles';
```

## What This Does:

1. **Removes NOT NULL constraints** - Allows empty values during signup
2. **Adds all missing columns** - Ensures table has all fields
3. **Creates simple trigger** - Only inserts essential fields
4. **Fixes RLS policies** - Allows `anon` role to insert during signup (CRITICAL!)
5. **Enables CASCADE delete** - Fixes user deletion issue
6. **Verifies setup** - Shows you confirmation

## The Key Fix:

The critical issue was the RLS policy. It must allow **`anon`** role (not just `authenticated`) because during signup, the user is not yet authenticated:

```sql
CREATE POLICY "Enable profile creation"
  ON public.profiles FOR INSERT
  TO anon, authenticated  -- ← THIS IS THE KEY!
  WITH CHECK (true);
```

## After Running the SQL:

1. **Refresh your browser** (clear cache)
2. **Try signup again** - Should work now!
3. **Check the results** at the bottom of the SQL output - should show:
   - Trigger exists: 1
   - RLS enabled: true
   - Policies count: 5

## Still Not Working?

Run this to see detailed error logs:

```sql
-- Check recent auth errors
SELECT 
  created_at,
  level,
  msg,
  error_code
FROM _realtime.logs
WHERE msg LIKE '%handle_new_user%'
ORDER BY created_at DESC
LIMIT 5;
```

Then send me the error message from the logs!
