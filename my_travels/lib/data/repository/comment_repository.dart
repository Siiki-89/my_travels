import 'package:my_travels/data/entities/comment_entity.dart';
import 'package:my_travels/data/entities/comment_photo_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/data/local/database_service.dart';
import 'package:my_travels/data/tables/comment_photo_table.dart';
import 'package:my_travels/data/tables/comment_table.dart';
import 'package:my_travels/data/tables/traveler_table.dart';
import 'package:sqflite/sqflite.dart';

class CommentRepository {
  CommentRepository({required this.dbService});
  final DatabaseService dbService;

  Future<void> insertComment(Comment comment) async {
    final db = await dbService.database;

    await db.transaction((txn) async {
      final commentId = await txn.insert(
        commentTableName,
        comment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final photo in comment.photos) {
        final photoMap = photo.toMap();
        photoMap[commentPhotoTableCommentId] = commentId;
        await txn.insert(commentPhotoTableName, photoMap);
      }
    });
  }

  Future<List<Comment>> getCommentsByStopPointId(int stopPointId) async {
    final db = await dbService.database;
    final commentMaps = await db.query(
      commentTableName,
      where: '$commentTableStopPointId = ?',
      whereArgs: [stopPointId],
    );

    final comments = <Comment>[];

    for (final commentMap in commentMaps) {
      final commentId = commentMap[commentTableId] as int;

      final photoMaps = await db.query(
        commentPhotoTableName,
        where: '$commentPhotoTableCommentId = ?',
        whereArgs: [commentId],
      );
      final photos = photoMaps.map(CommentPhoto.fromMap).toList();

      final travelerIdValue = commentMap[commentTableTravelerId] as int;
      final travelerMap = await db.query(
        travelerTableName,
        where: '$travelerTableId = ?',
        whereArgs: [travelerIdValue],
      );
      final traveler = travelerMap.isNotEmpty
          ? Traveler.fromMap(travelerMap.first)
          : null;

      comments.add(
        Comment.fromMap(commentMap, traveler: traveler, photos: photos),
      );
    }
    return comments;
  }
}
