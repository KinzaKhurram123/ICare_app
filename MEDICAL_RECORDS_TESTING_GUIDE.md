# Medical Records System - Testing Guide

## Overview
The Medical Records system allows doctors to create and view patient medical records, including diagnosis, symptoms, prescriptions, lab tests, vital signs, and follow-up dates.

## System Flow

```
1. Patient books appointment with Doctor
2. Doctor accepts appointment
3. Doctor views appointment details
4. Doctor creates medical record for patient
5. Doctor can view all patient records
6. Patient can view their own medical records (future feature)
```

## Setup: Add Test Data

### Step 1: Run the test data script

```bash
cd Icare_backend-main
node scripts/add_test_medical_records.js
```

This will:
- Find an existing doctor and patient in your database
- Create 3 sample medical records with realistic data:
  1. Common Cold with prescriptions
  2. Hypertension with medication
  3. Vitamin D Deficiency with supplements

### Step 2: Note the credentials shown

The script will display:
```
👨‍⚕️ Doctor: [Doctor Name] ([doctor email])
👤 Patient: [Patient Name] ([patient email])
```

## Testing Flow

### Test 1: View Existing Medical Records (Doctor Side)

1. **Login as Doctor**
   - Use the doctor email from the script output
   - Password: `123456` (or your test password)

2. **Navigate to Patient Records**
   - Click on sidebar menu (☰)
   - Select "Patient Records"
   - OR click "Patient Records" from Doctor Dashboard

3. **Search for Patient**
   - Use the search bar at the top
   - Type the patient name from script output
   - Patient card should appear

4. **View Patient's Records**
   - Click on the patient card
   - You should see 3 medical records listed
   - Each record shows:
     - Date created
     - Diagnosis
     - Quick preview of symptoms

5. **View Record Details**
   - Click on any medical record
   - Full details screen shows:
     - Patient information
     - Vital signs (BP, temperature, heart rate, weight, height)
     - Diagnosis
     - Symptoms list
     - Prescriptions with medicines (name, dosage, frequency, duration, instructions)
     - Lab tests recommended
     - Additional notes
     - Follow-up date

### Test 2: Create New Medical Record (Doctor Side)

1. **Login as Doctor** (if not already logged in)

2. **Go to Doctor Appointments**
   - From sidebar or dashboard
   - Find a "confirmed" or "completed" appointment

3. **View Appointment Details**
   - Click on any appointment card
   - This opens the "View Profile" screen

4. **Create Medical Record**
   - Click the blue "Create Medical Record" button
   - Fill in the form:

#### Form Fields:

**Diagnosis** (Required)
- Example: "Seasonal Allergies"

**Symptoms** (comma-separated)
- Example: "Sneezing, Runny nose, Itchy eyes"

**Vital Signs**
- Blood Pressure: "118/75"
- Temperature: "98.6"
- Heart Rate: "72"
- Weight: "70"
- Height: "175"

**Prescriptions** (Click + to add)
- Medicine Name: "Loratadine"
- Dosage: "10mg"
- Frequency: "Once daily"
- Duration: "14 days"
- Instructions: "Take in the morning"

**Lab Tests** (Click + to add)
- Example: "Allergy Panel Test"

**Additional Notes**
- Example: "Avoid outdoor activities during high pollen count days"

**Follow-up Date**
- Click calendar icon
- Select a date 2-4 weeks in the future

5. **Submit**
   - Click "Create Medical Record"
   - Success message should appear
   - You'll be taken back to the previous screen

6. **Verify Creation**
   - Go to "Patient Records"
   - Search for the patient
   - Click on patient
   - Your new record should appear at the top

### Test 3: View from Different Screens

**From Doctor Dashboard:**
1. Login as doctor
2. Click "Patient Records" quick action button
3. Search and view records

**From Appointments:**
1. Go to "My Appointments" (doctor side)
2. Click any appointment card
3. View patient profile
4. Click "Create Medical Record"

## API Endpoints Used

### Create Medical Record
```
POST /api/medical-records/create
Headers: Authorization: Bearer <token>
Body: {
  patientId, appointmentId, diagnosis, symptoms,
  prescription, labTests, vitalSigns, notes, followUpDate
}
```

### Get Patient's Records
```
GET /api/medical-records/patient/:patientId
Headers: Authorization: Bearer <token>
```

### Get Doctor's All Records
```
GET /api/medical-records/doctor
Headers: Authorization: Bearer <token>
```

### Get Single Record
```
GET /api/medical-records/:recordId
Headers: Authorization: Bearer <token>
```

## Data Structure

### Medical Record Object
```javascript
{
  _id: "record_id",
  patient: { name, email, phoneNumber },
  doctor: { name, email },
  appointment: { date, timeSlot },
  diagnosis: "string",
  symptoms: ["symptom1", "symptom2"],
  prescription: [
    {
      medicineName: "string",
      dosage: "string",
      frequency: "string",
      duration: "string",
      instructions: "string"
    }
  ],
  labTests: ["test1", "test2"],
  vitalSigns: {
    bloodPressure: "120/80",
    temperature: "98.6",
    heartRate: 75,
    weight: 70.5,
    height: 175
  },
  notes: "string",
  followUpDate: "2025-04-15",
  createdAt: "timestamp",
  updatedAt: "timestamp"
}
```

## Troubleshooting

### No records showing
- Make sure you ran the test script
- Check that you're logged in as the correct doctor
- Verify the patient exists in the database

### Can't create record
- Ensure appointment exists and has a patient
- Check that you're logged in as a doctor
- Verify backend server is running

### Search not working
- Patient name must match exactly (case-insensitive)
- Try searching with partial name
- Check console for errors

## Future Enhancements

1. **Patient Side View**
   - Patients can view their own medical records
   - Add to patient dashboard/sidebar

2. **Edit Medical Records**
   - Allow doctors to update existing records
   - Add edit button on detail screen

3. **Print/Export**
   - Generate PDF of medical record
   - Email record to patient

4. **Attachments**
   - Upload lab reports
   - Add prescription images

5. **Medical History Timeline**
   - Visual timeline of all records
   - Filter by date range or diagnosis type

## Test Accounts

**Doctor:**
- Email: doctor@gmail.com
- Password: 123456

**Doctor 2:**
- Email: doctor2@gmail.com
- Password: 123456

**Patient:**
- Email: kinza@gmail.com
- Password: 123456

## Quick Test Checklist

- [ ] Run test data script
- [ ] Login as doctor
- [ ] Navigate to Patient Records
- [ ] Search for patient
- [ ] View patient's records list
- [ ] Click on a record to view details
- [ ] Go to appointments
- [ ] Click on an appointment
- [ ] Click "Create Medical Record"
- [ ] Fill all form fields
- [ ] Add at least one prescription
- [ ] Add at least one lab test
- [ ] Select follow-up date
- [ ] Submit form
- [ ] Verify record appears in patient records list
- [ ] View the newly created record details

## Support

If you encounter any issues:
1. Check browser console for errors
2. Check backend terminal for API errors
3. Verify MongoDB connection
4. Ensure all required fields are filled
5. Check that appointment has a valid patient
