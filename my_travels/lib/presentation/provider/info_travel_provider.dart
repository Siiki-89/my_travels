import 'package:flutter/material.dart';
import 'package:my_travels/data/entities/comment_entity.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/repository/comment_repository.dart';

class InfoTravelProvider extends ChangeNotifier {
  final CommentRepository _commentRepository = CommentRepository();
  final Travel travel;
  List<Comment> comments = [];
  List<String> allImagePaths = [];
  bool isLoading = true;

  // Add this to track the active carousel page
  int currentImageIndex = 0;

  InfoTravelProvider({required this.travel}) {
    _loadAllContent();
  }

  // Add this method to update the index
  void setCurrentImageIndex(int index) {
    currentImageIndex = index;
    notifyListeners();
  }

  Future<void> _loadAllContent() async {
    isLoading = true;
    notifyListeners();

    // The logic to get comments...
    final List<Comment> allComments = [];
    for (final stopPoint in travel.stopPoints) {
      if (stopPoint.id != null) {
        final stopPointComments = await _commentRepository
            .getCommentsByStopPointId(stopPoint.id!);
        allComments.addAll(stopPointComments);
      }
    }
    comments = allComments;

    // Combines the cover image with photos from comments
    final List<String> paths = [];
    if (travel.coverImagePath != null && travel.coverImagePath!.isNotEmpty) {
      // Check for empty string
      paths.add(travel.coverImagePath!);
    }
    for (final comment in comments) {
      for (final photo in comment.photos) {
        paths.add(photo.imagePath);
      }
    }
    allImagePaths = paths;

    isLoading = false;
    notifyListeners();
  }
}
