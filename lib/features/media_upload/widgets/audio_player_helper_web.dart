import 'dart:html' as html;

/// Web implementation using dart:html
class AudioPlayerHelper {
  static html.AudioElement createAudioElement() {
    return html.AudioElement();
  }
  
  static void setSource(html.AudioElement element, String url) {
    element.src = url;
  }
  
  static void play(html.AudioElement element) {
    element.play();
  }
  
  static void pause(html.AudioElement element) {
    element.pause();
  }
  
  static void dispose(html.AudioElement element) {
    element.pause();
    element.src = '';
  }
  
  static void listenToLoadedMetadata(html.AudioElement element, Function callback) {
    element.onLoadedMetadata.listen((_) => callback());
  }
  
  static void listenToPlay(html.AudioElement element, Function callback) {
    element.onPlay.listen((_) => callback());
  }
  
  static void listenToPause(html.AudioElement element, Function callback) {
    element.onPause.listen((_) => callback());
  }
  
  static void listenToEnded(html.AudioElement element, Function callback) {
    element.onEnded.listen((_) => callback());
  }
  
  static void listenToTimeUpdate(html.AudioElement element, Function callback) {
    element.onTimeUpdate.listen((_) => callback());
  }
  
  static Duration getDuration(html.AudioElement element) {
    if (element.duration.isFinite) {
      return Duration(seconds: element.duration.toInt());
    }
    return Duration.zero;
  }
  
  static Duration getCurrentTime(html.AudioElement element) {
    return Duration(seconds: element.currentTime.toInt());
  }
  
  static void seek(html.AudioElement element, Duration position) {
    element.currentTime = position.inSeconds.toDouble();
  }
}
