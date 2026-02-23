import 'package:flutter/material.dart';
import 'package:provider/provider.dart' hide Locator;
import 'package:prototype/presentation/widgets/generic_page_items/header.dart';
import '../../../data/models/location.dart';
import '../../state/location_provider.dart';
import '../../widgets/generic_page_items/admin_bottom_navigation.dart';
import '../../widgets/form_dialogs/location_form_dialog.dart';
import '../../widgets/admin_cards/admin_location_card.dart';
import 'admin_location_detail_screen.dart';

class AdminLocationsScreen extends StatefulWidget {
  const AdminLocationsScreen({super.key});

  @override
  State<AdminLocationsScreen> createState() => _AdminLocationsScreenState();
}

class _AdminLocationsScreenState extends State<AdminLocationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().loadLocations();
    });
  }

  Future<void> _fetchLocations() async {
    await context.read<LocationProvider>().loadLocations();
  }

  Future<void> _openLocationDialog({Location? location}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => LocationFormDialog(existingLocation: location),
    );

    if (result == true) _fetchLocations();
  }

  Future<void> _deleteLocation(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Location'),
        content: const Text('Are you sure you want to delete this location? This action cannot be undone and will also delete all routes at this location.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      if (!mounted) return;
      await context.read<LocationProvider>().deleteLocation(id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete location: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(showMenuButton: false),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          final isLoading = locationProvider.isLoading;
          final error = locationProvider.error;
          final locations = locationProvider.locations;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => locationProvider.loadLocations(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (locations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No locations yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first climbing location!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => locationProvider.loadLocations(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final location = locations[index];
                return AdminLocationCard(
                  location: location,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminLocationDetailScreen(location: location),
                      ),
                    );
                  },
                  onEdit: () => _openLocationDialog(location: location),
                  onDelete: () => _deleteLocation(location.id),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openLocationDialog(),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Location'),
      ),
      bottomNavigationBar: const AdminBottomNavigationWidget(
        currentDestination: AdminDestination.locations,
      ),
    );
  }
}
