
import 'package:dartz/dartz.dart';

import 'app_error.dart';
import 'response_wrap.dart';

abstract class UseCase<Output, Input> {
  Future<Either<AppError, ResponseWrap<Output>>> call(Input params);
}
