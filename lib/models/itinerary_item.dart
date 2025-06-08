import 'package:mobilev2/models/tourist_attraction_model.dart';

class ItineraryItem {
  final TouristAttraction attraction;
  final DateTime visitTime;
  final Duration estimatedDuration;
  final String notes;

  ItineraryItem({
    required this.attraction,
    required this.visitTime,
    required this.estimatedDuration,
    this.notes = '',
  });

  ItineraryItem copyWith({
    TouristAttraction? attraction,
    DateTime? visitTime,
    Duration? estimatedDuration,
    String? notes,
}){
    return ItineraryItem(
      attraction: attraction ?? this.attraction,
      visitTime: visitTime ?? this.visitTime,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      notes: notes ?? this.notes,
    );
  }
}
