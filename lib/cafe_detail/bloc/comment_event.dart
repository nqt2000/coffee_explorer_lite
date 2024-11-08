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

class EditComment extends CommentEvent {
  final int commentId;
  final String newComment;
  final int cafeId;

  const EditComment(this.commentId, this.newComment, this.cafeId);

  @override
  List<Object> get props => [commentId, newComment, cafeId];
}

class HideComment extends CommentEvent {
  final int commentId;
  final int cafeId;

  const HideComment(this.commentId, this.cafeId);

  @override
  List<Object> get props => [commentId];
}

class FetchComments extends CommentEvent {
  final int cafeId;

  const FetchComments(this.cafeId);

  @override
  List<Object> get props => [cafeId];
}
