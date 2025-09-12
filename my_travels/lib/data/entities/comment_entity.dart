import 'package:my_travels/data/entities/comment_photo_entity.dart';
import 'package:my_travels/data/entities/stop_point_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';

/// Represents a user comment associated with a specific stop point.
class Comment {
  /// Creates a comment instance.
  const Comment({
    this.id,
    required this.stopPointId,
    required this.travelerId,
    required this.content,
    this.stopPoint,
    this.traveler,
    this.photos = const [],
  });

  /// The unique identifier of the comment.
  final int? id;

  /// The ID of the stop point this comment is linked to.
  final int stopPointId;

  /// The ID of the traveler who made the comment.
  final int travelerId;

  /// The text content of the comment.
  final String content;

  /// The associated stop point object (optional, loaded separately).
  final StopPoint? stopPoint;

  /// The associated traveler object (optional, loaded separately).
  final Traveler? traveler;

  /// A list of photos attached to the comment.
  final List<CommentPhoto> photos;

  /// Converts this Comment instance to a map for database storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stop_point_id': stopPointId,
      'traveler_id': travelerId,
      'content': content,
    };
  }

  /// Creates a Comment instance from a map retrieved from the database.
  factory Comment.fromMap(
    Map<String, dynamic> map, {
    StopPoint? stopPoint,
    Traveler? traveler,
    List<CommentPhoto>? photos,
  }) {
    return Comment(
      id: map['id'] as int?,
      stopPointId: map['stop_point_id'] as int,
      travelerId: map['traveler_id'] as int,
      content: map['content'] as String,
      stopPoint: stopPoint,
      traveler: traveler,
      photos: photos ?? [],
    );
  }

  /// Creates a copy of this Comment with the given fields replaced with new values.
  Comment copyWith({
    int? id,
    int? stopPointId,
    int? travelerId,
    String? content,
    StopPoint? stopPoint,
    Traveler? traveler,
    List<CommentPhoto>? photos,
  }) {
    return Comment(
      id: id ?? this.id,
      stopPointId: stopPointId ?? this.stopPointId,
      travelerId: travelerId ?? this.travelerId,
      content: content ?? this.content,
      stopPoint: stopPoint ?? this.stopPoint,
      traveler: traveler ?? this.traveler,
      photos: photos ?? this.photos,
    );
  }
}
