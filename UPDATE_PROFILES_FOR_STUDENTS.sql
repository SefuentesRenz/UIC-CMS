-- ============================================
-- UPDATE PROFILES TABLE FOR STUDENT INFORMATION
-- This ensures all required fields for students exist
-- ============================================

-- Add student-specific columns if they don't exist
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS contact_number TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS college_department TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS program TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS year_section TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS sex TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS type TEXT DEFAULT 'Student';

-- Add updated_at if it doesn't exist
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Create trigger to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS set_profiles_updated_at ON public.profiles;

-- Create trigger on profiles table
CREATE TRIGGER set_profiles_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION update_profiles_updated_at();

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_profiles_type ON public.profiles(type);
CREATE INDEX IF NOT EXISTS idx_profiles_sex ON public.profiles(sex);
CREATE INDEX IF NOT EXISTS idx_profiles_college ON public.profiles(college_department);

-- Verify the columns exist
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'profiles'
  AND column_name IN (
    'contact_number',
    'college_department',
    'program',
    'year_section',
    'sex',
    'type',
    'updated_at'
  )
ORDER BY column_name;

-- Sample update query (commented out - for reference)
-- UPDATE public.profiles
-- SET 
--   contact_number = '09171234567',
--   college_department = 'College of Engineering',
--   program = 'BS Computer Science',
--   year_section = '3rd Year',
--   sex = 'Male',
--   type = 'Student'
-- WHERE id = 'USER_UUID_HERE';
