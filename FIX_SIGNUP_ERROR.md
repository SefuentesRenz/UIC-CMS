# 🔧 Fix Signup Error: Database error saving new user

## 🔴 Problem
Getting "Database error saving new user" (500 error) when signing up as Student or Admin.

**Root Cause:** The trigger function is trying to insert into columns that don't exist yet in your `profiles` table.

---

## ✅ Solution: Run These SQL Commands in Order

### Step 1: First, let's see what columns you currently have
Run this to check your current table structure:

```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND table_schema = 'public'
ORDER BY ordinal_position;
```

---

### Step 2: Add Missing Columns to Profiles Table

Run this to add all necessary columns:

```sql
-- Add student-specific fields if they don't exist
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS college_department TEXT;

ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS program TEXT;

ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS year_section TEXT;

ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS contact_number TEXT;

ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS sex TEXT;

ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS type TEXT;

-- Add staff-specific fields if they don't exist
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS position TEXT;

ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS employee_id TEXT;

-- Add status field if it doesn't exist
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'Active';
```

---

### Step 3: Update the Trigger Function (Simpler Version)

Replace your current trigger function with this simpler version that only inserts the essential fields:

```sql
-- Drop the existing function
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

-- Create a simpler trigger function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (
    id, 
    full_name, 
    email, 
    school_id, 
    role,
    status
  )
  VALUES (
    NEW.id,
    COALESCE(
      NEW.raw_user_meta_data->>'full_name',
      NEW.user_metadata->>'full_name',
      ''
    ),
    NEW.email,
    COALESCE(
      NEW.raw_user_meta_data->>'school_id',
      NEW.user_metadata->>'school_id',
      ''
    ),
    COALESCE(
      NEW.raw_user_meta_data->>'role',
      NEW.user_metadata->>'role',
      'Student'
    ),
    'Active'
  );
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log the error for debugging
    RAISE LOG 'Error in handle_new_user for user %: %', NEW.id, SQLERRM;
    -- Re-raise the error so signup fails with a clear message
    RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate the trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

---

### Step 4: Update RLS Policies (Important!)

The trigger runs with SECURITY DEFINER, but we need to ensure RLS allows the INSERT:

```sql
-- Drop existing policies
DROP POLICY IF EXISTS "Allow profile creation" ON public.profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.profiles;

-- Allow inserts for profile creation during signup
CREATE POLICY "Enable profile creation during signup"
  ON public.profiles FOR INSERT
  WITH CHECK (true);
```

---

### Step 5: Verify the Setup

Check if the trigger exists:

```sql
SELECT 
  tgname AS trigger_name,
  tgenabled AS enabled,
  proname AS function_name
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE tgname = 'on_auth_user_created';
```

Should return:
- trigger_name: `on_auth_user_created`
- enabled: `O` (means enabled)
- function_name: `handle_new_user`

---

## 🧪 Test the Fix

### Test 1: Signup as Student
1. Go to `/signup`
2. Select "Student" account type
3. Fill in: Name, Email, School ID, Password
4. Click Sign Up
5. **Expected:** Account created successfully, redirects to `/student-home`

### Test 2: Signup as Admin
1. Go to `/signup`
2. Select "Admin" account type
3. Select role: "Nurse" (or Staff/Admin)
4. Fill in: Name, Email, School ID, Password
5. Click Sign Up
6. **Expected:** Account created successfully, redirects to `/dashboard`

---

## 🔍 Debug if Still Failing

### Check Supabase Logs:
1. Go to Supabase Dashboard
2. Click on your project
3. Go to **Database** → **Logs**
4. Look for errors related to `handle_new_user`

### Check if Profile Was Created:
```sql
SELECT id, email, full_name, school_id, role, created_at
FROM public.profiles
ORDER BY created_at DESC
LIMIT 5;
```

### Manually Test the Trigger Function:
```sql
-- This simulates what happens during signup
SELECT public.handle_new_user();
```

---

## 🚨 Common Issues and Fixes

### Issue 1: "null value in column violates not-null constraint"
**Cause:** Your `profiles` table has NOT NULL constraints on columns we're not inserting.

**Fix:** Make those columns nullable:
```sql
-- Make full_name nullable (we'll update it later)
ALTER TABLE public.profiles 
ALTER COLUMN full_name DROP NOT NULL;

-- Make school_id nullable
ALTER TABLE public.profiles 
ALTER COLUMN school_id DROP NOT NULL;
```

### Issue 2: "duplicate key value violates unique constraint"
**Cause:** Profile already exists for this user.

**Fix:** Delete the orphaned profile:
```sql
-- Find the orphaned profile
SELECT * FROM public.profiles 
WHERE email = 'your-test-email@example.com';

-- Delete it
DELETE FROM public.profiles 
WHERE email = 'your-test-email@example.com';
```

### Issue 3: RLS policy prevents insert
**Cause:** RLS is blocking the INSERT during signup.

**Fix:** Temporarily disable RLS for testing:
```sql
-- ONLY FOR TESTING - Disable RLS temporarily
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- Try signup again, then re-enable:
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
```

If it works with RLS disabled, the issue is the RLS policy. Use the policy from Step 4.

---

## 📋 Quick Fix Checklist

Run these in order in your Supabase SQL Editor:

```sql
-- 1. Add missing columns
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS college_department TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS program TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS year_section TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS contact_number TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS sex TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS type TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS position TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS employee_id TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'Active';

-- 2. Drop old trigger/function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

-- 3. Create simple trigger function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email, school_id, role, status)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.user_metadata->>'full_name', ''),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'school_id', NEW.user_metadata->>'school_id', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', NEW.user_metadata->>'role', 'Student'),
    'Active'
  );
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE LOG 'Error creating profile for %: %', NEW.id, SQLERRM;
    RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Recreate trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 5. Fix RLS policy
DROP POLICY IF EXISTS "Allow profile creation" ON public.profiles;
CREATE POLICY "Enable profile creation during signup"
  ON public.profiles FOR INSERT
  WITH CHECK (true);

-- 6. Verify trigger exists
SELECT tgname, tgenabled, proname
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE tgname = 'on_auth_user_created';
```

---

## ✅ After Running the SQL

1. **Clear browser cache** and refresh the signup page
2. **Try signing up** again as Student
3. **Check Supabase Dashboard** → Authentication → Users (should see new user)
4. **Check profiles table**: 
   ```sql
   SELECT * FROM public.profiles ORDER BY created_at DESC LIMIT 1;
   ```

If you still get errors, **send me the exact error message from the browser console** and I'll help debug further!
