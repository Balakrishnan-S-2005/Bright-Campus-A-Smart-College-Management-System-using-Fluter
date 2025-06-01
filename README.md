# 🎓 Bright Campus : College Management System using Flutter

A complete college management mobile app built using **Flutter** and **Firebase**, designed for Admin, Faculty, and Student roles. This project helps automate core academic processes such as attendance, marks, fee tracking, and communication.

## 📱 Roles & Features

### 👨‍💼 Admin
- Manage 8 classes
- Assign faculty & class tutors
- Add/view events in a calendar
- Post notifications
- View faculty leave requests
- Class reports (marks & attendance)
- Delete students (from Firestore & Firebase Auth)

### 👩‍🏫 Faculty
- View students in assigned class
- Mark attendance (5 periods/day)
- Add & update marks by subject (IA 1, IA 2, Model)
- Track fees with receipt upload (stored in Google Drive)
- Apply for leave (CL, OD, Permission; auto-convert to LOP if exceeded)
- View leave history and balances
- View class-wise attendance and marks reports

### 🎓 Student
- View personal attendance percentage
- View academic marks by category
- Upload fee payment receipt
- See fee status (Paid / Not Paid)
- View admin-posted notifications & calendar events

---

## 🔧 Tech Stack

- **Flutter** – UI development
- **Firebase Firestore** – Realtime database
- **Firebase Auth** – User authentication
- **Google Drive API** – Store fee receipts
- **Cloud Storage** (optional) – For storing files 
- **State Management** – [Provider / Riverpod] 
- **PDF generation** – For downloading reports

---

## 📁 Project Structure Highlights

```bash
/lib
  /screens
    /admin
    /faculty
    /student
  /models
  /widgets
  /services
