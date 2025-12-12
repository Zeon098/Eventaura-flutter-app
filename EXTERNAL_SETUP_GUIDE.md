# External Services Setup Guide

This guide covers the required configuration for Firebase, Algolia, and Cloudinary.

---

## 1. Firebase Setup

### A. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add project** or select existing project
3. Enter project name: `Eventaura` (or your choice)
4. Enable Google Analytics (optional)
5. Click **Create project**

### B. Register Your App

#### For Android:
1. In Firebase Console, click **Add app** → **Android**
2. Enter Android package name: `com.eventaura.app.eventaura_flutter` (from `android/app/build.gradle.kts`)
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

#### For iOS:
1. Click **Add app** → **iOS**
2. Enter iOS bundle ID: `com.eventaura.app.eventauraFlutter` (from `ios/Runner/Info.plist`)
3. Download `GoogleService-Info.plist`
4. Open Xcode → Right-click `Runner` folder → **Add Files to "Runner"**
5. Select `GoogleService-Info.plist` (ensure "Copy items if needed" is checked)

### C. Enable Firebase Authentication
1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable **Email/Password** provider
3. Click **Save**

### D. Setup Firestore Database
1. Go to **Firestore Database** → **Create database**
2. Select **Start in production mode**
3. Choose a location closest to your users
4. Click **Enable**

#### Set Security Rules:
Go to **Rules** tab and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Provider requests collection
    match /provider_requests/{requestId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == requestId;
      allow update, delete: if request.auth != null;
    }
    
    // Services collection
    match /services/{serviceId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        request.auth.uid == resource.data.providerId;
    }
    
    // Bookings collection
    match /bookings/{bookingId} {
      allow read: if request.auth != null && (
        request.auth.uid == resource.data.consumerId ||
        request.auth.uid == resource.data.providerId
      );
      allow create: if request.auth != null;
      allow update: if request.auth != null && (
        request.auth.uid == resource.data.consumerId ||
        request.auth.uid == resource.data.providerId
      );
    }
    
    // Chats collection
    match /chats/{chatId} {
      allow read: if request.auth != null && 
        request.auth.uid in resource.data.participantIds;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        request.auth.uid in resource.data.participantIds;
      
      match /chat_messages/{messageId} {
        allow read: if request.auth != null;
        allow create: if request.auth != null;
      }
    }
  }
}
```

Click **Publish**

### E. Create Firestore Indexes (for queries with orderBy)

Go to **Firestore Database** → **Indexes** → **Composite** tab

Create these indexes:

1. **Bookings by consumerId + createdAt**
   - Collection ID: `bookings`
   - Fields to index:
     - `consumerId` (Ascending)
     - `createdAt` (Descending)
   - Query scope: Collection

2. **Bookings by providerId + createdAt**
   - Collection ID: `bookings`
   - Fields to index:
     - `providerId` (Ascending)
     - `createdAt` (Descending)
   - Query scope: Collection

3. **Chats by participantIds + updatedAt**
   - Collection ID: `chats`
   - Fields to index:
     - `participantIds` (Array)
     - `updatedAt` (Descending)
   - Query scope: Collection

4. **Messages by sentAt**
   - Collection ID: `chat_messages`
   - Fields to index:
     - `sentAt` (Descending)
   - Query scope: Collection group

> **Note:** You may also create these indexes automatically by running the app and clicking the error links that appear in the console.

### F. Setup Firebase Cloud Messaging (FCM)

#### For Android:
- FCM is automatically configured via `google-services.json`
- No additional setup needed for Android

#### For iOS:
1. In Firebase Console → **Project settings** → **Cloud Messaging** tab
2. Under **Apple app configuration**, click **Upload** next to APNs Authentication Key (or APNs Certificates)
3. Upload your APNs authentication key (.p8 file) from Apple Developer Console
   - Or upload APNs certificate if using certificate-based authentication
4. Enter your Key ID and Team ID (found in Apple Developer Console)

> **Note:** The legacy Cloud Messaging API is deprecated. The app uses Firebase Cloud Messaging API (V1) which is automatically configured when you run `flutterfire configure`.

---

## 2. Algolia Setup

### A. Create Algolia Account
1. Go to [Algolia](https://www.algolia.com/)
2. Click **Sign up** or **Start free**
3. Create an account (free tier available)

### B. Create Application
1. After logging in, go to **Applications**
2. Click **Create Application**
3. Choose a plan (Free tier is fine for development)
4. Enter application name: `Eventaura`

### C. Create Index
1. In your Algolia dashboard, go to **Search** → **Indices**
2. Click **Create Index**
3. Enter index name: `services`
4. Click **Create**

### D. Configure Index Settings
1. Click on the `services` index
2. Go to **Configuration** → **Ranking and Sorting**
3. Set **Custom ranking** to:
   - `desc(rating)`
   - `desc(price)`
4. Go to **Configuration** → **Facets**
5. Add these attributes for faceting:
   - `category`
   - `price`
6. Go to **Configuration** → **Searchable attributes**
7. Set the order:
   - `title`
   - `description`
   - `category`
   - `location`

### E. Get API Keys
1. Go to **Settings** → **API Keys**
2. Copy these keys:
   - **Application ID** (e.g., `ABC123DEF4`)
   - **Search-Only API Key** (for frontend searches)

> **Important:** Never use the Admin API Key in your mobile app. Only use the Search-Only API Key.

### F. Enable Geo Search (Optional)
If you want location-based searches:
1. Go to index **Configuration** → **Geo Search**
2. Enable **Geo search**
3. Set **Geo attribute**: `_geoloc`

---

## 3. Cloudinary Setup

### A. Create Cloudinary Account
1. Go to [Cloudinary](https://cloudinary.com/)
2. Click **Sign up for free**
3. Complete registration

### B. Get Account Details
1. After logging in, go to **Dashboard**
2. Note your **Cloud name** (e.g., `dxyz123abc`)
3. Copy your **API Key** and **API Secret** (for backend, not needed in app)

### C. Create Upload Preset
1. Go to **Settings** → **Upload**
2. Scroll to **Upload presets**
3. Click **Add upload preset**
4. Configure:
   - **Upload preset name**: `eventaura_unsigned`
   - **Signing mode**: **Unsigned** (important for client-side uploads)
   - **Folder**: Leave empty or set to `eventaura/`
   - **Access mode**: Public read
   - **Allowed formats**: `jpg,png,jpeg,webp`
   - **Max file size**: 10 MB
   - **Image transformations**: Optional (e.g., auto quality, auto format)
5. Click **Save**

### D. Optional: Create Separate Presets
For better organization, create multiple presets:

1. **Service Covers**:
   - Preset name: `service_covers`
   - Folder: `services/covers`
   - Transformations: `c_fill,w_800,h_600,q_auto,f_auto`

2. **Service Gallery**:
   - Preset name: `service_gallery`
   - Folder: `services/gallery`
   - Transformations: `c_fill,w_1200,h_900,q_auto,f_auto`

3. **User Avatars**:
   - Preset name: `user_avatars`
   - Folder: `users/avatars`
   - Transformations: `c_thumb,w_400,h_400,g_face,q_auto,f_auto`

---

## 4. Configure Environment Variables

Create a `.env` file in the project root:

```bash
# Algolia Configuration
ALGOLIA_APP_ID=YOUR_ALGOLIA_APP_ID
ALGOLIA_SEARCH_API_KEY=YOUR_ALGOLIA_SEARCH_ONLY_KEY

# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=YOUR_CLOUDINARY_CLOUD_NAME
CLOUDINARY_UPLOAD_PRESET=eventaura_unsigned
```

**Replace** `YOUR_*` placeholders with your actual values from the services above.

> **Important:** Add `.env` to your `.gitignore` file to prevent committing sensitive keys:
```
# .gitignore
.env
```

---

## 5. Verify Setup

### Firebase Verification:
1. Run the app
2. Try signing up with email/password
3. Check Firebase Console → **Authentication** to see the new user
4. Check **Firestore Database** to verify user document creation

### Algolia Verification:
1. In the app, create a service (as a provider)
2. Go to Algolia Dashboard → **services** index
3. Check if the service appears in the index
4. Try searching for it using the explore/search UI

### Cloudinary Verification:
1. Create a service with a cover image
2. Go to Cloudinary Dashboard → **Media Library**
3. Check if the image appears in `services/covers/` folder
4. Verify the image URL works in a browser

---

## 6. Testing Checklist

- [ ] Firebase Auth: Sign up/login works
- [ ] Firestore: User data is saved
- [ ] Firestore: Services are created and listed
- [ ] Firestore: Bookings are created
- [ ] Firestore: Chat messages are sent/received
- [ ] Algolia: Services are indexed automatically
- [ ] Algolia: Search returns relevant results
- [ ] Algolia: Category and price filters work
- [ ] Cloudinary: Images upload successfully
- [ ] Cloudinary: Uploaded images display in app
- [ ] FCM: Push notifications received (optional)

---

## 7. Production Considerations

### Firebase:
- Upgrade Firestore rules for production security
- Enable App Check to prevent abuse
- Set up Cloud Functions for server-side logic
- Monitor usage in Firebase Console

### Algolia:
- Upgrade to a paid plan if needed
- Set up API rate limiting
- Monitor search analytics
- Configure synonyms and stop words

### Cloudinary:
- Set up transformations for optimal performance
- Enable auto format and quality
- Configure CDN caching
- Set up backup storage

---

## 8. Troubleshooting

### Firebase Issues:
- **Auth not working**: Check `google-services.json` / `GoogleService-Info.plist` placement
- **Firestore permission denied**: Verify security rules
- **Index error**: Create required composite indexes

### Algolia Issues:
- **Search not working**: Verify API keys in `.env`
- **No results**: Check if services are being indexed (see Algolia dashboard)
- **Geo search fails**: Ensure `_geoloc` field exists with `lat` and `lng`

### Cloudinary Issues:
- **Upload fails**: Verify upload preset is **unsigned**
- **Images not displaying**: Check cloud name in `.env`
- **CORS errors**: Enable CORS in Cloudinary settings

---

## Support Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Algolia Documentation](https://www.algolia.com/doc/)
- [Cloudinary Documentation](https://cloudinary.com/documentation)
- [Flutter Firebase Package](https://firebase.flutter.dev/)

---

**Last Updated:** December 12, 2025
