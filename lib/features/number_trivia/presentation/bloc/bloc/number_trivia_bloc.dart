import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/Error/failures.dart';
import '../../../../../core/Usecases/usecase.dart';
import '../../../../../core/util/input_converter.dart';
import '../../../domain/entities/number_trivia.dart';
import '../../../domain/usecases/get_concrete_number_trivia.dart';
import '../../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Cubit<NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required GetConcreteNumberTrivia concrete,
    required GetRandomNumberTrivia random,
    required this.inputConverter,
  })  : getConcreteNumberTrivia = concrete,
        getRandomNumberTrivia = random,
        super(NumberTriviaInitial());

  Future<void> getTriviaForConcreteNumber(String numberString) async {
    final inputEither = inputConverter.stringToUnsignedInteger(numberString);
    await inputEither.fold((failure) {
      emit(Error(message: INVALID_INPUT_FAILURE_MESSAGE));
    }, (integer) async {
      emit(Loading());
      final failureOrTrivia =
          await getConcreteNumberTrivia(Params(number: integer));
      failureOrTrivia.fold((failure) {
        emit(Error(message: _mapFailureToMessage(failure)));
      }, (trivia) {
        emit(Loaded(trivia: trivia));
      });
    });
  }

  Future<void> getTriviaForRandomNumber() async {
    emit(Loading());
    final failureOrTrivia = await getRandomNumberTrivia(NoParams());
    failureOrTrivia.fold((failure) {
      emit(Error(message: _mapFailureToMessage(failure)));
    }, (trivia) {
      emit(Loaded(trivia: trivia));
    });
  }
}

String _mapFailureToMessage(Failure failure) {
  switch (failure.runtimeType) {
    case ServerFailure:
      return SERVER_FAILURE_MESSAGE;
    case CacheFailure:
      return CACHE_FAILURE_MESSAGE;
    default:
      return 'Unexpected Error';
  }
}
