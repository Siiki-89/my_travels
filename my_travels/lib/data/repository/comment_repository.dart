import 'package:my_travels/data/entities/comment_entity.dart';
import 'package:my_travels/data/entities/comment_photo_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/data/local/database_service.dart';
import 'package:my_travels/data/tables/comment_photo_table.dart';
import 'package:my_travels/data/tables/comment_table.dart';
import 'package:my_travels/data/tables/traveler_table.dart';
import 'package:sqflite/sqflite.dart';

class CommentRepository {
  final DatabaseService _dbService = DatabaseService.instance;

  Future<void> insertComment(Comment comment) async {
    final db = await _dbService.database;

    await db.transaction((txn) async {
      final map = comment.toMap();
      map.remove('id');

      final commentId = await txn.insert(
        CommentTable.tableName,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final photo in comment.photos) {
        final photoMap = photo.toMap();
        photoMap.remove('id');
        photoMap[CommentPhotoTable.commentId] = commentId;
        await txn.insert(CommentPhotoTable.tableName, photoMap);
      }
    });
  }

  Future<List<Comment>> getCommentsByStopPointId(int stopPointId) async {
    final db = await _dbService.database;
    final commentMaps = await db.query(
      CommentTable.tableName,
      where: '${CommentTable.stopPointId} = ?',
      whereArgs: [stopPointId],
    );

    final comments = <Comment>[];
    for (final commentMap in commentMaps) {
      final commentId = commentMap[CommentTable.id] as int;

      final photoMaps = await db.query(
        CommentPhotoTable.tableName,
        where: '${CommentPhotoTable.commentId} = ?',
        whereArgs: [commentId],
      );
      final photos = photoMaps.map((map) => CommentPhoto.fromMap(map)).toList();

      final travelerIdValue = commentMap[CommentTable.travelerId] as int;
      final travelerMap = await db.query(
        TravelerTable.tableName,
        where: '${TravelerTable.id} = ?',
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
