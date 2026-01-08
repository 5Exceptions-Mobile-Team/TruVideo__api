class Endpoints {
  // Login API uses the SDK Mobile API
  // static const loginBaseUrl = 'https://upload-api.truvideo.com/';
  // static const loginBaseUrl = 'https://sdk-mobile-api-rc.truvideo.com';
  static const loginBaseUrl = 'https://sdk-mobile-api.truvideo.com';
  static const login = '/api/login';

  // Upload API uses the dedicated Upload API
  // static const uploadBaseUrl = 'https://upload-api-rc.truvideo.com';
  static const uploadBaseUrl = 'https://upload-api.truvideo.com';
  static const initializeUpload = '/upload/start';
  static const finalizeUpload = '/upload/{uploadId}/complete';
  static const getUploadStatus = '/upload/{uploadId}';
}
