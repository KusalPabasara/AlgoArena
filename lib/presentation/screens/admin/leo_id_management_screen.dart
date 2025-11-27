import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../data/repositories/leo_id_repository.dart';
import '../../../data/models/leo_id.dart';
import '../../../providers/auth_provider.dart';

/// Leo ID Management Screen - For Super Admin
class LeoIdManagementScreen extends StatefulWidget {
  const LeoIdManagementScreen({Key? key}) : super(key: key);

  @override
  State<LeoIdManagementScreen> createState() => _LeoIdManagementScreenState();
}

class _LeoIdManagementScreenState extends State<LeoIdManagementScreen> {
  final _leoIdRepository = LeoIdRepository();
  final _leoIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  
  List<LeoId> _leoIds = [];
  bool _isLoading = true;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _loadLeoIds();
  }

  @override
  void dispose() {
    _leoIdController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _loadLeoIds() async {
    setState(() => _isLoading = true);
    try {
      final leoIds = await _leoIdRepository.getAllLeoIds();
      setState(() {
        _leoIds = leoIds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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

  Future<void> _addLeoId() async {
    if (_leoIdController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in Leo ID and Email'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isAdding = true);

    try {
      await _leoIdRepository.addLeoId(
        leoId: _leoIdController.text.trim(),
        email: _emailController.text.trim(),
        fullName: _fullNameController.text.trim().isEmpty 
            ? null 
            : _fullNameController.text.trim(),
      );

      _leoIdController.clear();
      _emailController.clear();
      _fullNameController.clear();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leo ID added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadLeoIds();
      }
    } catch (e) {
      setState(() => _isAdding = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add Leo ID: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteLeoId(String leoIdId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Leo ID'),
        content: const Text('Are you sure you want to delete this Leo ID?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _leoIdRepository.deleteLeoId(leoIdId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Leo ID deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadLeoIds();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showAddDialog() {
    _leoIdController.clear();
    _emailController.clear();
    _fullNameController.clear();
    setState(() => _isAdding = false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Leo ID'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _leoIdController,
                decoration: const InputDecoration(
                  labelText: 'Leo ID *',
                  hintText: 'Enter Leo ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  hintText: 'Enter email address',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name (Optional)',
                  hintText: 'Enter full name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isAdding ? null : () async {
              await _addLeoId();
            },
            child: _isAdding
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Add'),
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
          title: const Text('Leo ID Management'),
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
        title: const Text('Leo ID Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
            tooltip: 'Add Leo ID',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _leoIds.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No Leo IDs found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _showAddDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Leo ID'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLeoIds,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _leoIds.length,
                    itemBuilder: (context, index) {
                      final leoId = _leoIds[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Text(
                              leoId.leoId.substring(0, 2).toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            leoId.leoId,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(leoId.email),
                              if (leoId.fullName != null)
                                Text(leoId.fullName!),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteLeoId(leoId.id),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

