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

  CommentError(this.message);

  @override
  List<Object?> get props => [message];
}

class CommentLoaded extends CommentState {
  final List<Map<String, dynamic>> comments;

  CommentLoaded(this.comments);

  @override
  List<Object?> get props => [comments];
}

class CommentActionSuccess extends CommentState {}
