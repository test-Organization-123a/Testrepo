import 'package:flutter/material.dart';
import 'package:prototype/data/models/location.dart';
import 'package:prototype/presentation/widgets/user_cards/location_grid.dart';
import 'package:prototype/presentation/widgets/generic_page_items/search_bar_widget.dart';
import 'package:prototype/presentation/widgets/generic_page_items/header.dart';
import 'package:prototype/presentation/widgets/generic_page_items/bottom_navigation.dart';
import 'package:provider/provider.dart';

import '../../state/location_provider.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().loadLocations();
    });
  }

  void _filterLocations(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<Location> _getFilteredLocations(List<Location> locations) {
    if (_searchQuery.isEmpty) {
      return locations;
    } else {
      return locations.where((location) {
        final nameMatch = location.name.toLowerCase().contains(_searchQuery.toLowerCase());
        final addressMatch = location.address.toLowerCase().contains(_searchQuery.toLowerCase());
        return nameMatch || addressMatch;
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final locationProvider = context.watch<LocationProvider>();
    final filteredLocations = _getFilteredLocations(locationProvider.locations);
    
    return Scaffold(
      appBar: const CustomHeader(),
      body: locationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : locationProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${locationProvider.error}'),
                      ElevatedButton(
                        onPressed: () => context.read<LocationProvider>().loadLocations(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    SearchBarWidget(
                      hintText: 'Search locations by name or address...',
                      onChanged: _filterLocations,
                    ),
                    Expanded(
                      child: LocationGrid(
                        locations: filteredLocations,
                        crossAxisCount: isMobile ? 2 : 3,
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: const BottomNavigationWidget(
        currentDestination: AppDestination.locations,
      ),
    );
  }
}