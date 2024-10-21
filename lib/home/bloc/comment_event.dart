import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object> get props => [];
}

class AddComment extends CommentEvent {
  final int cafeId;
  final String commentText;

  const AddComment(this.cafeId, this.commentText);

  @override
  List<Object> get props => [cafeId, commentText];
}

class UpdateComment extends CommentEvent {
  final int commentId;
  final String newText;

  const UpdateComment(this.commentId, this.newText);

  @override
  List<Object> get props => [commentId, newText];
}

class HideComment extends CommentEvent {
  final int commentId;

  const HideComment(this.commentId);

  @override
  List<Object> get props => [commentId];
}

class FetchComments extends CommentEvent {
  final int cafeId;

  const FetchComments(this.cafeId);

  @override
  List<Object> get props => [cafeId];
}
