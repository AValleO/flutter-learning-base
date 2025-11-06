import 'package:flutter/material.dart';
import 'package:flutter_application_4/features/home/presentation/blocs/cubit/counter_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CubitCounterScreen extends StatelessWidget {
  const CubitCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterCubit(),
      child: _CubitCounterView(),
    );
  }
}

class _CubitCounterView extends StatelessWidget {
  const _CubitCounterView();

  @override
  Widget build(BuildContext context) {
    final counterCubit = context.read<CounterCubit>();

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<CounterCubit, CounterState>(
          builder: (context, state) {
            return Text('Cubit Counter: ${state.transactionCount} Transactions');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Reset action
              counterCubit.reset();
            },
          ),
        ],
      ),
      body: Center(
        child: BlocBuilder<CounterCubit, CounterState>(
          buildWhen: (previous, current) =>
              previous.counterValue != current.counterValue,
          builder: (context, state) {
            return Text('Counter Value: ${state.counterValue}');
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: '1',
            child: const Text('+3'),
            onPressed: () {
              // Increment action +3
              counterCubit.increaseBy(3);
            },
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: '2',
            child: const Text('+2'),
            onPressed: () {
              // Increment action +2
              counterCubit.increaseBy(2);
            },
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: '3',
            child: const Text('+1'),
            onPressed: () {
              // Increment action +1
              counterCubit.increaseBy(1);
            },
          ),
        ],
      ),
    );
  }
}
