-- ============================================
-- FIX CONSULTATIONS TABLE FOREIGN KEY
-- Change student_id to reference patients table instead of profiles
-- ============================================

-- Step 1: Drop the existing foreign key constraint
ALTER TABLE public.consultations 
DROP CONSTRAINT IF EXISTS consultations_student_id_fkey;

-- Step 2: Add new foreign key constraint to patients table
ALTER TABLE public.consultations
ADD CONSTRAINT consultations_student_id_fkey
FOREIGN KEY (student_id) REFERENCES public.patients(id)
ON DELETE CASCADE;

-- Step 3: Verify the change
-- Run this to see the new constraint:
-- SELECT 
--   tc.constraint_name, 
--   tc.table_name, 
--   kcu.column_name,
--   ccu.table_name AS foreign_table_name,
--   ccu.column_name AS foreign_column_name 
-- FROM information_schema.table_constraints AS tc 
-- JOIN information_schema.key_column_usage AS kcu
--   ON tc.constraint_name = kcu.constraint_name
-- JOIN information_schema.constraint_column_usage AS ccu
--   ON ccu.constraint_name = tc.constraint_name
-- WHERE tc.table_name = 'consultations' 
--   AND tc.constraint_type = 'FOREIGN KEY';
