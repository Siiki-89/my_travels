class CommentPhoto {
  const CommentPhoto({
    this.id,
    required this.commentId,
    required this.imagePath,
  });

  final int? id;
  final int commentId;
  final String imagePath;

  Map<String, dynamic> toMap() {
    return {'id': id, 'comment_id': commentId, 'image_path': imagePath};
  }

  factory CommentPhoto.fromMap(Map<String, dynamic> map) {
    return CommentPhoto(
      id: map['id'],
      commentId: map['comment_id'],
      imagePath: map['image_path'],
    );
  }
}
