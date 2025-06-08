import 'attraction_model.dart';

class ItineraryItem {
  final Attraction attraction;
  final DateTime visitTime;
  final Duration estimatedDuration;
  final String notes;

  ItineraryItem({
    required this.attraction,
    required this.visitTime,
    this.estimatedDuration = const Duration(hours: 2),
    this.notes = '',
  });

  ItineraryItem copyWith({
    Attraction? attraction,
    DateTime? visitTime,
    Duration? estimatedDuration,
    String? notes,
  }) {
    return ItineraryItem(
      attraction: attraction ?? this.attraction,
      visitTime: visitTime ?? this.visitTime,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      notes: notes ?? this.notes,
    );
  }
}
