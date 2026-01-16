/// Stub implementation for non-web platforms (Mobile/Desktop)
class AudioPlayerHelper {
  static dynamic createAudioElement() {
    return null;
  }
  
  static void setSource(dynamic element, String url) {
    // No-op on mobile
  }
  
  static void play(dynamic element) {
    // No-op on mobile
  }
  
  static void pause(dynamic element) {
    // No-op on mobile
  }
  
  static void dispose(dynamic element) {
    // No-op on mobile
  }
  
  static void listenToLoadedMetadata(dynamic element, Function callback) {
    // No-op on mobile
  }
  
  static void listenToPlay(dynamic element, Function callback) {
    // No-op on mobile
  }
  
  static void listenToPause(dynamic element, Function callback) {
    // No-op on mobile
  }
  
  static void listenToEnded(dynamic element, Function callback) {
    // No-op on mobile
  }
  
  static void listenToTimeUpdate(dynamic element, Function callback) {
    // No-op on mobile
  }
  
  static Duration getDuration(dynamic element) {
    return Duration.zero;
  }
  
  static Duration getCurrentTime(dynamic element) {
    return Duration.zero;
  }
  
  static void seek(dynamic element, Duration position) {
    // No-op on mobile
  }
}
