# 🔴 Student Signup Not Saving to Database

## The Problem
You're getting "Account created successfully" but:
1. No profile appears in `public.profiles` table
2. Cannot login with the created student account

## Root Cause
The trigger function `handle_new_user()` is **failing silently** after creating the auth user. The auth user gets created in `auth.users`, but the profile is NOT being inserted into `public.profiles`.

---

## 🔍 Diagnosis Steps

### Step 1: Check if auth users are being created

Run this in Supabase SQL Editor:

```sql
-- Check recent auth users (last 10)
SELECT 
  id,
  email,
  created_at,
  raw_user_meta_data,
  email_confirmed_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 10;
```

**Expected:** You should see your student account email here with `created_at` timestamp.

### Step 2: Check if profiles exist for those users

```sql
-- Check which auth users DON'T have profiles
SELECT 
  u.id,
  u.email,
  u.created_at,
  p.id AS profile_id,
  p.role
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
ORDER BY u.created_at DESC
LIMIT 10;
```

**Expected:** If `profile_id` is NULL, the trigger failed to create the profile.

### Step 3: Check Postgres logs for errors

```sql
-- This won't work in SQL editor, but you can check in Dashboard:
-- Go to: Logs → Postgres Logs
-- Look for errors containing "handle_new_user"
```

---

## ✅ COMPLETE FIX - Run This SQL

This will fix the trigger and clean up orphaned auth users:

```sql
-- ============================================
-- FIX 1: Drop and recreate the trigger properly
-- ============================================

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Log the attempt
  RAISE LOG 'Creating profile for user % (email: %)', NEW.id, NEW.email;
  
  -- Insert profile
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
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'school_id', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', 'Student'),
    'Active',
    NOW()
  );
  
  RAISE LOG 'Profile created successfully for user %', NEW.id;
  RETURN NEW;
  
EXCEPTION WHEN OTHERS THEN
  -- Log the error with full details
  RAISE LOG 'ERROR in handle_new_user for user % (email: %): % - %', 
    NEW.id, NEW.email, SQLERRM, SQLSTATE;
  -- RE-RAISE to prevent user creation if profile fails
  RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- FIX 2: Update RLS policies (CRITICAL!)
-- ============================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Drop ALL existing policies
DROP POLICY IF EXISTS "Allow insert for signup" ON public.profiles;
DROP POLICY IF EXISTS "Enable profile creation" ON public.profiles;
DROP POLICY IF EXISTS "Allow profile creation" ON public.profiles;
DROP POLICY IF EXISTS "Users view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Staff view all" ON public.profiles;
DROP POLICY IF EXISTS "Staff can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users update own" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;

-- Create new policies with correct permissions

-- 1. Allow INSERT for anon (signup trigger runs as anon!)
CREATE POLICY "Enable insert during signup"
  ON public.profiles FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- 2. Allow users to view their own profile
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- 3. Allow staff to view all profiles
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

-- 4. Allow users to update their own profile
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- ============================================
-- FIX 3: Clean up orphaned auth users (optional)
-- ============================================

-- Find auth users without profiles
SELECT 
  'Orphaned auth users:' AS message,
  u.id,
  u.email,
  u.created_at
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
WHERE p.id IS NULL
ORDER BY u.created_at DESC;

-- If you want to delete them (BE CAREFUL!):
-- DELETE FROM auth.users
-- WHERE id IN (
--   SELECT u.id
--   FROM auth.users u
--   LEFT JOIN public.profiles p ON u.id = p.id
--   WHERE p.id IS NULL
-- );

-- ============================================
-- FIX 4: Verify the setup
-- ============================================

-- Check trigger exists
SELECT 
  t.tgname AS trigger_name,
  t.tgenabled AS enabled,
  p.proname AS function_name
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE t.tgname = 'on_auth_user_created';

-- Check RLS is enabled
SELECT 
  schemaname,
  tablename,
  rowsecurity AS rls_enabled
FROM pg_tables
WHERE tablename = 'profiles';

-- Check policies
SELECT 
  policyname,
  cmd AS operation,
  roles
FROM pg_policies
WHERE tablename = 'profiles'
ORDER BY cmd;

-- Should show:
-- INSERT policy for {anon, authenticated}
-- SELECT policies for authenticated
-- UPDATE policy for authenticated
```

---

## 🧪 Test After Running the Fix

### Test 1: Try signing up again

1. **Clear browser cache** (important!)
2. Go to `/signup`
3. Select **Student** mode
4. Fill in the form
5. Click Sign Up

### Test 2: Verify profile was created

```sql
-- Check if profile exists
SELECT * FROM public.profiles
WHERE email = 'your-test-email@example.com';

-- Should return a row with:
-- - id (UUID)
-- - email
-- - full_name
-- - school_id
-- - role = 'Student'
-- - status = 'Active'
```

### Test 3: Try logging in

1. Go to `/login`
2. Select **Student** mode
3. Enter email and password
4. Should redirect to `/student-home`

---

## 🚨 If Still Not Working

### Check Postgres Logs:

1. Go to Supabase Dashboard
2. Click **Logs** (left sidebar)
3. Select **Postgres Logs**
4. Look for entries with "handle_new_user"
5. **Send me the error message!**

### Temporarily disable RLS to test:

```sql
-- ONLY FOR TESTING - Disable RLS temporarily
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- Try signup again
-- If it works, the problem is RLS policies

-- Re-enable after testing:
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
```

### Manual profile creation (emergency workaround):

If you have orphaned auth users, create profiles manually:

```sql
-- Get the user ID from auth.users
SELECT id, email FROM auth.users WHERE email = 'student@example.com';

-- Insert profile manually (replace the UUID)
INSERT INTO public.profiles (id, email, full_name, school_id, role, status)
VALUES (
  'paste-user-id-here',
  'student@example.com',
  'Student Name',
  '12345',
  'Student',
  'Active'
);
```

---

## 📊 Quick Diagnostic Summary

Run this ONE query to see everything:

```sql
-- Complete diagnostic
WITH auth_users AS (
  SELECT id, email, created_at, 
         raw_user_meta_data->>'role' as signup_role
  FROM auth.users
  ORDER BY created_at DESC
  LIMIT 5
),
profiles AS (
  SELECT id, email, role, status
  FROM public.profiles
),
trigger_info AS (
  SELECT COUNT(*) as trigger_exists
  FROM pg_trigger
  WHERE tgname = 'on_auth_user_created'
),
policy_info AS (
  SELECT COUNT(*) as policy_count
  FROM pg_policies
  WHERE tablename = 'profiles'
)
SELECT 
  'Auth Users' as item,
  json_agg(json_build_object(
    'email', a.email,
    'has_profile', (p.id IS NOT NULL),
    'signup_role', a.signup_role,
    'actual_role', p.role
  )) as data
FROM auth_users a
LEFT JOIN profiles p ON a.id = p.id
UNION ALL
SELECT 'Trigger Exists', to_json(trigger_exists) FROM trigger_info
UNION ALL
SELECT 'Policy Count', to_json(policy_count) FROM policy_info;
```

---

## 💡 Summary

The issue is that:
1. **Auth user is created** (`auth.users` table)
2. **Trigger fails** to create profile in `public.profiles`
3. **RLS policy** is likely blocking the INSERT (trigger runs as `anon` role, not `authenticated`)

**Key fix:** The RLS INSERT policy MUST include `TO anon` because during signup, the user is not yet authenticated!

Run the complete fix SQL above and try again! 🚀
