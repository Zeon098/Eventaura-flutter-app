class AppConstants {
  AppConstants._();

  // Collections
  static const usersCollection = 'users';
  static const providerRequestsCollection = 'provider_requests';
  static const servicesCollection = 'services';
  static const bookingsCollection = 'bookings';
  static const chatsCollection = 'chats';
  static const messagesCollection = 'chat_messages';

  // Environment keys (names used in .env)
  static const algoliaAppIdKey = 'ALGOLIA_APP_ID';
  static const algoliaApiKeyKey = 'ALGOLIA_SEARCH_API_KEY';
  static const cloudinaryCloudNameKey = 'CLOUDINARY_CLOUD_NAME';
  static const cloudinaryUploadPresetKey = 'CLOUDINARY_UPLOAD_PRESET';
}
