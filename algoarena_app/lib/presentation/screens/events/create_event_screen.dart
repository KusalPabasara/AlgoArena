import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/event_service.dart';

/// Create Event Screen - For verified webmasters to create new events
class CreateEventScreen extends StatefulWidget {
  final String? clubId;
  final String? districtId;
  final String? clubName;
  final String? districtName;

  const CreateEventScreen({
    super.key,
    this.clubId,
    this.districtId,
    this.clubName,
    this.districtName,
  });

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxParticipantsController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  String _selectedCategory = 'general';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {'value': 'general', 'label': 'General', 'icon': Icons.event},
    {'value': 'community', 'label': 'Community Service', 'icon': Icons.volunteer_activism},
    {'value': 'fundraiser', 'label': 'Fundraiser', 'icon': Icons.attach_money},
    {'value': 'meeting', 'label': 'Meeting', 'icon': Icons.groups},
    {'value': 'workshop', 'label': 'Workshop', 'icon': Icons.school},
    {'value': 'social', 'label': 'Social Event', 'icon': Icons.celebration},
    {'value': 'sports', 'label': 'Sports', 'icon': Icons.sports},
    {'value': 'environment', 'label': 'Environment', 'icon': Icons.eco},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFD700),
              onPrimary: Colors.black,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFD700),
              onPrimary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final eventDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final eventTime = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

      final result = await EventService.createEvent(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        eventDate: eventDate,
        eventTime: eventTime,
        location: _locationController.text.trim(),
        clubId: widget.clubId,
        districtId: widget.districtId,
        category: _selectedCategory,
        maxParticipants: _maxParticipantsController.text.isNotEmpty
            ? int.tryParse(_maxParticipantsController.text)
            : null,
      );

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Yellow bubble decoration (top-left)
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFD700),
              ),
            ),
          ),

          // Dark bubble decoration (top-right)
          Positioned(
            top: 40,
            right: -60,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF02091A),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF02091A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Create Event',
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF02091A),
                              ),
                            ),
                            if (widget.clubName != null || widget.districtName != null)
                              Text(
                                'for ${widget.clubName ?? widget.districtName}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Event Title
                          _buildLabel('Event Title *'),
                          _buildTextField(
                            controller: _titleController,
                            hint: 'Enter event title',
                            validator: (v) => v?.isEmpty ?? true ? 'Title is required' : null,
                          ),
                          const SizedBox(height: 20),

                          // Category
                          _buildLabel('Category'),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: _categories.map((cat) {
                                  return DropdownMenuItem(
                                    value: cat['value'] as String,
                                    child: Row(
                                      children: [
                                        Icon(cat['icon'] as IconData, size: 20, color: const Color(0xFF666666)),
                                        const SizedBox(width: 12),
                                        Text(cat['label'] as String),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (v) => setState(() => _selectedCategory = v!),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Date and Time
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Date *'),
                                    GestureDetector(
                                      onTap: _selectDate,
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5F5F5),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFE0E0E0)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.calendar_today, size: 20, color: Color(0xFF666666)),
                                            const SizedBox(width: 8),
                                            Text(
                                              DateFormat('MMM d, y').format(_selectedDate),
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Time'),
                                    GestureDetector(
                                      onTap: _selectTime,
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5F5F5),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFE0E0E0)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.access_time, size: 20, color: Color(0xFF666666)),
                                            const SizedBox(width: 8),
                                            Text(
                                              _selectedTime.format(context),
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Location
                          _buildLabel('Location'),
                          _buildTextField(
                            controller: _locationController,
                            hint: 'Event location or venue',
                            prefixIcon: Icons.location_on,
                          ),
                          const SizedBox(height: 20),

                          // Description
                          _buildLabel('Description'),
                          _buildTextField(
                            controller: _descriptionController,
                            hint: 'Describe your event...',
                            maxLines: 4,
                          ),
                          const SizedBox(height: 20),

                          // Max Participants
                          _buildLabel('Max Participants (optional)'),
                          _buildTextField(
                            controller: _maxParticipantsController,
                            hint: 'Leave empty for unlimited',
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.people,
                          ),
                          const SizedBox(height: 40),

                          // Create Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _createEvent,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Text(
                                      'Create Event',
                                      style: TextStyle(
                                        fontFamily: 'Raleway',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Raleway',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF999999)),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: const Color(0xFF666666), size: 20)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
