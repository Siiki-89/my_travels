const commentPhotoTableName = 'CommentPhoto';
const commentPhotoTableId = 'id';
const commentPhotoTableCommentId = 'comment_id';
const commentPhotoTableImagePath = 'image_path';

const createCommentPhotoTable =
    '''
  CREATE TABLE $commentPhotoTableName(
    $commentPhotoTableId INTEGER PRIMARY KEY AUTOINCREMENT,
    $commentPhotoTableCommentId INTEGER NOT NULL,
    $commentPhotoTableImagePath TEXT NOT NULL,
    FOREIGN KEY ($commentPhotoTableCommentId) REFERENCES Comment(id)
  );
''';
