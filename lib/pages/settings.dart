import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import '../audiomanager.dart'; // Import AudioManager

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(
      title: 'Settings',
      children: <Widget>[
        // Music Volume Slider
        SliderSettingsTile(
          title: 'Music Volume',
          settingKey: 'music_volume',
          defaultValue: 50,
          min: 0,
          max: 100,
          step: 1,
          onChange: (value) {
            // Update music volume in the AudioManager
            AudioManager().setMusicVolume(
                value / 100.0); // Convert volume to range 0.0 to 1.0
            Settings.setValue('music_volume', value); // Save to settings
          },
        ),
        // Sound Effects Volume Slider
        SliderSettingsTile(
          title: 'Sound Effects Volume',
          settingKey: 'sound_effects_volume',
          defaultValue: 50,
          min: 0,
          max: 100,
          step: 1,
          onChange: (value) {
            // Update sound effects volume in the AudioManager
            AudioManager().setSfxVolume(
                value / 100.0); // Convert volume to range 0.0 to 1.0
            Settings.setValue(
                'sound_effects_volume', value); // Save to settings
          },
        ),
        // Dark Mode Toggle
        SwitchSettingsTile(
          settingKey: 'dark_mode',
          title: 'Dark Mode',
          defaultValue: false,
          onChange: (value) {
            if (value) {
              AdaptiveTheme.of(context).setDark();
            } else {
              AdaptiveTheme.of(context).setLight();
            }
          },
        ),
      ],
    );
  }
}
