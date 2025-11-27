import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/colors.dart';

/// Display Settings Screen - Full implementation
class DisplaySettingsScreen extends StatefulWidget {
  const DisplaySettingsScreen({Key? key}) : super(key: key);

  @override
  State<DisplaySettingsScreen> createState() => _DisplaySettingsScreenState();
}

class _DisplaySettingsScreenState extends State<DisplaySettingsScreen> {
  String _selectedTheme = 'Light';
  String _selectedFontSize = 'Medium';
  String _selectedLanguage = 'English';
  double _brightness = 0.5;
  final _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _loadDisplaySettings();
  }

  Future<void> _loadDisplaySettings() async {
    final prefs = await _prefs;
    setState(() {
      _selectedTheme = prefs.getString('theme') ?? 'Light';
      _selectedFontSize = prefs.getString('font_size') ?? 'Medium';
      _selectedLanguage = prefs.getString('language') ?? 'English';
      _brightness = prefs.getDouble('brightness') ?? 0.5;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await _prefs;
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Selection
          _buildSectionTitle('Theme'),
          const SizedBox(height: 8),
          _buildOptionCard(
            title: 'Light',
            isSelected: _selectedTheme == 'Light',
            onTap: () {
              setState(() => _selectedTheme = 'Light');
              _saveSetting('theme', 'Light');
            },
          ),
          const SizedBox(height: 8),
          _buildOptionCard(
            title: 'Dark',
            isSelected: _selectedTheme == 'Dark',
            onTap: () {
              setState(() => _selectedTheme = 'Dark');
              _saveSetting('theme', 'Dark');
            },
          ),
          const SizedBox(height: 8),
          _buildOptionCard(
            title: 'System Default',
            isSelected: _selectedTheme == 'System',
            onTap: () {
              setState(() => _selectedTheme = 'System');
              _saveSetting('theme', 'System');
            },
          ),
          const SizedBox(height: 24),
          
          // Font Size
          _buildSectionTitle('Font Size'),
          const SizedBox(height: 8),
          _buildOptionCard(
            title: 'Small',
            isSelected: _selectedFontSize == 'Small',
            onTap: () {
              setState(() => _selectedFontSize = 'Small');
              _saveSetting('font_size', 'Small');
            },
          ),
          const SizedBox(height: 8),
          _buildOptionCard(
            title: 'Medium',
            isSelected: _selectedFontSize == 'Medium',
            onTap: () {
              setState(() => _selectedFontSize = 'Medium');
              _saveSetting('font_size', 'Medium');
            },
          ),
          const SizedBox(height: 8),
          _buildOptionCard(
            title: 'Large',
            isSelected: _selectedFontSize == 'Large',
            onTap: () {
              setState(() => _selectedFontSize = 'Large');
              _saveSetting('font_size', 'Large');
            },
          ),
          const SizedBox(height: 24),
          
          // Language
          _buildSectionTitle('Language'),
          const SizedBox(height: 8),
          _buildOptionCard(
            title: 'English',
            isSelected: _selectedLanguage == 'English',
            onTap: () {
              setState(() => _selectedLanguage = 'English');
              _saveSetting('language', 'English');
            },
          ),
          const SizedBox(height: 8),
          _buildOptionCard(
            title: 'සිංහල',
            isSelected: _selectedLanguage == 'Sinhala',
            onTap: () {
              setState(() => _selectedLanguage = 'Sinhala');
              _saveSetting('language', 'Sinhala');
            },
          ),
          const SizedBox(height: 8),
          _buildOptionCard(
            title: 'தமிழ்',
            isSelected: _selectedLanguage == 'Tamil',
            onTap: () {
              setState(() => _selectedLanguage = 'Tamil');
              _saveSetting('language', 'Tamil');
            },
          ),
          const SizedBox(height: 24),
          
          // Brightness
          _buildSectionTitle('Screen Brightness'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Brightness',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${(_brightness * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _brightness,
                    onChanged: (value) {
                      setState(() => _brightness = value);
                      _saveSetting('brightness', value);
                    },
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primary : Colors.black87,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: AppColors.primary)
            : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

