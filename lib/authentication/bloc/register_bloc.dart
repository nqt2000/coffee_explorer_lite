import 'dart:async';
import 'register_event.dart';
import 'register_state.dart';
import '../../utils/database_helper.dart';

class RegisterBloc {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

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
        // Kiểm tra xem email đã tồn tại chưa
        final bool emailExists = await dbHelper.emailExists(event.email);

        if (emailExists) {
          // Nếu email đã tồn tại, báo lỗi
          _stateController.add(RegisterFailure('Email already exists!'));
        } else {
          // Nếu email chưa tồn tại, thực hiện đăng ký
          await dbHelper.insertUser({
            'name': event.name,
            'email': event.email,
            'password': event.password,
            'isAdmin': 0, // Mặc định khi đăng ký user không phải admin
          });
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
