import 'package:flutter/material.dart';
import 'package:prototype/presentation/widgets/user_cards/location_card.dart';
import '../../../data/models/location.dart';

class LocationGrid extends StatelessWidget {
  final List<Location> locations;
  final int crossAxisCount;

  const LocationGrid({
    super.key,
    required this.locations,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.7,
        ),
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];
          return LocationCard(location: location);
        },
      ),
    );
  }
}

