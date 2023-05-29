import 'package:cleanarch/core/Usecases/usecase.dart';
import 'package:cleanarch/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:cleanarch/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:cleanarch/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'get_concrete_number_trivia_test.mocks.dart';

@GenerateMocks([NumberTriviaRepository])
void main() async {
  late GetRandomNumberTrivia usecase;
  late MockNumberTriviaRepository mockNumberTriviaRepository;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetRandomNumberTrivia(mockNumberTriviaRepository);
  });

  const tNumber = 1;
  const tNumberTrivia = NumberTrivia(text: 'test', number: tNumber);

  test('should get trivia entity for number from repo', () async {
    when(mockNumberTriviaRepository.getRandomNumberTrivia())
        .thenAnswer((_) async => const Right(tNumberTrivia));

    final result = await usecase(NoParams());

    expect(result, const Right(tNumberTrivia));

    verify(mockNumberTriviaRepository.getRandomNumberTrivia());

    verifyNoMoreInteractions(mockNumberTriviaRepository);
  });
}
