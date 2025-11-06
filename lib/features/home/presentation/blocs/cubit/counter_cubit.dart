import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'counter_state.dart';

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterState(counterValue: 0, transactionCount: 0));

  void increaseBy(int value) {
    emit(state.copyWith(
      counterValue: state.counterValue + value,
      transactionCount: state.transactionCount + 1,
    ));
  }

  void reset(){
    emit(state.copyWith(
      counterValue: 0,
      transactionCount: state.transactionCount + 1,
    ));
  }
}
