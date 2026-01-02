-- ============================================
-- CREATE CONSULTATIONS TABLE
-- For tracking patient consultations and medical records
-- ============================================

-- Drop existing table if you want to recreate it
-- DROP TABLE IF EXISTS public.consultations CASCADE;

-- Create consultations table
CREATE TABLE IF NOT EXISTS public.consultations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Patient reference (connects to patients table)
  student_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
  
  -- Consultation details
  diagnosis TEXT NOT NULL,
  prescription TEXT,
  notes TEXT,
  remarks TEXT,
  treatment TEXT,
  
  -- Medical information
  quantity INTEGER,
  chief_complaint TEXT,
  
  -- Vital signs (optional)
  temperature NUMERIC(4,1),
  blood_pressure TEXT,
  heart_rate INTEGER,
  weight NUMERIC(5,2),
  
  -- Staff information
  attended_by UUID REFERENCES public.profiles(id),
  attended_by_name TEXT,
  
  -- Dates
  consultation_date TIMESTAMPTZ DEFAULT NOW(),
  follow_up_date DATE,
  
  -- Status
  status TEXT DEFAULT 'Completed' CHECK (status IN ('Pending', 'In Progress', 'Completed')),
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_consultations_student_id ON public.consultations(student_id);
CREATE INDEX IF NOT EXISTS idx_consultations_date ON public.consultations(consultation_date DESC);
CREATE INDEX IF NOT EXISTS idx_consultations_status ON public.consultations(status);
CREATE INDEX IF NOT EXISTS idx_consultations_attended_by ON public.consultations(attended_by);

-- Enable Row Level Security
ALTER TABLE public.consultations ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Allow authenticated users to manage consultations
CREATE POLICY "Allow authenticated users to read consultations"
  ON public.consultations FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated users to insert consultations"
  ON public.consultations FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update consultations"
  ON public.consultations FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow authenticated users to delete consultations"
  ON public.consultations FOR DELETE
  TO authenticated
  USING (true);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_consultations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_consultations_timestamp
  BEFORE UPDATE ON public.consultations
  FOR EACH ROW
  EXECUTE FUNCTION update_consultations_updated_at();

-- Verify the table was created
SELECT 
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'consultations'
  AND table_schema = 'public'
ORDER BY ordinal_position;
