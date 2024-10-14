import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object> get props => [];
}

class AddComment extends CommentEvent {
  final int cafeId;
  final String commentText;

  AddComment(this.cafeId, this.commentText);

  @override
  List<Object> get props => [cafeId, commentText];
}

class UpdateComment extends CommentEvent {
  final int commentId;
  final String newText;

  UpdateComment(this.commentId, this.newText);

  @override
  List<Object> get props => [commentId, newText];
}

class HideComment extends CommentEvent {
  final int commentId;

  HideComment(this.commentId);

  @override
  List<Object> get props => [commentId];
}

class FetchComments extends CommentEvent {
  final int cafeId;

  FetchComments(this.cafeId);

  @override
  List<Object> get props => [cafeId];
}
