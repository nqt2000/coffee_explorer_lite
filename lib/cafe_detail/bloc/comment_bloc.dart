import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/database_helper.dart';
import '../../utils/session_manager.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final DatabaseHelper _dbHelper;

  CommentBloc(this._dbHelper) : super(CommentInitial()) {
    on<AddComment>(_onAddComment);
    on<EditComment>(_onUpdateComment);
    on<HideComment>(_onHideComment);
    on<FetchComments>(_onFetchComments);
  }

  Future<int?> _getUserId() async {
    SessionManager sessionManager = SessionManager();
    Map<String, dynamic>? userInfo = await sessionManager.getUserInfo();
    return userInfo?['id'];
  }

  Future<bool> _isAdmin() async {
    SessionManager sessionManager = SessionManager();
    Map<String, dynamic>? userInfo = await sessionManager.getUserInfo();
    return (userInfo?['isAdmin'] ?? 0) == 1;
  }

  Future<void> _onAddComment(
      AddComment event, Emitter<CommentState> emit) async {
    try {
      emit(CommentLoading());

      int? userId = await _getUserId();
      if (userId != null) {
        await _dbHelper.insertComment(event.cafeId, userId, event.commentText);
        emit(CommentActionSuccess());
        add(FetchComments(event.cafeId));
      } else {
        emit(CommentError('User not logged in.'));
      }
    } catch (e) {
      emit(CommentError('Failed to add comment: $e'));
    }
  }

  Future<void> _onUpdateComment(
      EditComment event, Emitter<CommentState> emit) async {
    try {
      int? userId = await _getUserId();
      if (userId != null) {
        await _dbHelper.updateComment(event.commentId, event.newComment);

        // final comments = await _dbHelper.getCommentsByCafe(event.cafeId);
        emit(UpdateCommentSuccess());
      } else {
        emit(UpdateCommentFailure('User not logged in.'));
      }
    } catch (e) {
      emit(UpdateCommentFailure('Failed to update comment: $e'));
    }
  }

  Future<void> _onHideComment(
      HideComment event, Emitter<CommentState> emit) async {
    try {
      emit(CommentLoading());

      int? userId = await _getUserId();
      bool isAdmin = await _isAdmin();

      if (userId != null) {
        final comment = await _dbHelper.getCommentById(event.commentId);

        if (isAdmin || comment['userId'] == userId) {
          await _dbHelper.hideComment(event.commentId, userId);
          emit(CommentActionSuccess());
        } else {
          emit(
              CommentError('You do not have permission to hide this comment.'));
        }
      } else {
        emit(CommentError('User not logged in.'));
      }
    } catch (e) {
      emit(CommentError('Failed to hide comment: $e'));
    }
  }

  Future<void> _onFetchComments(
      FetchComments event, Emitter<CommentState> emit) async {
    try {
      emit(CommentLoading());
      List<Map<String, dynamic>> comments =
          await _dbHelper.getCommentsByCafe(event.cafeId);
      emit(CommentLoaded(comments));
    } catch (e) {
      emit(CommentError('Failed to load comments: $e'));
    }
  }
}
