import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/route.dart';
import '../../../data/models/location.dart';
import '../../widgets/generic_page_items/header.dart';
import '../../widgets/generic_page_items/bottom_navigation.dart';

class RouteDetailScreen extends StatefulWidget {
  final RouteModel route;
  final Location? location;

  const RouteDetailScreen({
    super.key,
    required this.route,
    this.location,
  });

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  bool _showFullDescription = false;
  int? _selectedRating;

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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 800;
                  
                  if (isWideScreen) {
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 1,
                            child: _buildRouteInfoCard(context, theme, colorScheme),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: _buildRouteInformationCard(context, theme, colorScheme),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Column(
                      children: [
                        _buildRouteInfoCard(context, theme, colorScheme),
                        const SizedBox(height: 16),
                        _buildRouteInformationCard(context, theme, colorScheme),
                      ],
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 16),

            if (widget.route.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: _buildDescriptionCard(context, theme, colorScheme),
                ),
              ),

            const SizedBox(height: 16),

            if (widget.route.ratings.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Ratings',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...widget.route.ratings.asMap().entries.map((entry) {
                          final index = entry.key;
                          final rating = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index < widget.route.ratings.length - 1 ? 12 : 0,
                            ),
                            child: _buildRatingItem(context, rating, index),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rate this Route',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'How would you grade this route?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          '5a', '5b', '5c', '6a', '6b', '6c', '7a', '7b', '7c',
                          '8a', '8b', '8c', '9a', '9b', '9c'
                        ].map((grade) {
                          final isSelected = _selectedRating == grade.hashCode;
                          return FilterChip(
                            label: Text(grade),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedRating = selected ? grade.hashCode : null;
                              });
                            },
                            selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                            checkmarkColor: colorScheme.primary,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedRating != null ? _submitRating : null,
                          child: const Text('Submit Rating'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingItem(BuildContext context, RouteRating rating, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              'U${index + 1}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grade: ${rating.grade}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  _formatDate(rating.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.star,
            size: 16,
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  bool _shouldShowReadMore() {
    return widget.route.description.length > 150;
  }

  void _shareRoute() {
    final locationInfo = widget.location != null ? ' at ${widget.location!.name}' : '';
    Share.share(
      'Check out this climbing route: ${widget.route.name} (Grade: ${widget.route.grade})$locationInfo\n\n${widget.route.description}',
    );
  }

  void _submitRating() {
    // TODO: Implement rating submission to backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rating submitted! (Feature coming soon)'),
        backgroundColor: Colors.green,
      ),
    );
    setState(() {
      _selectedRating = null;
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Today';
    }
  }

  Widget _buildRouteInfoCard(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.route.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _shareRoute,
                  icon: Icon(
                    Icons.share,
                    color: colorScheme.primary,
                  ),
                  tooltip: 'Share route',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.location != null) ...[
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
                      widget.location!.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.secondary,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 18,
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Grade: ${widget.route.grade}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              'Description',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedCrossFade(
              firstChild: Text(
                widget.route.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(
                widget.route.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
              crossFadeState: _showFullDescription
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
            if (_shouldShowReadMore())
              TextButton(
                onPressed: () {
                  setState(() {
                    _showFullDescription = !_showFullDescription;
                  });
                },
                child: Text(
                  _showFullDescription ? 'Read less' : 'Read more',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteInformationCard(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Route Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              Icons.calendar_today,
              'Added',
              _formatDate(widget.route.createdAt),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              Icons.star_rate,
              'Ratings',
              widget.route.ratings.isEmpty
                  ? 'No ratings yet'
                  : '${widget.route.ratings.length} rating${widget.route.ratings.length != 1 ? 's' : ''}',
            ),
          ],
        ),
      ),
    );
  }
}
