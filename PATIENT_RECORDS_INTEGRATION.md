# Patient Records System - Complete Integration Summary

## Overview
This document provides a complete reference for the Patient Records system integrated with Supabase in the UIC-CMS application.

## Architecture

### Database Schema
```sql
CREATE TABLE patients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  school_id VARCHAR NOT NULL UNIQUE,
  full_name VARCHAR NOT NULL,
  email VARCHAR NOT NULL,
  contact_number VARCHAR NOT NULL,
  college_department VARCHAR NOT NULL,
  program VARCHAR NOT NULL,
  year_section VARCHAR NOT NULL,
  sex VARCHAR CHECK (sex IN ('Male', 'Female')),
  type VARCHAR CHECK (type IN ('Student', 'Faculty', 'Staff')),
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Required RLS Policies
CREATE POLICY "Enable read access for authenticated users"
ON patients FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable insert for authenticated users"
ON patients FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Enable update for owners"
ON patients FOR UPDATE
TO authenticated
USING (auth.uid() = created_by);

CREATE POLICY "Enable delete for owners"
ON patients FOR DELETE
TO authenticated
USING (auth.uid() = created_by);
```

## Core Components

### 1. PatientRecord.vue (Main View)

**Location:** `src/views/PatientRecord.vue`

**Responsibilities:**
- Display patient table with filtering and search
- Handle patient CRUD operations
- Manage modal states (Add/View Patient)
- Integrate with Supabase for data operations

**Key Features:**
- Real-time search across all patient fields
- Filter by patient type (Student/Faculty/Staff)
- Pagination-ready structure
- Test data seeding capability

**Core Functions:**

#### fetchPatients()
Retrieves all patients from Supabase ordered by creation date.

```javascript
const fetchPatients = async () => {
  try {
    isLoading.value = true
    error.value = null
    
    const { data, error: err } = await supabase
      .from('patients')
      .select('*')
      .order('created_at', { ascending: false })
    
    if (err) throw err
    
    patients.value = data
  } catch (err) {
    console.error('Error fetching patients:', err)
    error.value = 'Failed to load patients'
  } finally {
    isLoading.value = false
  }
}
```

**Usage:** Called on component mount and after add/edit operations

---

#### handleAddPatient(patientData)
Inserts a new patient record into the database.

```javascript
const handleAddPatient = async (patientData) => {
  try {
    isLoading.value = true
    error.value = null

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    
    if (authError || !user) {
      throw new Error('User must be authenticated')
    }

    // Map form data to database schema
    const newPatient = {
      school_id: patientData.idNumber,
      full_name: patientData.fullName,
      email: patientData.email,
      contact_number: patientData.contactNumber,
      college_department: patientData.department,
      program: patientData.program,
      year_section: patientData.yearSection,
      sex: patientData.sex,
      type: patientData.type,
      created_by: user.id,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }

    const { data, error: err } = await supabase
      .from('patients')
      .insert([newPatient])
      .select()
      .single()

    if (err) throw err

    patients.value = [data, ...(patients.value || [])]
    showAddPatientModal.value = false
    error.value = null

  } catch (err) {
    console.error('Error adding patient:', err)
    error.value = `Failed to add patient: ${err.message}`
  } finally {
    isLoading.value = false
  }
}
```

**Input:** Patient data object from AddPatient component
**Output:** Updates local patients array and closes modal

---

#### viewPatient(patient)
Fetches detailed information for a specific patient.

```javascript
const viewPatient = async (patient) => {
  try {
    isLoading.value = true
    error.value = null

    const { data, error: err } = await supabase
      .from('patients')
      .select('*')
      .eq('id', patient.id)
      .single()

    if (err) throw err

    selectedPatient.value = data
    showViewPatientModal.value = true

  } catch (err) {
    console.error('Error fetching patient details:', err)
    error.value = 'Failed to load patient details'
  } finally {
    isLoading.value = false
  }
}
```

**Input:** Patient object with `id` property
**Output:** Opens ViewPatient modal with full patient details

---

#### seedTestData()
Populates the database with sample patient data.

```javascript
const seedTestData = async () => {
  try {
    if (!confirm('This will add 10 sample patients to the database. Continue?')) {
      return
    }

    isLoading.value = true
    error.value = null

    const result = await seedPatients()

    if (result.success) {
      console.log(`✅ Successfully seeded ${result.count} patients`)
      await fetchPatients()
    } else {
      throw new Error(result.error)
    }

  } catch (err) {
    console.error('Error seeding test data:', err)
    error.value = `Failed to seed test data: ${err.message}`
  } finally {
    isLoading.value = false
  }
}
```

**Usage:** Triggered by "🌱 Seed Test Data" button

---

#### filteredPatients (Computed)
Applies search and type filters to the patient list.

```javascript
const filteredPatients = computed(() => {
  let filtered = patients.value

  // Apply type filter
  if (activeFilter.value !== 'all') {
    filtered = filtered.filter(p => 
      p.type?.toLowerCase() === activeFilter.value.toLowerCase()
    )
  }

  // Apply search filter
  const search = (tableSearch.value || globalSearch.value || '').toLowerCase().trim()
  
  if (search) {
    filtered = filtered.filter(patient => {
      return (
        patient.full_name?.toLowerCase().includes(search) ||
        patient.school_id?.toLowerCase().includes(search) ||
        patient.email?.toLowerCase().includes(search) ||
        patient.college_department?.toLowerCase().includes(search) ||
        patient.program?.toLowerCase().includes(search) ||
        patient.year_section?.toLowerCase().includes(search) ||
        patient.type?.toLowerCase().includes(search)
      )
    })
  }

  return filtered
})
```

**Reactive Dependencies:** `patients`, `activeFilter`, `tableSearch`, `globalSearch`

---

### 2. AddPatient.vue (Add Patient Modal)

**Location:** `src/components/AddPatient.vue`

**Responsibilities:**
- Provide form for adding new patients
- Validate input data
- Emit properly formatted data to parent component

**Key Features:**
- Dynamic form fields based on patient type
- Client-side validation
- Event-based communication (no alerts)

**Core Functions:**

#### handleSubmit()
Validates and emits patient data to parent component.

```javascript
const handleSubmit = () => {
  if (!validateForm()) {
    return
  }

  // Map form fields to database schema
  const patientData = {
    idNumber: formData.value.schoolId,
    fullName: formData.value.fullName,
    email: formData.value.email,
    contactNumber: formData.value.contactNumber,
    department: formData.value.collegeDept,
    program: formData.value.program,
    yearSection: formData.value.yearSection,
    sex: formData.value.sex,
    type: formData.value.type
  }

  emit('add-patient', patientData)
}
```

**Validation:**
```javascript
const validateForm = () => {
  const { fullName, collegeDept, schoolId, program, yearSection, email, contactNumber, sex, type } = formData.value

  if (!fullName || !collegeDept || !schoolId || !program || !yearSection || !email || !contactNumber || !sex || !type) {
    emit('validation-error', 'Please fill in all fields')
    return false
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (!emailRegex.test(email)) {
    emit('validation-error', 'Please enter a valid email address')
    return false
  }

  const phoneRegex = /^09\d{9}$/
  if (!phoneRegex.test(contactNumber)) {
    emit('validation-error', 'Please enter a valid Philippine mobile number (09XXXXXXXXX)')
    return false
  }

  return true
}
```

**Events Emitted:**
- `add-patient`: When form is valid (payload: patient data object)
- `validation-error`: When validation fails (payload: error message string)
- `close`: When user cancels

---

### 3. ViewPatient.vue (View Patient Modal)

**Location:** `src/components/ViewPatient.vue`

**Responsibilities:**
- Display detailed patient information
- Provide edit and delete actions (if implemented)
- Show patient history and medical records (future feature)

**Props:**
```javascript
props: {
  patient: {
    type: Object,
    required: true
  }
}
```

**Data Displayed:**
- Full Name
- School/Employee ID
- Email & Contact Number
- Department & Program
- Year/Section (for students)
- Sex & Type
- Creation timestamp

---

### 4. Patient Seeder Utility

**Location:** `src/lib/patientSeeder.js`

**Responsibilities:**
- Provide sample patient data
- Bulk insert functionality
- Random patient generation
- Database cleanup utilities

**Core Functions:**

#### seedPatients(patients)
```javascript
export async function seedPatients(patients = samplePatients) {
  try {
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    
    if (authError || !user) {
      return {
        success: false,
        error: 'User must be authenticated to seed patients'
      }
    }

    const patientsWithMetadata = patients.map(patient => ({
      ...patient,
      created_by: user.id,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }))

    const { data, error } = await supabase
      .from('patients')
      .insert(patientsWithMetadata)
      .select()

    if (error) {
      return {
        success: false,
        error: error.message
      }
    }

    return {
      success: true,
      data,
      count: data.length
    }

  } catch (error) {
    return {
      success: false,
      error: error.message
    }
  }
}
```

#### Sample Dataset
10 pre-configured patients:
- 5 Students (CS, Business, Psychology, Civil Engineering, Biology)
- 2 Faculty (Medicine, Computer Science)
- 2 Staff (Registrar, Medical Staff)
- 1 additional Engineering student

#### generateRandomPatients(count)
Generates `count` number of random patient records with realistic data.

---

## Field Mapping Reference

| Frontend (AddPatient) | Backend (Supabase) | Type | Required |
|-----------------------|-------------------|------|----------|
| `idNumber` | `school_id` | STRING | ✅ |
| `fullName` | `full_name` | STRING | ✅ |
| `email` | `email` | STRING | ✅ |
| `contactNumber` | `contact_number` | STRING | ✅ |
| `department` | `college_department` | STRING | ✅ |
| `program` | `program` | STRING | ✅ |
| `yearSection` | `year_section` | STRING | ✅ |
| `sex` | `sex` | STRING | ✅ |
| `type` | `type` | STRING | ✅ |
| - | `created_by` | UUID | Auto |
| - | `created_at` | TIMESTAMP | Auto |
| - | `updated_at` | TIMESTAMP | Auto |

## Data Flow

### Adding a Patient
```
User clicks "+ Add Patient"
  ↓
AddPatient modal opens
  ↓
User fills form and clicks Submit
  ↓
AddPatient.vue validates data
  ↓
AddPatient emits 'add-patient' event with data
  ↓
PatientRecord.vue receives event
  ↓
handleAddPatient() maps data to schema
  ↓
Supabase INSERT operation
  ↓
New patient added to local state
  ↓
Modal closes, table updates
```

### Viewing a Patient
```
User clicks "View" button on table row
  ↓
PatientRecord.vue calls viewPatient(patient)
  ↓
Supabase SELECT operation (fetch full details)
  ↓
selectedPatient updated
  ↓
ViewPatient modal opens with data
```

### Seeding Test Data
```
User clicks "🌱 Seed Test Data"
  ↓
Confirmation dialog appears
  ↓
seedTestData() called
  ↓
Imports seedPatients() from utility
  ↓
Supabase bulk INSERT (10 patients)
  ↓
fetchPatients() refreshes table
  ↓
Success message logged
```

## Error Handling

### Authentication Errors
```javascript
if (authError || !user) {
  throw new Error('User must be authenticated')
}
```

### RLS Policy Errors
```javascript
if (err.code === '42501') {
  error.value = 'Permission denied. Check RLS policies.'
}
```

### Network Errors
```javascript
try {
  // Supabase operation
} catch (err) {
  console.error('Error:', err)
  error.value = `Failed to perform operation: ${err.message}`
}
```

### Validation Errors
```javascript
// Email validation
if (!emailRegex.test(email)) {
  emit('validation-error', 'Please enter a valid email address')
  return false
}

// Phone validation
if (!phoneRegex.test(contactNumber)) {
  emit('validation-error', 'Please enter a valid Philippine mobile number')
  return false
}
```

## Testing Checklist

### Manual Testing
- [ ] Login as authenticated user
- [ ] Navigate to Patient Records page
- [ ] Click "🌱 Seed Test Data" button
- [ ] Verify 10 patients appear in table
- [ ] Test search functionality (search for "MARIA")
- [ ] Test filter chips (Student/Faculty/Staff)
- [ ] Click "+ Add Patient" button
- [ ] Fill form with valid data
- [ ] Submit and verify patient appears
- [ ] Click "View" on a patient
- [ ] Verify all details display correctly
- [ ] Test with invalid data (empty fields, bad email)

### Data Validation
- [ ] School IDs are unique
- [ ] Email format is valid
- [ ] Phone numbers match Philippine format (09XXXXXXXXX)
- [ ] All required fields are populated
- [ ] `created_by` matches authenticated user
- [ ] Timestamps are properly set

### Performance
- [ ] Table loads within 2 seconds
- [ ] Search is responsive (< 100ms)
- [ ] Filter updates instantly
- [ ] Modal animations are smooth

## Troubleshooting

### "Failed to load patients"
**Cause:** RLS policy blocking SELECT
**Solution:** Verify SELECT policy allows authenticated users:
```sql
CREATE POLICY "Enable read access for authenticated users"
ON patients FOR SELECT TO authenticated USING (true);
```

### "User must be authenticated"
**Cause:** Session not properly initialized
**Solution:** Ensure Login.vue calls `supabase.auth.setSession()` after sign-in

### "Field mapping mismatch"
**Cause:** Frontend/backend field name inconsistency
**Solution:** Use field mapping reference table above

### "Duplicate school_id"
**Cause:** Attempting to insert patient with existing school_id
**Solution:** Clear database or use unique IDs for test data

## Future Enhancements

### Planned Features
- [ ] Edit patient functionality
- [ ] Delete patient with confirmation
- [ ] Export patient list to CSV
- [ ] Advanced search with filters
- [ ] Pagination for large datasets
- [ ] Patient medical history tracking
- [ ] Appointment scheduling integration
- [ ] Real-time updates with Supabase subscriptions

### Optimizations
- [ ] Implement virtual scrolling for large tables
- [ ] Add debounce to search input
- [ ] Cache frequently accessed patient data
- [ ] Lazy load patient details on view
- [ ] Optimize Supabase queries with indexes

## Support & Resources

- **Supabase Docs:** https://supabase.com/docs
- **Vue 3 Composition API:** https://vuejs.org/api/composition-api-setup.html
- **Patient Seeder Usage:** See `PATIENT_SEEDER_USAGE.md`

---

**Last Updated:** 2025
**System Version:** UIC-CMS v1.0.0
**Integration Status:** ✅ Fully Operational
