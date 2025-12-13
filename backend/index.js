const admin = require('firebase-admin');

// Initialize Firebase Admin with service account
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const messaging = admin.messaging();

console.log('🚀 Notification server started');
console.log('👀 Watching Firestore for new notifications...');

// Watch for new notifications in Firestore
db.collection('notifications')
  .where('read', '==', false)
  .onSnapshot(async (snapshot) => {
    for (const change of snapshot.docChanges()) {
      if (change.type === 'added') {
        const doc = change.doc;
        const data = doc.data();
        
        try {
          console.log(`📤 Sending notification to token: ${data.targetToken.substring(0, 20)}...`);
          
          // Send FCM notification using HTTP v1 API
          const message = {
            token: data.targetToken,
            notification: {
              title: data.title || 'Notification',
              body: data.body || '',
            },
            data: data.data || {},
            android: {
              priority: 'high',
              notification: {
                channelId: 'default_channel',
                priority: 'high',
              },
            },
            apns: {
              headers: {
                'apns-priority': '10',
              },
            },
          };

          await messaging.send(message);
          console.log('✅ Notification sent successfully');
          
          // Mark as read
          await doc.ref.update({ read: true });
          console.log('✓ Marked as read');
        } catch (error) {
          console.error('❌ Error sending notification:', error.message);
          
          // If token is invalid, mark as read to avoid retries
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            console.log('⚠️ Invalid token, marking as read');
            await doc.ref.update({ read: true });
          }
        }
      }
    }
  }, (error) => {
    console.error('Error watching Firestore:', error);
  });

// Keep the process running
process.on('SIGINT', () => {
  console.log('\n👋 Shutting down gracefully...');
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\n👋 Shutting down gracefully...');
  process.exit(0);
});
