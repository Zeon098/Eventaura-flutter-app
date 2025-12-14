const admin = require('firebase-admin');

/**
 * Backend helper: Call this when admin approves/rejects provider request
 * This should be integrated into your admin panel or Cloud Function
 */
async function notifyProviderStatusChange(userId, approved) {
  const db = admin.firestore();
  
  try {
    // Get user document
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      console.error('User not found:', userId);
      return;
    }

    const userData = userDoc.data();
    const fcmToken = userData.fcmToken;

    if (!fcmToken) {
      console.log('No FCM token for user:', userId);
      return;
    }

    // Create notification in Firestore for the app to pick up
    await db.collection('notifications').add({
      targetToken: fcmToken,
      title: approved ? 'Provider Request Approved! 🎉' : 'Provider Request Update',
      body: approved
        ? 'Congratulations! You can now create services.'
        : 'Your provider request has been reviewed.',
      data: {
        type: 'provider_approval',
        approved: approved.toString(),
        userId: userId,
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      read: false,
    });

    console.log(`✅ Notification queued for user ${userId} (approved: ${approved})`);
  } catch (error) {
    console.error('Error notifying provider status:', error);
  }
}

/**
 * Example Cloud Function to auto-notify on provider status change
 * Deploy this to Firebase Functions
 */
exports.onProviderStatusChange = admin.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const userId = context.params.userId;

    // Check if providerStatus changed
    if (before.providerStatus !== after.providerStatus) {
      const newStatus = after.providerStatus;
      
      if (newStatus === 'approved') {
        await notifyProviderStatusChange(userId, true);
      } else if (newStatus === 'rejected') {
        await notifyProviderStatusChange(userId, false);
      }
    }
  });

module.exports = { notifyProviderStatusChange };
