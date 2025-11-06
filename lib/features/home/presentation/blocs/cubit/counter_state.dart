part of 'counter_cubit.dart';

class CounterState extends Equatable {
  
  final int counterValue;
  final int transactionCount;

  const CounterState({
    required this.counterValue,
    required this.transactionCount,
  });

  CounterState copyWith({
    int? counterValue,
    int? transactionCount,
  }) {
    return CounterState(
      counterValue: counterValue ?? this.counterValue,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }

  @override
  List<Object?> get props => [counterValue, transactionCount];
}
