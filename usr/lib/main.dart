import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const NumberTrackerScreen(),
      },
    );
  }
}

class NumberTrackerScreen extends StatefulWidget {
  const NumberTrackerScreen({super.key});

  @override
  State<NumberTrackerScreen> createState() => _NumberTrackerScreenState();
}

class _NumberTrackerScreenState extends State<NumberTrackerScreen> {
  final List<double> _trackedNumbers = [];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _addNumber() {
    final String input = _controller.text.trim();
    
    if (input.isEmpty) return;

    // Check for "quit" equivalent or just parse number
    if (input.toLowerCase() == 'quit') {
      // In a GUI, "quit" might just mean clearing focus or showing a dialog, 
      // but here we'll just clear the field as the list is always visible.
      _controller.clear();
      FocusScope.of(context).unfocus();
      return;
    }

    final double? number = double.tryParse(input);

    if (number != null) {
      setState(() {
        _trackedNumbers.add(number);
      });
      _controller.clear();
      // Keep focus on the text field for rapid entry
      _focusNode.requestFocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid input. Please enter a valid number.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _resetTracker() {
    setState(() {
      _trackedNumbers.clear();
      _controller.clear();
    });
  }

  double get _totalSum {
    if (_trackedNumbers.isEmpty) return 0;
    return _trackedNumbers.reduce((a, b) => a + b);
  }

  double get _average {
    if (_trackedNumbers.isEmpty) return 0;
    return _totalSum / _trackedNumbers.length;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Number Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: _resetTracker,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Enter a number',
                      hintText: 'e.g. 42.5',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onSubmitted: (_) => _addNumber(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _addNumber,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Statistics Section
            Card(
              elevation: 2,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: 'Count',
                          value: '${_trackedNumbers.length}',
                        ),
                        _StatItem(
                          label: 'Sum',
                          value: _totalSum.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), ""),
                        ),
                        _StatItem(
                          label: 'Average',
                          value: _average.toStringAsFixed(2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Tracked Numbers:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // List Section
            Expanded(
              child: _trackedNumbers.isEmpty
                  ? Center(
                      child: Text(
                        'No numbers tracked yet.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _trackedNumbers.length,
                      itemBuilder: (context, index) {
                        // Display in reverse order (newest first) usually looks better for logs,
                        // but the python script implies a sequential list. Let's stick to insertion order.
                        // Actually, let's show index + 1 to match the Python "enumerate(..., start=1)"
                        final number = _trackedNumbers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${index + 1}'),
                            ),
                            title: Text(
                              number.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), ""),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _trackedNumbers.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
