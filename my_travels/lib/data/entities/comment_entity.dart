import 'package:my_travels/data/entities/comment_photo_entity.dart';
import 'package:my_travels/data/entities/stop_point_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';

class Comment {
  final int? id;
  final int stopPointId;
  final int travelerId;
  final String content;
  final StopPoint? stopPoint;
  final Traveler? traveler;
  final List<CommentPhoto> photos;

  Comment({
    this.id,
    required this.stopPointId,
    required this.travelerId,
    required this.content,
    this.stopPoint,
    this.traveler,
    this.photos = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stop_point_id': stopPointId,
      'traveler_id': travelerId,
      'content': content,
    };
  }

  factory Comment.fromMap(
    Map<String, dynamic> map, {
    StopPoint? stopPoint,
    Traveler? traveler,
    List<CommentPhoto>? photos,
  }) {
    return Comment(
      id: map['id'],
      stopPointId: map['stop_point_id'],
      travelerId: map['traveler_id'],
      content: map['content'],
      stopPoint: stopPoint,
      traveler: traveler,
      photos: photos ?? [],
    );
  }
}
