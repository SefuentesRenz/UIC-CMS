# UIC-CMS Database Schema - Complete Guide

## Overview
This document defines the complete database schema for the UIC Clinic Management System with Admin and Student modes.

---

## Table of Contents
1. [Authentication & User Management](#1-authentication--user-management)
2. [Patient Management](#2-patient-management)
3. [Medical Records](#3-medical-records)
4. [Medicine Inventory](#4-medicine-inventory)
5. [Financial Transactions](#5-financial-transactions)
6. [RLS Policies](#6-rls-policies)
7. [Page-to-Table Mapping](#7-page-to-table-mapping)

---

## 1. Authentication & User Management

### `profiles` (User Profile Table)
Stores profile data for all authenticated users (students, staff, admin).

```sql
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  school_id TEXT,
  role TEXT DEFAULT 'Student' CHECK (role IN ('Student', 'Staff', 'Admin', 'Nurse')),
  status TEXT DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive', 'Suspended')),
  
  -- Student-specific fields
  college_department TEXT,
  program TEXT,
  year_section TEXT,
  contact_number TEXT,
  sex TEXT CHECK (sex IN ('Male', 'Female')),
  type TEXT CHECK (type IN ('Student', 'Faculty', 'Staff')),
  
  -- Staff-specific fields
  position TEXT,
  employee_id TEXT,
  
  -- Common fields
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_profiles_role ON public.profiles(role);
CREATE INDEX idx_profiles_school_id ON public.profiles(school_id);
CREATE INDEX idx_profiles_status ON public.profiles(status);
```

**Purpose**: Unified user profile table for authentication and authorization.

**Used By**: 
- All pages for session management
- `Dashboard.vue` (admin user info)
- `StudentHome.vue` (student profile)
- `ClinicStaffUsers.vue` (staff management)

---

## 2. Patient Management

### `patients` (Patient Records Table)
Stores patient records for clinic management (includes students, faculty, staff).

```sql
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

CREATE INDEX idx_patients_school_id ON public.patients(school_id);
CREATE INDEX idx_patients_type ON public.patients(type);
CREATE INDEX idx_patients_profile_id ON public.patients(profile_id);
CREATE INDEX idx_patients_full_name ON public.patients(LOWER(full_name));
```

**Purpose**: Patient registry for clinic operations. Allows adding patients who may not have system accounts.

**Key Fields**:
- `type`: Identifies if patient is Student, Faculty, Staff, or Nurse
- `profile_id`: Optional link to auth account (for students who can log in)
- `school_id`: Unique identifier (student ID, employee ID, etc.)

**Used By**:
- `PatientRecord.vue` (view/manage patients)
- `Consultations.vue` (search patients for consultations)
- `StudentHome.vue` (link student profile to patient record)

---

## 3. Medical Records

### `consultations` (Medical Consultation Records)
Stores consultation/visit records with diagnosis and treatment.

```sql
CREATE TABLE IF NOT EXISTS public.consultations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Patient reference
  patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
  
  -- Consultation details
  chief_complaint TEXT,
  diagnosis TEXT NOT NULL,
  treatment TEXT,
  prescription TEXT,
  notes TEXT,
  remarks TEXT,
  
  -- Prescription details
  quantity INTEGER,
  
  -- Vital signs
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

CREATE INDEX idx_consultations_patient_id ON public.consultations(patient_id);
CREATE INDEX idx_consultations_date ON public.consultations(consultation_date DESC);
CREATE INDEX idx_consultations_status ON public.consultations(status);
CREATE INDEX idx_consultations_attended_by ON public.consultations(attended_by);
```

**Purpose**: Core medical records table. Each row = one patient visit/consultation.

**Key Fields**:
- `patient_id`: References `patients.id` (NOT `profiles.id`)
- `attended_by`: Staff/nurse who handled the consultation
- `prescription`: Medicine name
- `quantity`: Amount of medicine prescribed

**Used By**:
- `Consultations.vue` (add/view consultations - Admin)
- `StudentHome.vue` → Medical History tab (student view)
- `Dashboard.vue` (consultation statistics)

---

## 4. Medicine Inventory

### `medicine` (Medicine Stock Table)
Stores medicine inventory and stock information.

```sql
CREATE TABLE IF NOT EXISTS public.medicine (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
  unit TEXT DEFAULT 'pcs',
  category TEXT,
  date_added DATE DEFAULT CURRENT_DATE,
  expiration_date DATE NOT NULL,
  status TEXT DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive', 'Expired')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_medicine_name ON public.medicine(LOWER(name));
CREATE INDEX idx_medicine_status ON public.medicine(status);
CREATE INDEX idx_medicine_expiration ON public.medicine(expiration_date);
```

**Purpose**: Medicine inventory management for prescriptions and stock tracking.

**Key Fields**:
- `name`: Medicine name (searchable in Consultations)
- `quantity`: Current stock quantity
- `expiration_date`: For tracking expired medicines

**Used By**:
- `Medicine.vue` (manage inventory)
- `Consultations.vue` (search medicine for prescriptions)
- `Dashboard.vue` (medicine statistics)

---

## 5. Medicine Inventory Transactions

### `transactions` (Medicine Inventory Movement Records)
Tracks medicine dispensing, restocking, and inventory adjustments.

**⚠️ IMPORTANT NOTE**: This is a **FREE UNIVERSITY CLINIC** in the Philippines. All consultations and medicines are provided at **NO COST** to students, faculty, and staff. This table tracks **inventory movements**, not billing.

```sql
CREATE TABLE IF NOT EXISTS public.transactions (
  id BIGSERIAL PRIMARY KEY,
  patient_id UUID REFERENCES public.patients(id),
  consultation_id UUID REFERENCES public.consultations(id),
  medicine_id BIGINT REFERENCES public.medicine(id),
  
  -- Transaction details (for inventory tracking, not billing)
  quantity INTEGER NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('Dispensed', 'Restocked', 'Adjustment', 'Expired', 'Donated')),
  description TEXT,
  notes TEXT,
  
  -- Audit
  performed_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_transactions_patient_id ON public.transactions(patient_id);
CREATE INDEX idx_transactions_medicine_id ON public.transactions(medicine_id);
CREATE INDEX idx_transactions_created_at ON public.transactions(created_at DESC);
CREATE INDEX idx_transactions_type ON public.transactions(type);
```

**Purpose**: Track medicine inventory movements for audit and stock management (NOT for billing).

**Transaction Types**:
- `Dispensed`: Medicine given to patient (consultation-linked)
- `Restocked`: New medicine inventory received
- `Adjustment`: Stock correction/inventory count update
- `Expired`: Medicine removed due to expiration
- `Donated`: Medicine received as donation

**Used By**:
- `Transactions.vue` (view dispensing history and inventory movements)
- `Medicine.vue` (track stock changes)
- `Dashboard.vue` (medicine dispensing statistics)

---

## 6. RLS Policies

### For `consultations` table:

```sql
ALTER TABLE public.consultations ENABLE ROW LEVEL SECURITY;

-- Staff/Admin: Full access
CREATE POLICY "staff_admin_full_access"
  ON public.consultations
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role IN ('Admin', 'Staff', 'Nurse')
    )
  );

-- Students: Read only their own consultations
CREATE POLICY "student_read_own_consultations"
  ON public.consultations
  FOR SELECT
  TO authenticated
  USING (
    patient_id = (
      SELECT id FROM public.patients
      WHERE profile_id = auth.uid()
    )
  );
```

### For `patients` table:

```sql
ALTER TABLE public.patients ENABLE ROW LEVEL SECURITY;

-- Staff/Admin: Full access
CREATE POLICY "staff_admin_manage_patients"
  ON public.patients
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Students: Read only their own patient record
CREATE POLICY "student_read_own_record"
  ON public.patients
  FOR SELECT
  TO authenticated
  USING (profile_id = auth.uid());
```

---

## 7. Page-to-Table Mapping

### Admin Mode Pages

| Page | Tables Used | Operations |
|------|-------------|------------|
| `Dashboard.vue` | `profiles`, `patients`, `consultations`, `medicine`, `transactions` | Read (statistics/charts) |
| `Consultations.vue` | `consultations`, `patients`, `medicine`, `profiles` | Create, Read, Search |
| `PatientRecord.vue` | `patients`, `consultations`, `transactions` | Create, Read, Update, Delete |
| `Medicine.vue` | `medicine`, `transactions` | Create, Read, Update, Delete |
| `Transactions.vue` | `transactions`, `patients`, `profiles` | Create, Read |
| `ClinicStaffUsers.vue` | `profiles` | Read (filtered by role) |

### Student Mode Pages

| Page | Tables Used | Operations |
|------|-------------|------------|
| `StudentHome.vue` → Profile | `profiles` | Read, Update (own profile) |
| `StudentHome.vue` → Medical History | `consultations`, `patients` | Read (filtered by patient_id) |
| `StudentHome.vue` → Appointments | `appointments` (future) | Read, Create |

---

## 8. Setup Instructions

### Step 1: Run SQL scripts in this order:

```sql
-- 1. Create profiles table (if not exists from auth trigger)
-- Run COMPLETE_DATABASE_SETUP.sql sections for profiles

-- 2. Create patients table
-- Run CREATE_PATIENTS_TABLE.sql

-- 3. Create consultations table
-- Run CREATE_CONSULTATIONS_TABLE.sql

-- 4. Create medicine table
-- Run sections from MEDICINE_MODULE_SETUP.md or equivalent

-- 5. Create transactions table
-- Run sections from TRANSACTIONS_TABLE_SETUP.sql or create manually

-- 6. Set up RLS policies (see section 6 above)
```

### Step 2: Link student profiles to patients

When a student signs up or logs in for the first time:
1. Create/update record in `profiles` (via signup trigger)
2. Create corresponding record in `patients` with `profile_id = profiles.id`
3. Use `school_id` to link the two tables

### Step 3: Consultations workflow

When admin adds a consultation:
1. Search for patient by name/school_id in `patients` table
2. Select patient → get `patient.id`
3. Save consultation with `patient_id = patient.id`
4. Student can view via `StudentHome.vue` by matching `patients.profile_id = auth.uid()`

---

## 9. Key Relationships

```
auth.users (Supabase Auth)
    ↓ (ON DELETE CASCADE)
profiles (id = auth.users.id)
    ↓ (profile_id, ON DELETE SET NULL)
patients (id = UUID)
    ↓ (patient_id, ON DELETE CASCADE)
consultations
    ↓ (consultation_id, optional)
transactions

medicine (referenced in consultations.prescription)
```

---

## 10. Important Notes

1. **Type Field**: The `type` field in `patients` table distinguishes:
   - `Student`: Regular students
   - `Faculty`: Teaching staff
   - `Staff`: Administrative staff
   - `Nurse`: Clinic nurses

2. **Profile vs Patient**:
   - `profiles`: For authentication and app access
   - `patients`: For clinic medical records
   - A student has both: profile (to login) + patient record (for medical history)
   - Faculty/staff may only have patient records (no login)

3. **Role vs Type**:
   - `profiles.role`: System access level (Student, Staff, Admin, Nurse)
   - `patients.type`: Clinical classification (Student, Faculty, Staff, Nurse)

4. **Foreign Keys**:
   - `consultations.patient_id` → `patients.id` (not `profiles.id`)
   - Always use `patients.id` for medical records
   - Use `profiles.id` for system authentication/authorization

5. **Name-Based Matching** (CRITICAL):
   - Student accounts link to consultations by **matching full names**
   - Primary strategy: Match `profiles.full_name` with `patients.full_name` (case-insensitive)
   - Fallback strategy: Match by `school_id` if name match fails
   - This allows consultations to be visible even if created before student account existed
   - Example: Patient record "Gi Linghon" created → Consultation added → Student "Gi Linghon" signs up → Sees existing consultations automatically

---

## Quick Reference: Column Names

| Table | ID Column | Link to Patients | Link to Profiles |
|-------|-----------|------------------|------------------|
| `profiles` | `id` (UUID) | - | `id = auth.users.id` |
| `patients` | `id` (UUID) | - | `profile_id → profiles.id` |
| `consultations` | `id` (UUID) | `patient_id → patients.id` | `attended_by → profiles.id` |
| `medicine` | `id` (BIGSERIAL) | - | - |
| `transactions` | `id` (BIGSERIAL) | `patient_id → patients.id` | `created_by → profiles.id` |

---

## End of Schema Documentation
