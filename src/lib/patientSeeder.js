/**
 * Patient Data Seeder Utility
 * 
 * This file contains sample patient data and functions to populate the Supabase
 * patients table for testing and development purposes.
 * 
 * Usage:
 * 1. Import this file in your Vue component or run directly in browser console
 * 2. Call seedPatients() to insert test data
 * 3. Call clearAllPatients() to remove all test data (use with caution)
 */

import { supabase } from './Supabase.js'

/**
 * Sample patient dataset for testing
 * Contains diverse data across different types (Student, Faculty, Staff)
 */
export const samplePatients = [
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
  },
  {
    school_id: '2022005678',
    full_name: 'JUAN PABLO DELA CRUZ',
    email: 'juan.delacruz@uic.edu.ph',
    contact_number: '09181234567',
    college_department: 'College of Business Administration',
    program: 'BS Business Administration',
    year_section: '2-B',
    sex: 'Male',
    type: 'Student'
  },
  {
    school_id: 'F2019001',
    full_name: 'DR. ELENA RODRIGUEZ',
    email: 'elena.rodriguez@uic.edu.ph',
    contact_number: '09191234567',
    college_department: 'College of Medicine',
    program: 'Medicine Department',
    year_section: 'N/A',
    sex: 'Female',
    type: 'Faculty'
  },
  {
    school_id: '2023009876',
    full_name: 'CARLO ANTONIO REYES',
    email: 'carlo.reyes@uic.edu.ph',
    contact_number: '09201234567',
    college_department: 'College of Arts and Sciences',
    program: 'BS Psychology',
    year_section: '1-C',
    sex: 'Male',
    type: 'Student'
  },
  {
    school_id: 'S2020045',
    full_name: 'ANNA MARIE LOPEZ',
    email: 'anna.lopez@uic.edu.ph',
    contact_number: '09211234567',
    college_department: 'Administrative Office',
    program: 'Registrar Staff',
    year_section: 'N/A',
    sex: 'Female',
    type: 'Staff'
  },
  {
    school_id: '2022003456',
    full_name: 'MIGUEL JOSE GARCIA',
    email: 'miguel.garcia@uic.edu.ph',
    contact_number: '09221234567',
    college_department: 'College of Engineering',
    program: 'BS Civil Engineering',
    year_section: '2-A',
    sex: 'Male',
    type: 'Student'
  },
  {
    school_id: 'F2018002',
    full_name: 'PROF. SOFIA ISABELLE TAN',
    email: 'sofia.tan@uic.edu.ph',
    contact_number: '09231234567',
    college_department: 'College of Computer Studies',
    program: 'Computer Science Department',
    year_section: 'N/A',
    sex: 'Female',
    type: 'Faculty'
  },
  {
    school_id: '2021007890',
    full_name: 'RAFAEL MIGUEL CRUZ',
    email: 'rafael.cruz@uic.edu.ph',
    contact_number: '09241234567',
    college_department: 'College of Business Administration',
    program: 'BS Accountancy',
    year_section: '3-C',
    sex: 'Male',
    type: 'Student'
  },
  {
    school_id: 'S2021089',
    full_name: 'JENNIFER MAE SANTOS',
    email: 'jennifer.santos@uic.edu.ph',
    contact_number: '09251234567',
    college_department: 'Clinic Services',
    program: 'Medical Staff',
    year_section: 'N/A',
    sex: 'Female',
    type: 'Staff'
  },
  {
    school_id: '2023001122',
    full_name: 'ALEXANDRA NICOLE MENDOZA',
    email: 'alexandra.mendoza@uic.edu.ph',
    contact_number: '09261234567',
    college_department: 'College of Arts and Sciences',
    program: 'BS Biology',
    year_section: '1-A',
    sex: 'Female',
    type: 'Student'
  }
]

/**
 * Inserts sample patients into the Supabase database
 * 
 * @param {Array} patients - Array of patient objects to insert (defaults to samplePatients)
 * @returns {Promise<Object>} Result object with success status and data/error
 */
export async function seedPatients(patients = samplePatients) {
  try {
    // Get current authenticated user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    
    if (authError || !user) {
      console.error('Authentication error:', authError)
      return {
        success: false,
        error: 'User must be authenticated to seed patients'
      }
    }

    // Add metadata to each patient record
    const patientsWithMetadata = patients.map(patient => ({
      ...patient,
      created_by: user.id,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }))

    // Insert patients into database
    const { data, error } = await supabase
      .from('patients')
      .insert(patientsWithMetadata)
      .select()

    if (error) {
      console.error('Error inserting patients:', error)
      return {
        success: false,
        error: error.message
      }
    }

    console.log(`✅ Successfully inserted ${data.length} patients`)
    return {
      success: true,
      data,
      count: data.length
    }

  } catch (error) {
    console.error('Unexpected error during seeding:', error)
    return {
      success: false,
      error: error.message
    }
  }
}

/**
 * Removes all patients from the database
 * ⚠️ USE WITH CAUTION - This deletes all patient records
 * 
 * @returns {Promise<Object>} Result object with success status
 */
export async function clearAllPatients() {
  try {
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    
    if (authError || !user) {
      return {
        success: false,
        error: 'User must be authenticated to clear patients'
      }
    }

    // Delete all patients
    const { error } = await supabase
      .from('patients')
      .delete()
      .neq('id', 0) // Delete all rows (neq with impossible condition)

    if (error) {
      console.error('Error clearing patients:', error)
      return {
        success: false,
        error: error.message
      }
    }

    console.log('✅ All patients cleared successfully')
    return {
      success: true
    }

  } catch (error) {
    console.error('Unexpected error during clearing:', error)
    return {
      success: false,
      error: error.message
    }
  }
}

/**
 * Fetches all patients from the database
 * 
 * @returns {Promise<Array>} Array of patient records
 */
export async function getAllPatients() {
  try {
    const { data, error } = await supabase
      .from('patients')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Error fetching patients:', error)
      return []
    }

    return data || []

  } catch (error) {
    console.error('Unexpected error fetching patients:', error)
    return []
  }
}

/**
 * Helper function to generate random patient data
 * Useful for generating large test datasets
 * 
 * @param {number} count - Number of random patients to generate
 * @returns {Array} Array of generated patient objects
 */
export function generateRandomPatients(count = 10) {
  const firstNames = ['Maria', 'Juan', 'Sofia', 'Miguel', 'Ana', 'Carlos', 'Elena', 'Rafael', 'Isabelle', 'Diego']
  const lastNames = ['Santos', 'Dela Cruz', 'Garcia', 'Reyes', 'Lopez', 'Rodriguez', 'Mendoza', 'Cruz', 'Tan', 'Flores']
  const departments = ['College of Engineering', 'College of Business Administration', 'College of Arts and Sciences', 'College of Computer Studies', 'College of Medicine']
  const programs = ['BS Computer Science', 'BS Business Administration', 'BS Psychology', 'BS Civil Engineering', 'BS Accountancy', 'BS Biology']
  const types = ['Student', 'Student', 'Student', 'Faculty', 'Staff'] // Weighted toward students
  const sections = ['A', 'B', 'C']

  const randomPatients = []

  for (let i = 0; i < count; i++) {
    const firstName = firstNames[Math.floor(Math.random() * firstNames.length)]
    const lastName = lastNames[Math.floor(Math.random() * lastNames.length)]
    const type = types[Math.floor(Math.random() * types.length)]
    const year = type === 'Student' ? Math.floor(Math.random() * 4) + 1 : null
    const section = type === 'Student' ? sections[Math.floor(Math.random() * sections.length)] : null

    randomPatients.push({
      school_id: type === 'Student' ? `2023${String(i).padStart(6, '0')}` : `${type[0]}2023${String(i).padStart(3, '0')}`,
      full_name: `${firstName.toUpperCase()} ${lastName.toUpperCase()}`,
      email: `${firstName.toLowerCase()}.${lastName.toLowerCase()}@uic.edu.ph`,
      contact_number: `0917${String(Math.floor(Math.random() * 10000000)).padStart(7, '0')}`,
      college_department: departments[Math.floor(Math.random() * departments.length)],
      program: programs[Math.floor(Math.random() * programs.length)],
      year_section: type === 'Student' ? `${year}-${section}` : 'N/A',
      sex: Math.random() > 0.5 ? 'Male' : 'Female',
      type
    })
  }

  return randomPatients
}

// Export for direct browser console usage
if (typeof window !== 'undefined') {
  window.patientSeeder = {
    seed: seedPatients,
    clear: clearAllPatients,
    getAll: getAllPatients,
    generate: generateRandomPatients,
    samples: samplePatients
  }
  console.log('Patient seeder utilities loaded. Use window.patientSeeder in console.')
}
