import 'package:flutter/material.dart';
import 'package:prototype/data/models/location.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/route.dart';
import '../../widgets/generic_page_items/header.dart';
import '../../widgets/generic_page_items/bottom_navigation.dart';
import '../../widgets/user_cards/route_card.dart';
import '../../widgets/generic_page_items/search_bar_widget.dart';
import 'route_detail_screen.dart';

class LocationDetailScreen extends StatefulWidget {
  final Location location;

  const LocationDetailScreen({super.key, required this.location});

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  int _currentImageIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<RouteModel> _filteredRoutes = [];

  @override
  void initState() {
    super.initState();
    _filteredRoutes = widget.location.routes;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _previousImage() {
    if (_currentImageIndex > 0) {
      setState(() {
        _currentImageIndex--;
      });
    }
  }

  void _nextImage() {
    if (_currentImageIndex < widget.location.imageUrls.length - 1) {
      setState(() {
        _currentImageIndex++;
      });
    }
  }

  void _filterRoutes(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredRoutes = widget.location.routes;
      } else {
        _filteredRoutes = widget.location.routes
            .where((route) =>
                route.name.toLowerCase().contains(query.toLowerCase()) ||
                route.grade.toLowerCase().contains(query.toLowerCase()) ||
                route.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _shareLocation() {
    Share.share(
      'Check out this climbing location: ${widget.location.name}\n${widget.location.description}\n\nAddress: ${widget.location.address}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: const CustomHeader(showMenuButton: false),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.location.hasImages) _buildImageCarousel(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.location.name,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _shareLocation,
                        icon: Icon(
                          Icons.share,
                          color: colorScheme.primary,
                        ),
                        tooltip: 'Share location',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.location.address,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.location.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Text(
                        'Routes',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.location.routes.length}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            if (widget.location.routes.isNotEmpty)
              SearchBarWidget(
                hintText: 'Search routes...',
                onChanged: _filterRoutes,
                controller: _searchController,
              ),
            
            if (_filteredRoutes.isEmpty && _searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No routes found matching "$_searchQuery"',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else if (widget.location.routes.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.route,
                        size: 64,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No routes available at this location yet',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredRoutes.length,
                itemBuilder: (context, index) {
                  final route = _filteredRoutes[index];
                  return RouteCard(
                    route: route,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RouteDetailScreen(
                            route: route,
                            location: widget.location,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(
        currentDestination: AppDestination.locations,
      ),
    );
  }

  Widget _buildImageCarousel() {    
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: 300,
            child: ClipRRect(
              child: Image.network(
                widget.location.imageUrls.isNotEmpty
                    ? widget.location.imageUrls[_currentImageIndex]
                    : 'https://via.placeholder.com/400',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),

          if (widget.location.imageUrls.length > 1) ...[
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  onPressed: _previousImage,
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.orangeAccent,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  onPressed: _nextImage,
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.orangeAccent,
                  ),
                ),
              ),
            ),
          ],

          if (widget.location.imageUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.location.imageUrls.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentImageIndex
                          ? Colors.orange
                          : Colors.amber,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}