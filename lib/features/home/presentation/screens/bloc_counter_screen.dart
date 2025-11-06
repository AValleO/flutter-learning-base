import 'package:flutter/material.dart';
import 'package:flutter_application_4/features/home/presentation/blocs/bloc/counter_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocCounterScreen extends StatelessWidget {
  const BlocCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: BlocCounterView(),
    );
  }
}

class BlocCounterView extends StatelessWidget {
  const BlocCounterView({super.key});

  void _increaseCounter(BuildContext context, {int value = 1}) {
    context.read<CounterBloc>().add(CounterIncremented(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: context.select(
          (CounterBloc bloc) =>
              Text('BLoC Transactions: ${bloc.state.transactionCount}'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Reset action
              context.read<CounterBloc>().add(CounterReset());
            },
          ),
        ],
      ),
      body: Center(
        child: context.select(
          (CounterBloc bloc) =>
              Text('BLoC Counter Value: ${bloc.state.counterValue}'),
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
              _increaseCounter(context, value: 3);
            },
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: '2',
            child: const Text('+2'),
            onPressed: () {
              // Increment action +2
              _increaseCounter(context, value: 2);
            },
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: '3',
            child: const Text('+1'),
            onPressed: () {
              // Increment action +1
              _increaseCounter(context);
            },
          ),
        ],
      ),
    );
  }
}
