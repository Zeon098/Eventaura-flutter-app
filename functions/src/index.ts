import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

interface PushNotificationData {
  token: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

export const sendPushToToken = functions.https.onCall(
  async (request: functions.https.CallableRequest<PushNotificationData>) => {
    // Verify authenticated user
    if (!request.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated to send notifications."
      );
    }

    const {token, title, body, data: payload} = request.data;

    if (!token || !title || !body) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing required fields: token, title, body"
      );
    }

    try {
      const message = {
        notification: {
          title: title,
          body: body,
        },
        data: payload || {},
        token: token,
      };

      const response = await admin.messaging().send(message);
      return {success: true, messageId: response};
    } catch (error: unknown) {
      const errorMessage =
        error instanceof Error ? error.message : "Unknown error";
      console.error("Error sending push notification:", error);
      throw new functions.https.HttpsError(
        "internal",
        `Failed to send notification: ${errorMessage}`
      );
    }
  }
);
