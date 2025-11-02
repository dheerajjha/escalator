# Firebase Cloud Messaging Setup Guide

This document explains the Firebase configuration for the Escalator project.

## ✅ Configuration Status

**Firebase is now fully configured and working!**

The backend server shows:
```
✅ Firebase Cloud Messaging initialized successfully
```

## 📱 App Details

### iOS App
- **Bundle ID:** `com.example.escalator`
- **Config File:** `app/ios/Runner/GoogleService-Info.plist` ✅
- **Status:** Configured

### Android App
- **Package Name:** `com.example.escalator`
- **Config File:** `app/android/app/google-services.json` ✅
- **Status:** Configured

### Backend
- **Service Account:** `backend/config/firebase-service-account.json` ✅
- **Firebase Admin SDK:** Installed and initialized
- **Status:** Working

## 🔒 Security Notes

All Firebase configuration files are excluded from Git via `.gitignore`:
- `backend/config/firebase-service-account.json`
- `app/ios/Runner/GoogleService-Info.plist`
- `app/android/app/google-services.json`

**IMPORTANT:** Never commit these files to version control!

## 🧪 Testing Push Notifications

### Method 1: Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Cloud Messaging** → **Send your first message**
4. Enter title and message
5. Select your app
6. Click **Send**

### Method 2: Test via API
Once a device has registered its FCM token, you can test via the backend API:

```javascript
// The app automatically sends FCM token when user logs in
// Token is stored in users table
```

## 📊 How It Works

### 1. User Onboarding (Mobile App)
- User opens app → creates account
- App requests notification permission
- FCM token generated automatically
- Token sent to backend via `/api/users/:id/fcm-token`

### 2. Backend Scheduler
- Runs every hour checking for due reminders
- Finds work items needing escalation
- Sends push notification via FCM
- Marks reminder as sent

### 3. User Receives Notification
- Notification appears on device
- User taps → app opens to work item detail
- User can take action (escalate, resolve, add note)

## 🔄 Reminder Schedule

Work items automatically schedule reminders:

| Stage | Time | Notification |
|-------|------|-------------|
| Active → Day 2 Nudge | +2 days | "Time to nudge [POC] offline" |
| Day 2 → Day 4 | +2 days | "Second nudge needed" |
| Day 4 → Week 1 | +3 days | "Setup call with [POC]" |
| Week 1 → Manager | +1 day | "Escalate to manager" |

## 🛠️ Troubleshooting

### Backend shows "FCM initialization failed"
- Check that `backend/config/firebase-service-account.json` exists
- Verify the JSON file is valid
- Ensure `firebase-admin` is installed: `npm install firebase-admin`

### Mobile app not receiving notifications
- Check that GoogleService-Info.plist (iOS) or google-services.json (Android) is in place
- Verify app requested notification permission
- Check FCM token is stored in database
- Test sending from Firebase Console

### Notifications not appearing
- iOS: Check notification settings in device Settings app
- Android: Check app notification permissions
- Verify app is in foreground or background (not force-closed)

## 📝 Environment Setup for New Developers

When setting up on a new machine:

1. **Get Firebase config files** from project admin (not in Git)
2. Place files in correct locations:
   - `app/ios/Runner/GoogleService-Info.plist`
   - `app/android/app/google-services.json`
   - `backend/config/firebase-service-account.json`
3. Install backend dependencies: `cd backend && npm install`
4. Verify FCM works: Check backend startup logs for "✅ Firebase Cloud Messaging initialized"

## 🎉 Success Indicators

When properly configured, you'll see:

**Backend startup:**
```
✅ Firebase Cloud Messaging initialized successfully
🚀 Escalator backend running on port 3000
```

**Sending notification:**
```
✅ Successfully sent notification: projects/escalator-af43a/messages/...
```

**Failed notification:**
```
❌ Error sending notification: [error details]
```

## 📚 Resources

- [Firebase Console](https://console.firebase.google.com)
- [Firebase Admin SDK Docs](https://firebase.google.com/docs/admin/setup)
- [FCM for iOS](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [FCM for Android](https://firebase.google.com/docs/cloud-messaging/android/client)
- [Flutter Firebase Messaging](https://firebase.flutter.dev/docs/messaging/overview/)
