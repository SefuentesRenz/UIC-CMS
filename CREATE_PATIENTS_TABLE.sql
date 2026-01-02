-- ============================================
-- CREATE PATIENTS TABLE
-- For storing patient records (students, faculty, staff)
-- ============================================

-- Create patients table with all required fields
CREATE TABLE IF NOT EXISTS public.patients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Basic Information
  school_id TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  contact_number TEXT NOT NULL,
  
  -- Academic/Professional Information
  college_department TEXT NOT NULL,
  program TEXT NOT NULL,
  year_section TEXT NOT NULL,
  
  -- Demographics
  sex TEXT NOT NULL CHECK (sex IN ('Male', 'Female')),
  type TEXT NOT NULL CHECK (type IN ('Student', 'Faculty', 'Staff', 'Nurse')),
  
  -- Optional: Link to profiles table (if patient has auth account)
  profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  
  -- Audit fields
  created_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_patients_school_id ON public.patients(school_id);
CREATE INDEX IF NOT EXISTS idx_patients_type ON public.patients(type);
CREATE INDEX IF NOT EXISTS idx_patients_created_by ON public.patients(created_by);
CREATE INDEX IF NOT EXISTS idx_patients_profile_id ON public.patients(profile_id);

-- Enable Row Level Security
ALTER TABLE public.patients ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Allow authenticated users to read/manage patients
CREATE POLICY "Allow authenticated users to read patients"
  ON public.patients FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated users to insert patients"
  ON public.patients FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update patients"
  ON public.patients FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow authenticated users to delete patients"
  ON public.patients FOR DELETE
  TO authenticated
  USING (true);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_patients_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_patients_timestamp
  BEFORE UPDATE ON public.patients
  FOR EACH ROW
  EXECUTE FUNCTION update_patients_updated_at();

-- If table already exists, add missing columns
DO $$ 
BEGIN
  -- Add type column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'patients' 
    AND column_name = 'type'
  ) THEN
    ALTER TABLE public.patients ADD COLUMN type TEXT NOT NULL DEFAULT 'Student' CHECK (type IN ('Student', 'Faculty', 'Staff', 'Nurse'));
    CREATE INDEX IF NOT EXISTS idx_patients_type ON public.patients(type);
  END IF;

  -- Add profile_id column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'patients' 
    AND column_name = 'profile_id'
  ) THEN
    ALTER TABLE public.patients ADD COLUMN profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL;
    CREATE INDEX IF NOT EXISTS idx_patients_profile_id ON public.patients(profile_id);
  END IF;
END $$;

-- Verify the table structure
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'patients'
ORDER BY ordinal_position;
