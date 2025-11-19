# 🔍 DIAGNOSE THE SIGNUP ERROR

## Step 1: Check Current Table Structure

Run this in Supabase SQL Editor to see what columns exist:

```sql
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'profiles'
ORDER BY ordinal_position;
```

**Send me the results!** This will tell us what's missing.

---

## Step 2: Check Current Trigger

```sql
SELECT 
  p.proname AS function_name,
  pg_get_functiondef(p.oid) AS function_definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public' 
AND p.proname = 'handle_new_user';
```

---

## Step 3: Check RLS Policies

```sql
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'profiles';
```

---

## Step 4: Check Supabase Logs

1. Go to your Supabase Dashboard
2. Click **Logs** in the left sidebar
3. Select **Postgres Logs**
4. Look for recent errors (should show the actual error message)

**Screenshot or copy the error message!**

---

## Step 5: NUCLEAR OPTION - Complete Reset

If you want to start completely fresh, run this (⚠️ **THIS DELETES ALL PROFILE DATA**):

```sql
-- ============================================
-- NUCLEAR RESET - USE WITH CAUTION!
-- ============================================

-- 1. Drop all policies
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Staff can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Allow profile creation" ON public.profiles;
DROP POLICY IF EXISTS "Enable profile creation during signup" ON public.profiles;
DROP POLICY IF EXISTS "Enable profile creation" ON public.profiles;
DROP POLICY IF EXISTS "Admin can delete profiles" ON public.profiles;

-- 2. Disable RLS temporarily
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- 3. Drop existing trigger and function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

-- 4. Drop and recreate profiles table
DROP TABLE IF EXISTS public.profiles CASCADE;

CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  school_id TEXT,
  role TEXT DEFAULT 'Student',
  college_department TEXT,
  program TEXT,
  year_section TEXT,
  contact_number TEXT,
  sex TEXT,
  type TEXT,
  position TEXT,
  employee_id TEXT,
  status TEXT DEFAULT 'Active',
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Create simple trigger function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
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
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RAISE LOG 'handle_new_user error for %: %', NEW.email, SQLERRM;
  RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Create trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 7. Enable RLS with simple policies
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Allow anyone to insert (for signup)
CREATE POLICY "Allow insert for signup"
  ON public.profiles FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- Users can view own profile
CREATE POLICY "Users view own profile"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Staff can view all
CREATE POLICY "Staff view all"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role IN ('Admin', 'Nurse', 'Staff')
    )
  );

-- Users can update own
CREATE POLICY "Users update own"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

-- 8. Verify setup
SELECT 'Profiles table' AS item, COUNT(*) AS count FROM public.profiles
UNION ALL
SELECT 'Trigger exists', COUNT(*) FROM pg_trigger WHERE tgname = 'on_auth_user_created'
UNION ALL
SELECT 'Policies', COUNT(*) FROM pg_policies WHERE tablename = 'profiles'
UNION ALL
SELECT 'RLS enabled', CASE WHEN relrowsecurity THEN 1 ELSE 0 END 
  FROM pg_class WHERE relname = 'profiles';
```

---

## Step 6: Test Trigger Manually

After running the reset, test if the trigger works:

```sql
-- This simulates what happens during signup
DO $$
DECLARE
  test_id UUID := gen_random_uuid();
BEGIN
  -- Simulate inserting into auth.users
  -- (We can't actually do this, but we can test the function logic)
  RAISE NOTICE 'Testing trigger function...';
  
  -- Try a direct insert to profiles
  INSERT INTO public.profiles (id, email, full_name, school_id, role)
  VALUES (test_id, 'test@test.com', 'Test User', '12345', 'Student');
  
  RAISE NOTICE 'Direct insert successful!';
  
  -- Clean up
  DELETE FROM public.profiles WHERE id = test_id;
END $$;
```

If this works, the problem is with the trigger, not the table.

---

## Step 7: Alternative - Disable Trigger Temporarily

If you just want to test if signup works WITHOUT the trigger:

```sql
-- Disable the trigger
ALTER TABLE auth.users DISABLE TRIGGER on_auth_user_created;
```

Then try signup again. If it works, the problem is definitely in the trigger function.

To re-enable:
```sql
ALTER TABLE auth.users ENABLE TRIGGER on_auth_user_created;
```

---

## What to Send Me:

1. **Results from Step 1** (current columns in profiles table)
2. **Error message from Supabase Postgres Logs** (Step 4)
3. **Tell me if you ran the nuclear reset** (Step 5)

This will help me identify the exact issue!
