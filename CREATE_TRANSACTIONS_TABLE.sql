-- ============================================
-- CREATE TRANSACTIONS TABLE
-- For tracking medicine inventory movements (NOT billing)
-- University Clinic - FREE services model
-- ============================================

-- ⚠️ IMPORTANT: This is a FREE CLINIC
-- All consultations and medicines are provided at NO COST
-- This table tracks INVENTORY MOVEMENTS, not financial transactions

-- Create transactions table
CREATE TABLE IF NOT EXISTS public.transactions (
  id BIGSERIAL PRIMARY KEY,
  
  -- References
  patient_id UUID REFERENCES public.patients(id) ON DELETE SET NULL,
  consultation_id UUID REFERENCES public.consultations(id) ON DELETE SET NULL,
  medicine_id BIGINT REFERENCES public.medicine(id) ON DELETE SET NULL,
  
  -- Inventory movement details
  quantity INTEGER NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('Dispensed', 'Restocked', 'Adjustment', 'Expired', 'Donated')),
  description TEXT,
  notes TEXT,
  
  -- Audit fields
  performed_by UUID REFERENCES public.profiles(id),
  performed_by_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_transactions_patient_id ON public.transactions(patient_id);
CREATE INDEX IF NOT EXISTS idx_transactions_consultation_id ON public.transactions(consultation_id);
CREATE INDEX IF NOT EXISTS idx_transactions_medicine_id ON public.transactions(medicine_id);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON public.transactions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON public.transactions(type);
CREATE INDEX IF NOT EXISTS idx_transactions_performed_by ON public.transactions(performed_by);

-- Enable Row Level Security
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Allow authenticated users to read/manage transactions
CREATE POLICY "Allow authenticated users to read transactions"
  ON public.transactions FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated users to insert transactions"
  ON public.transactions FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update transactions"
  ON public.transactions FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow authenticated users to delete transactions"
  ON public.transactions FOR DELETE
  TO authenticated
  USING (true);

-- Example: Create transaction when medicine is dispensed
-- This would typically be done in application code when a consultation is created

COMMENT ON TABLE public.transactions IS 'Tracks medicine inventory movements for a FREE university clinic (no billing)';
COMMENT ON COLUMN public.transactions.type IS 'Dispensed: Given to patient | Restocked: New inventory | Adjustment: Stock correction | Expired: Removed | Donated: Received donation';
COMMENT ON COLUMN public.transactions.quantity IS 'Positive for restock/donated, negative for dispensed/expired';
COMMENT ON COLUMN public.transactions.consultation_id IS 'Links to consultation if medicine was dispensed during visit';

-- Verify the table structure
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'transactions'
ORDER BY ordinal_position;
