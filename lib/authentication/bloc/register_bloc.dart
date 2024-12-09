import 'dart:async';
import '../../utils/session_manager.dart';
import 'register_event.dart';
import 'register_state.dart';
import '../../utils/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterBloc {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final SessionManager sessionManager = SessionManager();

  final _stateController = StreamController<RegisterState>();

  Stream<RegisterState> get state => _stateController.stream;

  final _eventController = StreamController<RegisterEvent>();

  Sink<RegisterEvent> get event => _eventController.sink;

  RegisterBloc() {
    _eventController.stream.listen(_mapEventToState);
  }

  void _mapEventToState(RegisterEvent event) async {
    if (event is RegisterButtonPressed) {
      _stateController.add(RegisterLoading());

      try {
        final bool emailExists = await dbHelper.emailExists(event.email);

        if (emailExists) {
          _stateController.add(RegisterFailure('Email already exists!'));
        } else {
          await dbHelper.insertUser({
            'name': event.name,
            'email': event.email,
            'password': event.password,
            'isAdmin': 0,
          });
          await sessionManager.saveUserSession(event.email);
          _stateController.add(RegisterSuccess());
        }
      } catch (e) {
        _stateController.add(RegisterFailure('Register failed!'));
      }
    }
  }

  void dispose() {
    _stateController.close();
    _eventController.close();
  }
}
