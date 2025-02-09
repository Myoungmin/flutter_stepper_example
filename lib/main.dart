import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StepperExample(),
    );
  }
}

class StepperExample extends StatefulWidget {
  const StepperExample({super.key});

  @override
  StepperExampleState createState() => StepperExampleState();
}

class StepperExampleState extends State<StepperExample> {
  int _currentStep = 5;
  int _totalSteps = 5;
  Timer? _timer;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _startAutoProgress() {
    if (_totalSteps <= 0) return;

    _timer?.cancel();
    setState(() {
      _currentStep = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentStep < _totalSteps) {
        setState(() {
          _currentStep++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stepper Example")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Step 개수 입력",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final int steps = int.tryParse(value) ?? 5;
                setState(() {
                  _totalSteps = steps;
                  _currentStep = _totalSteps;
                });
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _startAutoProgress,
              child: const Text("시작"),
            ),
            const SizedBox(height: 20),
            Expanded(
              key: UniqueKey(),
              child: _totalSteps > 0
                  ? Scrollbar(
                      thumbVisibility: true,
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _scrollController,
                        child: SizedBox(
                          width: (_totalSteps * 100.0)
                              .clamp(300.0, double.infinity),
                          child: Stepper(
                            type: StepperType.horizontal,
                            currentStep: _currentStep.clamp(0, _totalSteps - 1),
                            steps: List.generate(
                              _totalSteps,
                              (index) => Step(
                                isActive: _currentStep >= index,
                                state: _currentStep - 1 >= index
                                    ? StepState.complete
                                    : StepState.indexed,
                                title: Text("Step ${index + 1}"),
                                content: Center(
                                    child: Text(_currentStep == _totalSteps
                                        ? "완료됨"
                                        : "${index + 1} 번째 단계")),
                              ),
                            ),
                            controlsBuilder: (context, details) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    )
                  : const Center(child: Text("Step 개수를 입력하세요")),
            ),
          ],
        ),
      ),
    );
  }
}
