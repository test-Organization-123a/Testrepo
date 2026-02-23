import 'package:flutter/material.dart';
import 'package:prototype/presentation/widgets/generic_page_items/header.dart';
import 'package:provider/provider.dart' hide Locator;
import '../../../data/models/location.dart';
import '../../../data/models/route.dart';
import '../../state/route_provider.dart';
import '../../widgets/form_dialogs/route_form_dialog.dart';
import '../../widgets/admin_cards/admin_route_card.dart';

class AdminLocationDetailScreen extends StatefulWidget {
  final Location location;

  const AdminLocationDetailScreen({
    super.key,
    required this.location,
  });

  @override
  State<AdminLocationDetailScreen> createState() => _AdminLocationDetailScreenState();
}

class _AdminLocationDetailScreenState extends State<AdminLocationDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RouteProvider>().loadRoutes();
    });
  }

  Future<void> _openRouteDialog({RouteModel? route}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => RouteFormDialog(
        existingRoute: route,
        locationId: widget.location.id,
      ),
    );

    if (result == true && mounted) {
      context.read<RouteProvider>().loadRoutes();
    }
  }

  Future<void> _deleteRoute(String routeId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Route'),
        content: const Text('Are you sure you want to delete this route? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
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
      await context.read<RouteProvider>().deleteRoute(routeId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete route: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: const CustomHeader(showMenuButton: false),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.location.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.location.address,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.location.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Consumer<RouteProvider>(
              builder: (context, routeProvider, child) {
                final isLoading = routeProvider.isLoading;
                final error = routeProvider.error;
                
                final locationRoutes = routeProvider.routes
                    .where((route) => route.locationId == widget.location.id)
                    .toList();

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
                          onPressed: () => routeProvider.loadRoutes(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (locationRoutes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.route_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No routes yet',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add the first climbing route for this location!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => routeProvider.loadRoutes(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: locationRoutes.length,
                    itemBuilder: (context, index) {
                      final route = locationRoutes[index];
                      return AdminRouteCard(
                        route: route,
                        onEdit: () => _openRouteDialog(route: route),
                        onDelete: () => _deleteRoute(route.id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openRouteDialog(),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Route'),
      ),
    );
  }
}