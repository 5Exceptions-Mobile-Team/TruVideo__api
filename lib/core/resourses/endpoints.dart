class Endpoints {
  // Login API
  static const loginRCBaseUrl = 'https://sdk-mobile-api-rc.truvideo.com';
  static const loginProdBaseUrl = 'https://sdk-mobile-api.truvideo.com';
  static const login = '/api/login';

  // Upload APIs
  static const uploadRCBaseUrl = 'https://upload-api-rc.truvideo.com';
  static const uploadProdBaseUrl = 'https://upload-api.truvideo.com';
  static const initializeUpload = '/upload/start';
  static const finalizeUpload = '/upload/{uploadId}/complete';
  static const getUploadStatus = '/upload/{uploadId}';
}
