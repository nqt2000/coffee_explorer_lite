import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/database_helper.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final DatabaseHelper _dbHelper;

  CommentBloc(this._dbHelper) : super(CommentInitial()) {
    on<AddComment>(_onAddComment);
    on<DeleteComment>(_onDeleteComment);
    on<UpdateComment>(_onUpdateComment);
    on<HideComment>(_onHideComment);
    on<FetchComments>(_onFetchComments);
  }

  Future<void> _onAddComment(AddComment event, Emitter<CommentState> emit) async {
    try {
      emit(CommentLoading());
      await _dbHelper.insertComment(event.cafeId, event.userId, event.commentText);
      emit(CommentActionSuccess());
      add(FetchComments(event.cafeId));
    } catch (e) {
      emit(CommentError('Failed to add comment'));
    }
  }

  Future<void> _onDeleteComment(DeleteComment event, Emitter<CommentState> emit) async {
    try {
      emit(CommentLoading());
      await _dbHelper.deleteComment(event.commentId, event.userId);
      emit(CommentActionSuccess());
    } catch (e) {
      emit(CommentError('Failed to delete comment'));
    }
  }

  Future<void> _onUpdateComment(UpdateComment event, Emitter<CommentState> emit) async {
    try {
      emit(CommentLoading());
      await _dbHelper.updateComment(event.commentId, event.newText, event.userId);
      emit(CommentActionSuccess());
    } catch (e) {
      emit(CommentError('Failed to update comment'));
    }
  }

  Future<void> _onHideComment(HideComment event, Emitter<CommentState> emit) async {
    try {
      emit(CommentLoading());
      await _dbHelper.hideComment(event.commentId, event.userId);
      emit(CommentActionSuccess());
    } catch (e) {
      emit(CommentError('Failed to hide comment'));
    }
  }

  Future<void> _onFetchComments(FetchComments event, Emitter<CommentState> emit) async {
    try {
      emit(CommentLoading());
      List<Map<String, dynamic>> comments = await _dbHelper.getCommentsByCafe(event.cafeId);
      emit(CommentLoaded(comments));
    } catch (e) {
      emit(CommentError('Failed to load comments'));
    }
  }
}
