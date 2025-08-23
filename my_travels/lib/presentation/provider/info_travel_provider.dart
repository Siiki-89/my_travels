import 'package:flutter/cupertino.dart';
import 'package:my_travels/data/entities/comment_entity.dart';
import 'package:my_travels/data/repository/comment_repository.dart';

class InfoTravelProvider with ChangeNotifier  {
  List<Comment> _imagePaths = [];
  List<Comment> get imagePaths => _imagePaths;
  final CommentRepository _commentRepository = CommentRepository();

  InfoTravelProvider (int id){
    loadImagesPath(id);
  }

  Future<void> loadImagesPath (int id) async{
    _imagePaths = await _commentRepository.getCommentsByStopPointId(id);
    notifyListeners();
  }

}