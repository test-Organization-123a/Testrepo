import 'package:flutter/material.dart';
import 'package:provider/provider.dart' hide Locator;
import '../../../data/models/route.dart';
import '../../state/route_provider.dart';

class RouteFormDialog extends StatefulWidget {
  final RouteModel? existingRoute;
  final String locationId;
  
  const RouteFormDialog({
    super.key, 
    this.existingRoute,
    required this.locationId,
  });

  @override
  State<RouteFormDialog> createState() => _RouteFormDialogState();
}

class _RouteFormDialogState extends State<RouteFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _gradeController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final route = widget.existingRoute;
    _nameController = TextEditingController(text: route?.name ?? '');
    _descriptionController = TextEditingController(text: route?.description ?? '');
    _gradeController = TextEditingController(text: route?.grade ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  Future<void> _saveRoute() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.existingRoute != null) {
        await context.read<RouteProvider>().updateRoute(
          widget.existingRoute!.id, 
          {
            'name': _nameController.text.trim(),
            'description': _descriptionController.text.trim(),
            'grade': _gradeController.text.trim(),
          },
        );
      } else {
        await context.read<RouteProvider>().createRoute(
          name: _nameController.text.trim(),
          grade: _gradeController.text.trim(),
          locationId: widget.locationId,
          description: _descriptionController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save route: $e'),
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
    final isEditing = widget.existingRoute != null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Text(
        isEditing ? 'Edit Route' : 'Add New Route',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Route Name *',
                    hintText: 'e.g., Eagle\'s Ascent',
                    prefixIcon: Icon(Icons.route),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Route name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _gradeController,
                  decoration: const InputDecoration(
                    labelText: 'Grade *',
                    hintText: 'e.g., 5.10a, V4, 6b+',
                    prefixIcon: Icon(Icons.trending_up),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Grade is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Grade must be at least 2 characters';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.none,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe the route, holds, difficulty...',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveRoute,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}