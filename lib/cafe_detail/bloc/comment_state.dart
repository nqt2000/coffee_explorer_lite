import 'package:equatable/equatable.dart';

abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentError extends CommentState {
  final String message;

  const CommentError(this.message);

  @override
  List<Object?> get props => [message];
}

class CommentLoaded extends CommentState {
  final List<Map<String, dynamic>> comments;

  const CommentLoaded(this.comments);

  @override
  List<Object?> get props => [comments];
}

class CommentActionSuccess extends CommentState {}

class UpdateCommentSuccess extends CommentState {}

class UpdateCommentFailure extends CommentState {
  final String error;

  const UpdateCommentFailure(this.error);
}
