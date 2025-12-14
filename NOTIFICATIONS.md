# Push Notification System

Complete production push notification implementation using GetX service architecture.

## Features Implemented

### 1. **FCM Token Management** ✅
- Token automatically saved to Firestore on user login
- Located in: `ShellController.onInit()`
- Updates user document with `fcmToken` field

### 2. **Centralized NotificationService** ✅
- **File**: `lib/core/services/notification_service.dart`
- GetX service registered in `GlobalBinding`
- Handles all notification types in one place

### 3. **Notification Types**

#### Provider Approval ✅
- **Trigger**: Backend watches `users` collection for `providerStatus` changes
- **When**: Admin approves/rejects provider request
- **Recipients**: Provider applicant
- **Backend**: `backend/index.js` (automatic listener)

#### New Booking Request ✅
- **Trigger**: `BookingController.createBooking()`
- **When**: Consumer creates a booking
- **Recipients**: Service provider
- **Includes**: Service title, consumer name

#### Booking Status Change ✅
- **Trigger**: `BookingController.updateStatus()`
- **When**: Provider accepts/rejects booking
- **Recipients**: Consumer who made the booking
- **Includes**: Provider name, new status

#### New Chat Message ✅
- **Trigger**: `ChatController.sendMessage()` and `sendImage()`
- **When**: User sends text or image message
- **Recipients**: Other chat participants
- **Includes**: Sender name, message preview (or "[Image]")

## Architecture

```
┌─────────────────────────────────────┐
│     NotificationService (GetX)      │
│  Centralized notification logic     │
└──────────────┬──────────────────────┘
               │
       ┌───────┴────────┐
       │                │
┌──────▼─────┐  ┌──────▼──────┐
│  Booking   │  │    Chat     │
│ Controller │  │ Controller  │
└────────────┘  └─────────────┘
       │                │
       │                │
       ▼                ▼
┌─────────────────────────────────────┐
│  PushNotificationService            │
│  Writes to Firestore notifications  │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│     Backend Server (Node.js)        │
│  Watches notifications collection   │
│  Sends FCM via firebase-admin       │
└─────────────────────────────────────┘
```

## Backend Setup

### Start Backend Server
```bash
cd backend
npm install
npm start
```

### What Backend Does
1. Watches `notifications` collection for new docs with `read: false`
2. Sends FCM HTTP v1 notification
3. Marks notification as `read: true`
4. **NEW**: Watches `users` collection for `providerStatus` changes
5. **NEW**: Auto-queues provider approval/rejection notifications

## Notification Data Structure

### Firestore `notifications` Collection
```json
{
  "targetToken": "user_fcm_token",
  "title": "Notification Title",
  "body": "Notification body text",
  "data": {
    "type": "booking_new|booking_status|chat|provider_approval",
    "bookingId": "...",
    "roomId": "...",
    ...
  },
  "createdAt": "timestamp",
  "read": false
}
```

## Usage Examples

### Send Booking Notification
```dart
// Automatically called in BookingController.createBooking()
await notificationService.notifyNewBooking(
  providerId: providerId,
  bookingId: booking.id,
  serviceTitle: 'Photography Service',
  consumerName: 'John Doe',
);
```

### Send Booking Status Notification
```dart
// Automatically called in BookingController.updateStatus()
await notificationService.notifyBookingStatusChange(
  booking: booking,
  status: 'accepted',
  providerName: 'Jane Smith',
);
```

### Send Chat Notification
```dart
// Automatically called in ChatController._deliverMessage()
await notificationService.notifyNewMessage(
  recipientId: otherUserId,
  roomId: chatRoomId,
  senderId: currentUserId,
  messageType: 'text',
  messageContent: 'Hello!',
  senderName: 'Alice',
);
```

### Provider Approval (Backend Automatic)
When admin updates user document:
```javascript
// Update in Firestore console or admin panel
db.collection('users').doc(userId).update({
  providerStatus: 'approved' // or 'rejected'
});
// Backend auto-sends notification
```

## Testing

1. **Token Saved**: Check Firestore `users/{userId}` has `fcmToken` field
2. **New Booking**: Create booking → provider gets notification
3. **Accept/Reject**: Provider updates status → consumer gets notification
4. **Chat Message**: Send message → recipient gets notification (app killed state supported)
5. **Provider Approval**: Admin approves provider → user gets notification

## Files Modified/Created

### New Files
- `lib/core/services/notification_service.dart` - Central notification logic
- `backend/providerNotifications.js` - Helper functions (optional)

### Modified Files
- `lib/routes/global_binding.dart` - Register NotificationService
- `lib/modules/booking/controllers/booking_controller.dart` - Use NotificationService
- `lib/modules/chat/controllers/chat_controller.dart` - Use NotificationService
- `lib/modules/home/bindings/shell_binding.dart` - Inject NotificationService
- `lib/modules/chat/bindings/chat_binding.dart` - Inject NotificationService
- `backend/index.js` - Add provider status watcher

## Production Checklist

- [x] FCM token saved on login
- [x] Centralized notification service
- [x] Booking request notifications
- [x] Booking status notifications
- [x] Chat message notifications
- [x] Provider approval notifications
- [x] Backend server handles all types
- [x] Error handling for missing tokens
- [x] User names included in notifications
- [ ] Deploy backend to always-on host (Railway/Render/Fly.io)
- [ ] Set up monitoring/logging for backend
- [ ] Test all notification scenarios end-to-end

## Next Steps

1. **Deploy Backend**: Deploy Node.js server to free tier hosting
2. **Test App Killed State**: Verify notifications arrive when app is closed
3. **Add Analytics**: Track notification delivery rates
4. **Handle Token Refresh**: Listen for token updates in app
5. **Add Notification History**: Show in-app notification center

## Troubleshooting

**No notifications received**:
- Check FCM token exists in Firestore user doc
- Verify backend server is running
- Check backend logs for errors
- Confirm Firestore rules allow notification writes

**Provider approval not sent**:
- Ensure backend server is watching `users` collection
- Check `providerStatus` field changed to 'approved'/'rejected'
- Verify user has valid FCM token

**Chat notifications not working**:
- Confirm both users have FCM tokens
- Check chat room has correct `participantIds`
- Verify Firestore rules allow message reads/writes
