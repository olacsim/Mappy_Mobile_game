import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  // Singleton pattern to ensure only one instance of AudioManager
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  // Internal constructor
  AudioManager._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // Set volume for music player
  void setMusicVolume(double volume) {
    _musicPlayer.setVolume(volume);
  }

  // Set volume for sound effects player
  void setSfxVolume(double volume) {
    _sfxPlayer.setVolume(volume);
  }

  // Play music in a loop
  void playMusic(String soundFile) {
    _musicPlayer.setReleaseMode(ReleaseMode.loop); //makes the music loop
    _musicPlayer.play(AssetSource(soundFile));
  }

  // Play sound effect then stop
  void playSfx(String soundFile) {
    _sfxPlayer.play(AssetSource(soundFile));
  }

  // Stop music (with async handling)
  Future<void> stopMusic() async {
    await _musicPlayer.stop(); // Wait for the stop action to complete
  }

  // Stop sound effects
  void stopSfx() {
    _sfxPlayer.stop();
  }
}
