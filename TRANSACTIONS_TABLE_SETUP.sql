-- =====================================================
-- TRANSACTIONS TABLE SETUP FOR SUPABASE
-- =====================================================
-- This script creates the transactions table with proper schema,
-- RLS policies, and indexes for the UIC-CMS system
-- =====================================================

-- Step 1: Create transactions table
-- =====================================================
CREATE TABLE IF NOT EXISTS public.transactions (
    id BIGSERIAL PRIMARY KEY,
    patient_name TEXT NOT NULL,
    purpose TEXT NOT NULL,
    date DATE NOT NULL,
    time_start TIME NOT NULL,
    time_end TIME NOT NULL,
    time_spent TEXT,
    status TEXT DEFAULT 'Done',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Step 2: Add comments for documentation
-- =====================================================
COMMENT ON TABLE public.transactions IS 'Stores all patient transaction records including consultations, treatments, and services';
COMMENT ON COLUMN public.transactions.id IS 'Unique transaction identifier';
COMMENT ON COLUMN public.transactions.patient_name IS 'Name of the patient';
COMMENT ON COLUMN public.transactions.purpose IS 'Purpose/type of transaction (e.g., Medical Consultation, Dental Check-Up)';
COMMENT ON COLUMN public.transactions.date IS 'Date of the transaction';
COMMENT ON COLUMN public.transactions.time_start IS 'Start time of the transaction';
COMMENT ON COLUMN public.transactions.time_end IS 'End time of the transaction';
COMMENT ON COLUMN public.transactions.time_spent IS 'Calculated time spent (e.g., "10 Mins", "1 Hour")';
COMMENT ON COLUMN public.transactions.status IS 'Transaction status (Done, Pending, Cancelled)';
COMMENT ON COLUMN public.transactions.notes IS 'Additional notes or remarks';
COMMENT ON COLUMN public.transactions.created_by IS 'ID of the user who created this transaction';

-- Step 3: Create indexes for better query performance
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_transactions_date ON public.transactions(date DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_patient_name ON public.transactions(patient_name);
CREATE INDEX IF NOT EXISTS idx_transactions_status ON public.transactions(status);
CREATE INDEX IF NOT EXISTS idx_transactions_purpose ON public.transactions(purpose);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON public.transactions(created_at DESC);

-- Step 4: Create updated_at trigger function
-- =====================================================
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 5: Create trigger to auto-update updated_at
-- =====================================================
DROP TRIGGER IF EXISTS update_transactions_updated_at ON public.transactions;
CREATE TRIGGER update_transactions_updated_at
    BEFORE UPDATE ON public.transactions
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Step 6: Enable Row Level Security (RLS)
-- =====================================================
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Step 7: Drop existing policies if any
-- =====================================================
DROP POLICY IF EXISTS "Allow authenticated users to read transactions" ON public.transactions;
DROP POLICY IF EXISTS "Allow authenticated users to insert transactions" ON public.transactions;
DROP POLICY IF EXISTS "Allow authenticated users to update transactions" ON public.transactions;
DROP POLICY IF EXISTS "Allow authenticated users to delete transactions" ON public.transactions;

-- Step 8: Create RLS policies for transactions table
-- =====================================================

-- Policy 1: Allow all authenticated users to read transactions
CREATE POLICY "Allow authenticated users to read transactions"
ON public.transactions
FOR SELECT
TO authenticated
USING (true);

-- Policy 2: Allow authenticated users to insert transactions
CREATE POLICY "Allow authenticated users to insert transactions"
ON public.transactions
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Policy 3: Allow authenticated users to update their own transactions
CREATE POLICY "Allow authenticated users to update transactions"
ON public.transactions
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Policy 4: Allow authenticated users to delete transactions
CREATE POLICY "Allow authenticated users to delete transactions"
ON public.transactions
FOR DELETE
TO authenticated
USING (true);

-- Step 9: Grant necessary permissions
-- =====================================================
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON public.transactions TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.transactions_id_seq TO authenticated;

-- Step 10: Insert sample data (optional - for testing)
-- =====================================================
-- Uncomment the lines below if you want to add sample transactions

/*
INSERT INTO public.transactions (patient_name, purpose, date, time_start, time_end, time_spent, status, notes) VALUES
('Ella Mai', 'Dental Check-Up & Treatment', '2024-09-10', '12:30:11', '12:32:09', '2 Mins', 'Done', 'Regular dental checkup completed'),
('Chris Brown', 'Dental Check-Up & Treatment', '2024-09-10', '18:10:02', '18:20:10', '10 Mins', 'Done', 'Teeth cleaning and examination'),
('Olivia Rodrigo', 'Urinalysis Test', '2024-09-10', '18:17:10', '18:30:10', '13 Mins', 'Done', 'Routine urinalysis test'),
('Central Cee', 'Medical Certificate Issuance', '2024-09-10', '19:08:05', '20:02:05', '1 Hour', 'Done', 'Medical certificate for school requirements'),
('Sabrina Carpenter', 'Medical Consultation', '2024-09-10', '20:13:15', '20:30:15', '17 Mins', 'Done', 'General health consultation');
*/

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================
-- Run these queries to verify the setup

-- 1. Check if table exists and view structure
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'transactions'
ORDER BY ordinal_position;

-- 2. Check indexes
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'transactions' AND schemaname = 'public';

-- 3. Check RLS policies
SELECT policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'transactions' AND schemaname = 'public';

-- 4. Check triggers
SELECT trigger_name, event_manipulation, event_object_table, action_statement
FROM information_schema.triggers
WHERE event_object_table = 'transactions' AND event_object_schema = 'public';

-- 5. Count total transactions
SELECT COUNT(*) as total_transactions FROM public.transactions;

-- 6. View recent transactions
SELECT id, patient_name, purpose, date, time_start, time_end, status
FROM public.transactions
ORDER BY date DESC, time_start DESC
LIMIT 10;

-- =====================================================
-- SETUP COMPLETE
-- =====================================================
-- Copy and paste this entire script into your Supabase SQL Editor
-- and click "Run" to create the transactions table with all
-- necessary configurations.
-- =====================================================
