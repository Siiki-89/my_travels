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

  // CREATE
  Future<void> insertComment(Comment comment) async {
    final db = await _dbService.database;

    await db.transaction((txn) async {
      final commentId = await txn.insert(
        CommentTable.tableName,
        comment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final photo in comment.photos) {
        final photoMap = photo.toMap();
        photoMap['comment_id'] = commentId;
        await txn.insert(CommentPhotoTable.tableName, photoMap);
      }
    });
  }

  // READ ALL
  Future<List<Comment>> getCommentsByStopPointId(int stopPointId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> commentMaps = await db.query(
      CommentTable.tableName,
      where: '${CommentTable.stopPointId} = ?',
      whereArgs: [stopPointId],
    );

    final List<Comment> comments = [];

    for (var commentMap in commentMaps) {
      final int commentId = commentMap[CommentTable.id] as int;

      // Buscar as fotos do comentário
      final List<Map<String, dynamic>> photoMaps = await db.query(
        CommentPhotoTable.tableName,
        where: '${CommentPhotoTable.commentId} = ?',
        whereArgs: [commentId],
      );
      final photos = photoMaps.map((map) => CommentPhoto.fromMap(map)).toList();

      // Buscar o viajante do comentário
      final int travelerId = commentMap[CommentTable.travelerId] as int;
      final travelerMap = await db.query(
        TravelerTable.tableName,
        where: '${TravelerTable.id} = ?',
        whereArgs: [travelerId],
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

  // DELETE
  Future<void> deleteComment(int id) async {
    final db = await _dbService.database;
    await db.transaction((txn) async {
      await txn.delete(
        CommentPhotoTable.tableName,
        where: '${CommentPhotoTable.commentId} = ?',
        whereArgs: [id],
      );
      await txn.delete(
        CommentTable.tableName,
        where: '${CommentTable.id} = ?',
        whereArgs: [id],
      );
    });
  }
}
