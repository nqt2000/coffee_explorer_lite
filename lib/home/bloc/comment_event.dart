import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => [];
}

class AddComment extends CommentEvent {
  final int cafeId;
  final int userId;
  final String commentText;

  AddComment(this.cafeId, this.userId, this.commentText);

  @override
  List<Object?> get props => [cafeId, userId, commentText];
}

class DeleteComment extends CommentEvent {
  final int commentId;
  final int userId;

  DeleteComment(this.commentId, this.userId);

  @override
  List<Object?> get props => [commentId, userId];
}

class UpdateComment extends CommentEvent {
  final int commentId;
  final String newText;
  final int userId;

  UpdateComment(this.commentId, this.newText, this.userId);

  @override
  List<Object?> get props => [commentId, newText, userId];
}

class HideComment extends CommentEvent {
  final int commentId;
  final int userId;

  HideComment(this.commentId, this.userId);

  @override
  List<Object?> get props => [commentId, userId];
}

class FetchComments extends CommentEvent {
  final int cafeId;

  FetchComments(this.cafeId);

  @override
  List<Object?> get props => [cafeId];
}
