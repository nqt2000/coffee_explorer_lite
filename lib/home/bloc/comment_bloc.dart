import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/database_helper.dart';
import '../../utils/session_manager.dart';
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

  Future<int?> _getUserId() async {
    SessionManager sessionManager = SessionManager();
    Map<String, dynamic>? userInfo = await sessionManager.getUserInfo();
    return userInfo?['id'];
  }

  Future<void> _onAddComment(AddComment event, Emitter<CommentState> emit) async {
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

  Future<void> _onDeleteComment(DeleteComment event, Emitter<CommentState> emit) async {
    try {
      emit(CommentLoading());

      int? userId = await _getUserId();
      if (userId != null) {
        await _dbHelper.deleteComment(event.commentId, userId);
        emit(CommentActionSuccess());
      } else {
        emit(CommentError('User not logged in.'));
      }
    } catch (e) {
      emit(CommentError('Failed to delete comment: $e'));
    }
  }

  Future<void> _onUpdateComment(UpdateComment event, Emitter<CommentState> emit) async {
    try {
      emit(CommentLoading());

      int? userId = await _getUserId();
      if (userId != null) {
        await _dbHelper.updateComment(event.commentId, event.newText, userId);
        emit(CommentActionSuccess());
      } else {
        emit(CommentError('User not logged in.'));
      }
    } catch (e) {
      emit(CommentError('Failed to update comment: $e'));
    }
  }

  Future<void> _onHideComment(HideComment event, Emitter<CommentState> emit) async {
    try {
      emit(CommentLoading());

      int? userId = await _getUserId();
      if (userId != null) {
        await _dbHelper.hideComment(event.commentId, userId);
        emit(CommentActionSuccess());
      } else {
        emit(CommentError('User not logged in.'));
      }
    } catch (e) {
      emit(CommentError('Failed to hide comment: $e'));
    }
  }

  Future<void> _onFetchComments(FetchComments event, Emitter<CommentState> emit) async {
    try {
      emit(CommentLoading());
      List<Map<String, dynamic>> comments = await _dbHelper.getCommentsByCafe(event.cafeId);
      emit(CommentLoaded(comments));
    } catch (e) {
      emit(CommentError('Failed to load comments: $e'));
    }
  }
}
