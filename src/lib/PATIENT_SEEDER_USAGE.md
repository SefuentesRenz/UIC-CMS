# Patient Seeder Utility - Usage Guide

## Overview
The Patient Seeder provides utilities to populate your UIC-CMS database with test patient data for development and testing purposes.

## Features
- ✅ Pre-defined sample dataset (10 patients with diverse profiles)
- ✅ Bulk insert functionality
- ✅ Random patient generator for large datasets
- ✅ Database cleanup utilities
- ✅ Browser console integration

## Quick Start

### Method 1: UI Button (Easiest)
1. Navigate to **Patient Records** page
2. Click the **🌱 Seed Test Data** button
3. Confirm the action
4. 10 sample patients will be added automatically

### Method 2: Import in Vue Component
```javascript
import { seedPatients, samplePatients } from '@/lib/patientSeeder.js'

// In your component method
const loadTestData = async () => {
  const result = await seedPatients()
  if (result.success) {
    console.log(`Added ${result.count} patients`)
  }
}
```

### Method 3: Browser Console
The seeder automatically exposes utilities to `window.patientSeeder`:

```javascript
// Seed with default sample data (10 patients)
await window.patientSeeder.seed()

// Generate and seed random patients
const randomPatients = window.patientSeeder.generate(20) // Generate 20 patients
await window.patientSeeder.seed(randomPatients)

// View all patients
const patients = await window.patientSeeder.getAll()
console.table(patients)

// Clear all patients (⚠️ USE WITH CAUTION)
await window.patientSeeder.clear()

// View sample data without inserting
console.table(window.patientSeeder.samples)
```

## Sample Data Overview

The default dataset includes:
- **5 Students**: Various programs (CS, Business, Psychology, Civil Eng, Biology)
- **2 Faculty Members**: Medicine and Computer Science departments
- **2 Staff Members**: Registrar and Medical staff
- **1 Engineering Student**: Civil Engineering program

### Sample Patient Structure
```javascript
{
  school_id: '2021001234',
  full_name: 'MARIA CLARA SANTOS',
  email: 'maria.santos@uic.edu.ph',
  contact_number: '09171234567',
  college_department: 'College of Engineering',
  program: 'BS Computer Science',
  year_section: '3-A',
  sex: 'Female',
  type: 'Student'
}
```

## API Reference

### `seedPatients(patients?)`
Inserts patient records into the database.

**Parameters:**
- `patients` (Array, optional): Array of patient objects. Defaults to `samplePatients`

**Returns:**
```javascript
{
  success: true,
  data: [...], // Inserted records
  count: 10
}
```

**Example:**
```javascript
import { seedPatients, samplePatients } from '@/lib/patientSeeder.js'

// Use default sample data
const result = await seedPatients()

// Use custom data
const customPatients = [{ /* patient object */ }]
const result = await seedPatients(customPatients)
```

---

### `generateRandomPatients(count)`
Generates random patient data for testing.

**Parameters:**
- `count` (Number): Number of patients to generate (default: 10)

**Returns:** Array of patient objects

**Example:**
```javascript
import { generateRandomPatients, seedPatients } from '@/lib/patientSeeder.js'

// Generate 50 random patients
const patients = generateRandomPatients(50)

// Insert them into database
await seedPatients(patients)
```

---

### `getAllPatients()`
Fetches all patients from the database.

**Returns:** Array of patient records ordered by `created_at` DESC

**Example:**
```javascript
import { getAllPatients } from '@/lib/patientSeeder.js'

const patients = await getAllPatients()
console.log(`Total patients: ${patients.length}`)
```

---

### `clearAllPatients()`
⚠️ **Deletes all patient records** from the database.

**Returns:**
```javascript
{
  success: true
}
```

**Example:**
```javascript
import { clearAllPatients } from '@/lib/patientSeeder.js'

// Clear all data (use with caution!)
const result = await clearAllPatients()
if (result.success) {
  console.log('All patients cleared')
}
```

## Database Schema

The seeder expects a `patients` table with the following structure:

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
  sex VARCHAR NOT NULL CHECK (sex IN ('Male', 'Female')),
  type VARCHAR NOT NULL CHECK (type IN ('Student', 'Faculty', 'Staff')),
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

## Best Practices

### Development Workflow
1. **Start Clean**: Use `clearAllPatients()` to remove old test data
2. **Seed Data**: Use `seedPatients()` to add fresh test data
3. **Test Features**: Verify search, filtering, and CRUD operations
4. **Repeat**: Clear and re-seed as needed

### Production Safety
- ⚠️ **Never use seeder in production** - Remove import or gate with environment check
- Consider adding a `.env` check:
  ```javascript
  if (import.meta.env.MODE === 'development') {
    // Allow seeding
  }
  ```

### Performance Tips
- For large datasets (100+ records), use batch inserts
- Supabase has a default limit of 1000 rows per insert
- Consider chunking for very large datasets:
  ```javascript
  const chunk = (arr, size) => 
    Array.from({ length: Math.ceil(arr.length / size) }, (_, i) =>
      arr.slice(i * size, i * size + size)
    )

  const patients = generateRandomPatients(5000)
  const batches = chunk(patients, 1000)
  
  for (const batch of batches) {
    await seedPatients(batch)
  }
  ```

## Troubleshooting

### "User must be authenticated to seed patients"
**Solution:** Log in to the application before seeding data. The seeder requires an authenticated user to set `created_by` field.

### "new row violates row-level security policy"
**Solution:** Ensure RLS policies allow INSERT for authenticated users:
```sql
CREATE POLICY "Enable insert for authenticated users"
ON patients FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = created_by);
```

### "duplicate key value violates unique constraint"
**Solution:** The `school_id` field must be unique. Either:
1. Clear existing data with `clearAllPatients()`
2. Modify `school_id` values to avoid collisions
3. Generate new random patients

### Import errors with Supabase.js
**Solution:** Ensure `src/lib/Supabase.js` exports the initialized client:
```javascript
// src/lib/Supabase.js
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseKey)
```

## Examples

### Scenario: Testing Search Functionality
```javascript
// 1. Clear existing data
await window.patientSeeder.clear()

// 2. Add diverse test data
await window.patientSeeder.seed()

// 3. Test search with known values
// Search for "MARIA" should return 1 result
// Search for "Engineering" should return 2 results
// Filter by "Student" should return 5 results
```

### Scenario: Performance Testing
```javascript
// Generate large dataset
const patients = window.patientSeeder.generate(500)

// Seed in batches
const batches = []
for (let i = 0; i < patients.length; i += 100) {
  batches.push(patients.slice(i, i + 100))
}

for (const batch of batches) {
  await window.patientSeeder.seed(batch)
  console.log(`Seeded batch of ${batch.length}`)
}
```

### Scenario: Custom Department Testing
```javascript
// Create custom dataset for specific department
const engineeringStudents = [
  {
    school_id: '2023CE001',
    full_name: 'TEST STUDENT ONE',
    email: 'test1@uic.edu.ph',
    contact_number: '09171111111',
    college_department: 'College of Engineering',
    program: 'BS Civil Engineering',
    year_section: '1-A',
    sex: 'Male',
    type: 'Student'
  },
  // ... more students
]

await window.patientSeeder.seed(engineeringStudents)
```

## Support

For issues or questions:
1. Check browser console for error messages
2. Verify Supabase connection and RLS policies
3. Ensure authentication is working
4. Check network tab for failed requests

## Version History

- **v1.0.0** (Current): Initial release with core seeding functionality
  - Sample dataset (10 patients)
  - Random generator
  - Clear/fetch utilities
  - Browser console integration
