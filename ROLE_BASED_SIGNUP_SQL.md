# Role-Based Signup SQL Setup

## 🔵 Step 1: Update Profiles Table (if not already done)

If your `profiles` table doesn't have a `role` column yet, run this:

```sql
-- Add role column to profiles table if it doesn't exist
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'Student' 
CHECK (role IN ('Student', 'Nurse', 'Staff', 'Admin'));

-- Create index for faster role-based queries
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
```

## 🔵 Step 2: Update the Database Trigger

Update the automatic profile creation trigger to handle the new role field:

```sql
-- Update the trigger function to handle role-based signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, school_id, role, email)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'school_id',
    COALESCE(NEW.raw_user_meta_data->>'role', 'Student'), -- Default to Student
    NEW.email
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate the trigger (if it already exists, this will replace it)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

## 🔵 Step 3: Verify RLS Policies

Ensure users can read profiles based on roles:

```sql
-- Allow authenticated users to read all profiles
-- (This is needed for Clinic Staff Users page to show Nurse/Staff)
CREATE POLICY "Allow authenticated users to read all profiles"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (true);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);
```

## 🔵 Step 4: Test Data (Optional)

Insert some test users with different roles:

```sql
-- Note: These are profile records only. 
-- Real users should sign up through the app to get auth credentials.

-- Example: Create test staff members (you'll need to create auth users separately)
-- This is just to show what the data looks like

INSERT INTO public.profiles (id, full_name, school_id, role, email)
VALUES
  ('00000000-0000-0000-0000-000000000001', 'Nurse Jane Doe', 'STAFF-001', 'Nurse', 'nurse.jane@uic.edu'),
  ('00000000-0000-0000-0000-000000000002', 'Staff John Smith', 'STAFF-002', 'Staff', 'staff.john@uic.edu')
ON CONFLICT (id) DO NOTHING;
```

## 🔵 Role Options

The system supports these roles:
- **Student** - Default role for student signups (auto-assigned)
- **Nurse** - Healthcare staff (manually selected during Admin signup)
- **Staff** - Administrative staff (manually selected during Admin signup)
- **Admin** - System administrators (manually selected during Admin signup or can be set separately)

## 🔵 Expected Behavior After Setup

1. **Student Signup**:
   - User selects "Student" mode
   - Role is automatically set to "Student"
   - No additional role selection needed

2. **Admin Signup**:
   - User selects "Admin" mode
   - User must select a role from dropdown: Nurse, Staff, or Admin
   - Role is saved to the profile

3. **Clinic Staff Users Page**:
   - Only displays users with role = "Nurse" or "Staff"
   - Students are filtered out
   - Admins can be optionally shown (configurable)

---

## ✅ After Running These SQL Commands

- ✅ Profiles table has a `role` column
- ✅ Trigger automatically creates profiles with correct role
- ✅ RLS policies allow authenticated users to read all profiles
- ✅ Ready for role-based signup in the Vue app
