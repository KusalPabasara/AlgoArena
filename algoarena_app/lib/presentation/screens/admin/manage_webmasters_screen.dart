import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/webmaster_service.dart';

/// Manage Webmasters Screen - Super Admin only
/// Allows super admin to view users, assign Leo IDs, and manage webmasters
class ManageWebmastersScreen extends StatefulWidget {
  const ManageWebmastersScreen({super.key});

  @override
  State<ManageWebmastersScreen> createState() => _ManageWebmastersScreenState();
}

class _ManageWebmastersScreenState extends State<ManageWebmastersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _webmasters = [];
  List<Map<String, dynamic>> _leoIds = [];
  
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        WebmasterService.getAllUsers(),
        WebmasterService.getWebmasters(),
        WebmasterService.getAllLeoIds(),
      ]);

      if (mounted) {
        setState(() {
          _allUsers = results[0];
          _webmasters = results[1];
          _leoIds = results[2];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) return _allUsers;
    final query = _searchQuery.toLowerCase();
    return _allUsers.where((user) {
      final name = (user['fullName'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  Future<void> _createLeoId(Map<String, dynamic> user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Leo ID'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Leo ID for ${user['fullName']}?'),
            const SizedBox(height: 12),
            Text(
              'This will assign them to Leo Club of Colombo and generate a unique Leo ID.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFD700)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFB8860B), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'User must verify with this Leo ID to become a webmaster.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
            ),
            child: const Text('Create Leo ID'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await WebmasterService.createLeoId(
        userId: user['id'],
        clubId: 'leo-club-colombo',
        clubName: 'Leo Club of Colombo',
      );

      if (mounted) {
        final leoId = result['leoId'];
        
        // Show success dialog with Leo ID to copy
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Leo ID Created!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Leo ID for ${user['fullName']}:'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        leoId,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: leoId));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Leo ID copied to clipboard!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Share this Leo ID with ${user['fullName']}. They need to enter it in their profile verification to become a webmaster.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadData(); // Refresh data
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _revokeWebmaster(Map<String, dynamic> webmaster) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Webmaster'),
        content: Text(
          'Are you sure you want to revoke webmaster status from ${webmaster['fullName']}?\n\nThey will no longer be able to create posts or events.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await WebmasterService.revokeWebmaster(webmaster['id']);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Webmaster status revoked'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF02091A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage Webmasters',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF02091A),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFFD700),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFFFD700),
          tabs: const [
            Tab(text: 'All Users'),
            Tab(text: 'Webmasters'),
            Tab(text: 'Leo IDs'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUsersTab(),
                    _buildWebmastersTab(),
                    _buildLeoIdsTab(),
                  ],
                ),
    );
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ),
        // User count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '${_filteredUsers.length} users',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
        // User list
        Expanded(
          child: _filteredUsers.isEmpty
              ? const Center(child: Text('No users found'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    final isWebmaster = user['role'] == 'webmaster';
                    final hasLeoId = user['leoId'] != null;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isWebmaster
                              ? const Color(0xFFFFD700)
                              : Colors.grey[300],
                          child: Text(
                            (user['fullName'] ?? 'U')[0].toUpperCase(),
                            style: TextStyle(
                              color: isWebmaster ? Colors.black : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          user['fullName'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['email'] ?? ''),
                            if (hasLeoId)
                              Text(
                                'Leo ID: ${user['leoId']}',
                                style: const TextStyle(
                                  color: Color(0xFFB8860B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        trailing: isWebmaster
                            ? const Chip(
                                label: Text('Webmaster'),
                                backgroundColor: Color(0xFFFFD700),
                              )
                            : hasLeoId
                                ? const Chip(
                                    label: Text('Pending'),
                                    backgroundColor: Colors.orange,
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: const Color(0xFFFFD700),
                                    onPressed: () => _createLeoId(user),
                                    tooltip: 'Create Leo ID',
                                  ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildWebmastersTab() {
    return _webmasters.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No webmasters yet',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Assign Leo IDs from the "All Users" tab',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _webmasters.length,
            itemBuilder: (context, index) {
              final webmaster = _webmasters[index];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFFFFD700),
                            radius: 24,
                            child: Text(
                              (webmaster['fullName'] ?? 'W')[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  webmaster['fullName'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  webmaster['email'] ?? '',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'revoke',
                                child: Row(
                                  children: [
                                    Icon(Icons.remove_circle, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Revoke Access'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'revoke') {
                                _revokeWebmaster(webmaster);
                              }
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.badge,
                            webmaster['leoId'] ?? 'N/A',
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            Icons.location_city,
                            webmaster['leoClubName'] ?? 'Leo Club of Colombo',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildLeoIdsTab() {
    return _leoIds.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.badge, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No Leo IDs generated yet',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _leoIds.length,
            itemBuilder: (context, index) {
              final leoId = _leoIds[index];
              final isUsed = leoId['isUsed'] == true;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isUsed ? Colors.green : Colors.orange,
                    child: Icon(
                      isUsed ? Icons.check : Icons.hourglass_empty,
                      color: Colors.white,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        leoId['leoId'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: leoId['leoId'] ?? ''),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied!')),
                          );
                        },
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('For: ${leoId['userName'] ?? leoId['userEmail'] ?? 'Unknown'}'),
                      Text(
                        isUsed ? '✓ Verified' : '○ Pending verification',
                        style: TextStyle(
                          color: isUsed ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
