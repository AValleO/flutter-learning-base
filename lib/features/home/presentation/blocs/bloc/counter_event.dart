part of 'counter_bloc.dart';

sealed class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object> get props => [];
}

class CounterIncremented extends CounterEvent {
  final int value;

  const CounterIncremented(this.value);

  @override
  List<Object> get props => [value];
}

class CounterReset extends CounterEvent {}
