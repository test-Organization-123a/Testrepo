import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart' hide Locator;
import '../../../data/models/location.dart';
import '../../state/location_provider.dart';

class LocationFormDialog extends StatefulWidget {
  final Location? existingLocation;
  
  const LocationFormDialog({super.key, this.existingLocation});

  @override
  State<LocationFormDialog> createState() => _LocationFormDialogState();
}

class _LocationFormDialogState extends State<LocationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;

  bool _isLoading = false;
  File? _pickedImage;
  Uint8List? _webImageBytes;
  String? _webImageName;

  @override
  void initState() {
    super.initState();
    final location = widget.existingLocation;
    _nameController = TextEditingController(text: location?.name ?? '');
    _descriptionController = TextEditingController(text: location?.description ?? '');
    _addressController = TextEditingController(text: location?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source, imageQuality: 75);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _webImageName = picked.name;
          _pickedImage = null;
        });
      } else {
        setState(() {
          _pickedImage = File(picked.path);
          _webImageBytes = null;
          _webImageName = null;
        });
      }
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 32,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            'No image selected',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveLocation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.existingLocation != null) {
        await context.read<LocationProvider>().updateLocation(
          widget.existingLocation!.id, 
          {
            'name': _nameController.text.trim(),
            'description': _descriptionController.text.trim(),
            'address': _addressController.text.trim(),
          },
          imageFile: _pickedImage,
          webImageBytes: _webImageBytes,
          webImageName: _webImageName,
          existingImages: widget.existingLocation!.imageUrls,
        );
      } else {
        await context.read<LocationProvider>().createLocation(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          address: _addressController.text.trim(),
          imageFiles: _pickedImage != null ? [_pickedImage!] : null,
          webImageBytes: _webImageBytes,
          webImageName: _webImageName,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save location: $e'),
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
    final isEditing = widget.existingLocation != null;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        isEditing ? 'Edit Location' : 'Add New Location',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: Colors.orange[800],
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
                    labelText: 'Location Name *',
                    hintText: 'e.g., Eagle Peak Crag',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Location name is required';
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
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    hintText: 'Describe the climbing location...',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required';
                    }
                    if (value.trim().length < 10) {
                      return 'Description must be at least 10 characters';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address *',
                    hintText: 'Full address or coordinates',
                    prefixIcon: Icon(Icons.place),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Address is required';
                    }
                    if (value.trim().length < 5) {
                      return 'Address must be at least 5 characters';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location Image',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Builder(
                        builder: (context) {
                          if (kIsWeb) {
                            if (_webImageBytes != null) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.memory(
                                  _webImageBytes!,
                                  width: double.infinity,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              );
                            } else if (widget.existingLocation?.imageUrls.isNotEmpty == true) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.network(
                                  widget.existingLocation!.imageUrls.first,
                                  width: double.infinity,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                                ),
                              );
                            } else {
                              return _buildPlaceholder();
                            }
                          } else {
                            if (_pickedImage != null) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.file(
                                  _pickedImage!,
                                  width: double.infinity,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                                ),
                              );
                            } else if (widget.existingLocation?.imageUrls.isNotEmpty == true) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.network(
                                  widget.existingLocation!.imageUrls.first,
                                  width: double.infinity,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                                ),
                              );
                            } else {
                              return _buildPlaceholder();
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Pick from Gallery'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange[800],
                              side: BorderSide(color: Colors.orange[300]!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Take Photo'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange[800],
                              side: BorderSide(color: Colors.orange[300]!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
          onPressed: _isLoading ? null : _saveLocation,
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