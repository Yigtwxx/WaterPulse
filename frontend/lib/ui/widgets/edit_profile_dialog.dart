
import 'package:flutter/material.dart';
import 'package:waterpulse/services/api_client.dart';

class EditProfileDialog extends StatefulWidget {
  final int userId;
  final String currentName;
  final String? currentTitle;

  const EditProfileDialog({
    super.key,
    required this.userId,
    required this.currentName,
    this.currentTitle,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  String? _selectedTitle;
  bool _isLoadingTitles = true;
  String? _titlesError;
  List<String> _unlockedTitles = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _selectedTitle = widget.currentTitle;
    _loadTitles();
  }

  Future<void> _loadTitles() async {
    try {
      final apiClient = ApiClient();
      final achievements = await apiClient.getAchievements(userId: widget.userId);
      if (!mounted) return;
      
      final titles = achievements
          .where((a) => a['unlocked_at'] != null)
          .map((a) => a['title'] as String)
          .toList();
      
      setState(() {
        _unlockedTitles = titles;
        _isLoadingTitles = false;
        
        // Ensure selected title is still valid or null
        if (_selectedTitle != null && !_unlockedTitles.contains(_selectedTitle)) {
           // If current title is not in unlocked list (weird but possible), 
           // keep it if you want, or Reset?
           // For DropdownButton safety, we should add it to items or reset it.
           // Let's reset it if it's invalid, or add it to list?
           // Standard behavior: if you have it, you keep it. But if it's strictly from unlocked...
           // Let's assume unlocked source of truth.
           // However to avoid crash, if not found, we set to null or keep logic simple.
           if (!_unlockedTitles.contains(_selectedTitle)) {
             _selectedTitle = null;
           }
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _titlesError = e.toString();
          _isLoadingTitles = false;
        });
      }
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final apiClient = ApiClient();
      // Handle empty name? Reset to something default or error?
      // existing User schemas say name is optional but good to have one.
      final updates = <String, dynamic>{
        'name': _nameController.text.trim(),
        'selected_title': _selectedTitle,
      };
      
      await apiClient.updateUser(widget.userId, updates);
      
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Edit Profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            
            // Title Selector
            const Text('Title', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            if (_isLoadingTitles)
               const Center(child: Padding(
                 padding: EdgeInsets.all(8.0),
                 child: CircularProgressIndicator(),
               ))
            else if (_titlesError != null)
               Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                   color: Colors.red.withOpacity(0.1),
                   borderRadius: BorderRadius.circular(8),
                 ),
                 child: Text('Could not load titles: $_titlesError', style: const TextStyle(color: Colors.red, fontSize: 12)),
               )
            else
              DropdownButtonFormField<String?>(
                value: _unlockedTitles.contains(_selectedTitle) ? _selectedTitle : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  prefixIcon: const Icon(Icons.emoji_events_outlined, color: Colors.amber),
                ),
                isExpanded: true,
                hint: const Text("Select a title"),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('None (Hidden)'),
                  ),
                  ..._unlockedTitles.map((title) => DropdownMenuItem<String?>(
                    value: title,
                    child: Text(title),
                  )),
                ],
                onChanged: (val) => setState(() => _selectedTitle = val),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isSaving 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
            : const Text('Save'),
        ),
      ],
    );
  }
}
