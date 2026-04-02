import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ApiFailure extends Failure {
  const ApiFailure(super.message);
}

class JsonParsingFailure extends Failure {
  const JsonParsingFailure(super.message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}
