/// Represents a photo attached to a comment.
class CommentPhoto {
  /// Creates a comment photo instance.
  const CommentPhoto({
    this.id,
    required this.commentId,
    required this.imagePath,
  });

  /// The unique identifier of the comment photo.
  final int? id;

  /// The ID of the comment this photo is linked to.
  final int commentId;

  /// The local file path of the image.
  final String imagePath;

  /// Converts this CommentPhoto instance to a map for database storage.
  Map<String, dynamic> toMap() {
    return {'id': id, 'comment_id': commentId, 'image_path': imagePath};
  }

  /// Creates a CommentPhoto instance from a map retrieved from the database.
  factory CommentPhoto.fromMap(Map<String, dynamic> map) {
    return CommentPhoto(
      id: map['id'] as int?,
      commentId: map['comment_id'] as int,
      imagePath: map['image_path'] as String,
    );
  }

  /// Creates a copy of this CommentPhoto with the given fields replaced with new values.
  CommentPhoto copyWith({int? id, int? commentId, String? imagePath}) {
    return CommentPhoto(
      id: id ?? this.id,
      commentId: commentId ?? this.commentId,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
