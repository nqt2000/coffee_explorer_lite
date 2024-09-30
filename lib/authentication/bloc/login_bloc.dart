import 'dart:async';
import 'login_event.dart';
import 'login_state.dart';
import '../../utils/session_manager.dart';
import '../../utils/database_helper.dart';

class LoginBloc {
  final SessionManager sessionManager = SessionManager();
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  // Controllers for managing state and events
  final _stateController = StreamController<LoginState>();
  Stream<LoginState> get state => _stateController.stream;

  final _eventController = StreamController<LoginEvent>();
  Sink<LoginEvent> get event => _eventController.sink;

  LoginBloc() {
    _eventController.stream.listen(_mapEventToState);
  }

  void _mapEventToState(LoginEvent event) async {
    if (event is LoginButtonPressed) {
      _stateController.add(LoginLoading());

      try {
        var user = await dbHelper.queryUser(event.email, event.password);
        if (user != null) {
          await sessionManager.saveUserSession(event.email);
          _stateController.add(LoginSuccess());
        } else {
          _stateController.add(LoginFailure('Email hoặc mật khẩu không đúng'));
        }
      } catch (e) {
        _stateController.add(LoginFailure('Đăng nhập thất bại'));
      }
    }
  }

  void dispose() {
    _stateController.close();
    _eventController.close();
  }
}
