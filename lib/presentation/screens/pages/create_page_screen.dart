import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../data/repositories/leo_id_repository.dart';
import '../../../data/models/leo_id.dart';
import '../../../providers/auth_provider.dart';

/// Create Page Screen - For Super Admin to create pages with webmaster assignment
class CreatePageScreen extends StatefulWidget {
  const CreatePageScreen({Key? key}) : super(key: key);

  @override
  State<CreatePageScreen> createState() => _CreatePageScreenState();
}

class _CreatePageScreenState extends State<CreatePageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pageRepository = PageRepository();
  final _leoIdRepository = LeoIdRepository();
  
  String _selectedType = 'club'; // 'club' or 'district'
  List<String> _selectedWebmasterIds = [];
  List<LeoId> _availableLeoIds = [];
  bool _isLoading = false;
  bool _isLoadingLeoIds = true;

  @override
  void initState() {
    super.initState();
    _loadLeoIds();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadLeoIds() async {
    setState(() => _isLoadingLeoIds = true);
    try {
      final leoIds = await _leoIdRepository.getAllLeoIds();
      setState(() {
        _availableLeoIds = leoIds;
        _isLoadingLeoIds = false;
      });
    } catch (e) {
      setState(() => _isLoadingLeoIds = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load Leo IDs: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createPage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedWebmasterIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one webmaster'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _pageRepository.createPage(
        name: _nameController.text.trim(),
        type: _selectedType,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        webmasterIds: _selectedWebmasterIds,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Page created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create page: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showWebmasterSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Webmasters'),
        content: SizedBox(
          width: double.maxFinite,
          child: _isLoadingLeoIds
              ? const Center(child: CircularProgressIndicator())
              : _availableLeoIds.isEmpty
                  ? const Text('No Leo IDs available')
                  : StatefulBuilder(
                      builder: (context, setDialogState) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: _availableLeoIds.length,
                          itemBuilder: (context, index) {
                            final leoId = _availableLeoIds[index];
                            final isSelected = _selectedWebmasterIds.contains(leoId.leoId);
                            return CheckboxListTile(
                              title: Text(leoId.leoId),
                              subtitle: Text(leoId.email),
                              value: isSelected,
                              onChanged: (value) {
                                setDialogState(() {
                                  if (value == true) {
                                    _selectedWebmasterIds.add(leoId.leoId);
                                  } else {
                                    _selectedWebmasterIds.remove(leoId.leoId);
                                  }
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Check if user is super admin
    if (!authProvider.isSuperAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create Page'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Access denied. Super admin only.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Page'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Page Name *',
                  hintText: 'Enter page name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a page name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Page Type
              const Text(
                'Page Type *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Club'),
                      value: 'club',
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() => _selectedType = value!);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('District'),
                      value: 'district',
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() => _selectedType = value!);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter page description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Webmasters
              const Text(
                'Webmasters *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _showWebmasterSelector,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people_outline),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _selectedWebmasterIds.isEmpty
                            ? const Text('Select webmasters')
                            : Text('${_selectedWebmasterIds.length} webmaster(s) selected'),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
              if (_selectedWebmasterIds.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedWebmasterIds.map((leoId) {
                    return Chip(
                      label: Text(leoId),
                      onDeleted: () {
                        setState(() {
                          _selectedWebmasterIds.remove(leoId);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 24),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Create Page',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

