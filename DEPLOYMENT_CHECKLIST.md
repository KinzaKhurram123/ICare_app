# iCare LMS - Deployment Checklist

## ✅ Backend Deployment

### 1. New Models Added
- ✅ `StudentVerification.js` - Document verification
- ✅ `Certificate.js` - Course certificates
- ✅ `LiveSession.js` - Live class sessions
- ✅ `Quiz.js` - Quiz questions and settings
- ✅ `QuizAttempt.js` - Student quiz submissions

### 2. New Routes Added
- ✅ `/api/verification/*` - Verification endpoints
- ✅ `/api/live-sessions/*` - Live session management
- ✅ `/api/quizzes/*` - Quiz system
- ✅ Existing: `/api/lms/assignments/*`
- ✅ Existing: `/api/lms/attendance/*`
- ✅ Existing: `/api/lms/announcements/*`

### 3. Backend Files Modified
- ✅ `icare-backend/index.js` - Added new route imports

### 4. Environment Variables Needed
```env
# Cloudinary (already configured)
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# MongoDB (already configured)
MONGODB_URI=your_mongodb_uri

# JWT (already configured)
JWT_SECRET=your_jwt_secret
```

### 5. Deploy Backend
```bash
cd icare-backend
npm install
vercel --prod
```

---

## ✅ Frontend Deployment

### 1. New Screens Added
- ✅ `lms_public_catalog.dart` - Public course browsing
- ✅ `lms_public_course_detail.dart` - Course details
- ✅ `lms_purchase_flow.dart` - Signup & purchase
- ✅ `lms_document_upload.dart` - Document verification
- ✅ `lms_limited_dashboard.dart` - Limited access dashboard
- ✅ `admin_verification_panel.dart` - Admin verification UI

### 2. New Services Added
- ✅ `lms_service.dart` - LMS API calls

### 3. Routes Added
- ✅ `/lms/catalog` - Public course catalog
- ✅ `/admin/verifications` - Admin panel

### 4. Modified Files
- ✅ `lib/navigators/app_router.dart` - Added LMS routes
- ✅ `lib/screens/public_home.dart` - Added "Explore Courses" button

### 5. Build & Deploy Flutter Web
```bash
flutter clean
flutter pub get
flutter build web --release
```

Then deploy `build/web` to your hosting (Vercel/Firebase/etc.)

---

## 🧪 Testing Checklist

### Public Access (No Login)
- [ ] Visit `/lms/catalog`
- [ ] Browse courses
- [ ] Search courses
- [ ] Filter by category
- [ ] Filter by difficulty
- [ ] Click course to view details
- [ ] See curriculum
- [ ] See instructor info
- [ ] Click "Buy Now"

### Purchase Flow
- [ ] Fill signup form (5 fields)
- [ ] Validate all fields
- [ ] Create account
- [ ] Redirect to payment
- [ ] Complete payment
- [ ] Enroll in course
- [ ] Upload documents
- [ ] See limited dashboard

### Limited Access Dashboard
- [ ] See verification pending banner
- [ ] See purchased course
- [ ] Click "Continue Learning"
- [ ] Access course content
- [ ] See progress tracking

### Admin Verification
- [ ] Login as admin
- [ ] Visit `/admin/verifications`
- [ ] See pending verifications
- [ ] View uploaded documents
- [ ] Approve verification
- [ ] Reject verification (with reason)
- [ ] Check student gets notification

### Full LMS Access (After Approval)
- [ ] Student sees "Approved" banner
- [ ] Can browse all courses
- [ ] Can purchase more courses
- [ ] Access assignments
- [ ] Access quizzes
- [ ] Join live sessions
- [ ] View grades
- [ ] Download certificates

### Instructor Features
- [ ] Create course
- [ ] Add modules/lessons
- [ ] Upload videos
- [ ] Create quizzes
- [ ] Create assignments
- [ ] Schedule live sessions
- [ ] Grade submissions
- [ ] View analytics

---

## 🚀 Quick Start Commands

### Backend
```bash
cd icare-backend
npm install
npm run dev  # Local testing
vercel --prod  # Production deploy
```

### Frontend
```bash
flutter clean
flutter pub get
flutter run -d chrome  # Local testing
flutter build web --release  # Production build
```

---

## 📊 API Endpoints Summary

### Public (No Auth)
- `GET /api/courses/public` - Browse courses

### Student (Auth Required)
- `POST /api/courses/enrollments` - Enroll in course
- `GET /api/courses/enrollments/my` - My enrollments
- `POST /api/verification/upload` - Upload documents
- `GET /api/verification/my-status` - Check verification status
- `GET /api/quizzes/course/:id` - Get course quizzes
- `POST /api/quizzes/:id/submit` - Submit quiz
- `GET /api/live-sessions/upcoming` - Upcoming sessions
- `POST /api/live-sessions/:id/join` - Join session

### Instructor (Auth Required)
- `POST /api/instructors/courses` - Create course
- `PUT /api/instructors/courses/:id` - Update course
- `POST /api/quizzes` - Create quiz
- `POST /api/live-sessions` - Schedule session
- `GET /api/lms/assignments/:id/submissions` - View submissions
- `PUT /api/lms/assignments/submissions/:id/grade` - Grade assignment

### Admin (Auth Required)
- `GET /api/verification/pending` - Pending verifications
- `POST /api/verification/:id/approve` - Approve verification
- `POST /api/verification/:id/reject` - Reject verification
- `GET /api/verification/all` - All verifications

---

## 🔧 Troubleshooting

### Backend Issues
1. **Routes not working**: Check `icare-backend/index.js` imports
2. **Database errors**: Verify MongoDB connection
3. **File upload fails**: Check Cloudinary credentials
4. **CORS errors**: Verify CORS middleware in `index.js`

### Frontend Issues
1. **Routes not found**: Check `lib/navigators/app_router.dart`
2. **API calls fail**: Verify backend URL in `api_service.dart`
3. **Build errors**: Run `flutter clean && flutter pub get`
4. **Import errors**: Check all new screen imports

---

## 📝 Next Steps After Deployment

1. **Test all flows** using checklist above
2. **Create demo data** for testing
3. **Train admin users** on verification process
4. **Monitor error logs** for issues
5. **Collect user feedback**
6. **Iterate and improve**

---

## 🎯 Success Metrics

Track these after deployment:
- Course views
- Signup conversions
- Purchase completions
- Verification approval time
- Course completion rates
- User satisfaction ratings

---

**Status**: Ready for Deployment ✅  
**Last Updated**: May 7, 2026  
**Version**: 1.0.0
