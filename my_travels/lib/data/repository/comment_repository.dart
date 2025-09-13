import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'package:my_travels/data/entities/comment_entity.dart';
import 'package:my_travels/data/entities/comment_photo_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/data/local/database_service.dart';
import 'package:my_travels/data/tables/comment_photo_table.dart';
import 'package:my_travels/data/tables/comment_table.dart';
import 'package:my_travels/data/tables/traveler_table.dart';

/// Manages comment-related data operations with the local database.
class CommentRepository {
  /// The singleton instance of the database service.
  final DatabaseService _dbService = DatabaseService.instance;

  /// Inserts a new comment and its associated photos into the database.
  ///
  /// This operation is performed within a transaction to ensure data integrity.
  Future<void> insertComment(Comment comment) async {
    final db = await _dbService.database;
    try {
      await db.transaction((txn) async {
        final map = comment.toMap();
        // Remove 'id' because the database will auto-generate it.
        map.remove('id');

        final commentId = await txn.insert(
          CommentTable.tableName,
          map,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Insert each photo, linking it to the newly created comment.
        for (final photo in comment.photos) {
          final photoMap = photo.toMap();
          photoMap.remove('id');
          photoMap[CommentPhotoTable.commentId] = commentId;
          await txn.insert(CommentPhotoTable.tableName, photoMap);
        }
      });
    } catch (e) {
      // debugPrint('Erro ao inserir comentário: $e');
      rethrow;
    }
  }

  /// Retrieves all comments for a specific stop point ID.
  ///
  /// For each comment, it also fetches the associated traveler and photos.
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

      // Fetch associated photos for the current comment.
      final photoMaps = await db.query(
        CommentPhotoTable.tableName,
        where: '${CommentPhotoTable.commentId} = ?',
        whereArgs: [commentId],
      );
      final photos = photoMaps.map((map) => CommentPhoto.fromMap(map)).toList();

      // Fetch the traveler who wrote the comment.
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

  /// Updates an existing comment in the database.
  Future<void> updateComment(Comment comment) async {
    try {
      final db = await _dbService.database;
      await db.update(
        CommentTable.tableName,
        comment.toMap(),
        where: '${CommentTable.id} = ?',
        whereArgs: [comment.id],
      );
    } catch (e) {
      // debugPrint('Erro ao atualizar comentário: $e');
      rethrow;
    }
  }

  /// Deletes a comment and its associated photos from the database.
  Future<void> deleteComment(int commentId) async {
    try {
      final db = await _dbService.database;
      await db.transaction((txn) async {
        // Deleta as fotos associadas primeiro
        await txn.delete(
          CommentPhotoTable.tableName,
          where: '${CommentPhotoTable.commentId} = ?',
          whereArgs: [commentId],
        );
        // Depois deleta o comentário principal
        await txn.delete(
          CommentTable.tableName,
          where: '${CommentTable.id} = ?',
          whereArgs: [commentId],
        );
      });
    } catch (e) {
      // debugPrint('Erro ao deletar comentário: $e');
      rethrow;
    }
  }
}
