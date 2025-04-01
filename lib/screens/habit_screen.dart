import 'package:flutter/material.dart';
import 'package:habit_tracker/model/habit_model.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:provider/provider.dart';

class HabitScreen extends StatefulWidget {
  const HabitScreen({super.key});

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  bool isSelectionMode = false; // Track selection mode
  List<bool> selectedItems = [];


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      habitProvider.loadHabits().then((_) {
        // Initialize selectedItems after loading habits
        setState(() {
          selectedItems = List.generate(habitProvider.habits.length, (index) => false);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print('selectedItems length: ${selectedItems.length}');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: isSelectionMode
            ? Row(
          children: [
          IconButton( onPressed: (){
            setState(() {
              isSelectionMode = false;
              selectedItems = List.generate(
                  context.read<HabitProvider>().habits.length, (index) => false
              );
            });
          }, icon: Icon(Icons.close), key: Key('closeButton'),),
        ],
        )
            : const Text('Habit Tracker'),
        backgroundColor: Colors.purple.shade50,
        actions: [
          if (isSelectionMode)
            Row(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(
                        '${selectedItems.where((item) => item).length} selected', // Display number of selected items
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        // Delete selected habits
                        context.read<HabitProvider>().deleteSelectedHabits(selectedItems);
                        setState(() {
                          isSelectionMode = false; // Exit selection mode after delete
                          selectedItems = List.generate(
                            context.read<HabitProvider>().habits.length,
                                (index) => false,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),

        ],
      ),
      body: Consumer<HabitProvider>(
        builder: (context, hProvider, child) {
          if (hProvider.habits.isEmpty) {
            return const Center(child: Text('No habits found'));
          }
          double progress =
              hProvider.habits.where((habit) => habit.isCompleted).length /
              hProvider.habits.length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      """Progress: ${(progress * 100).toStringAsFixed(2)}%""",
                    ),
                    SizedBox.square(dimension: 10),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      color: Colors.purple,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: hProvider.habits.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (isSelectionMode) {
                          setState(() {
                            selectedItems[index] = !selectedItems[index];
                          });

                          if (!selectedItems.any((item) => item)) {
                            setState(() {
                              isSelectionMode = false;
                            });
                          }
                        } else {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            // To control the height of the sheet
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) {
                              return DraggableScrollableSheet(
                                initialChildSize: 0.35,
                                // Initial size when the sheet opens
                                minChildSize: 0.2,
                                // Minimum height
                                maxChildSize: 1.0,
                                // Maximum height
                                expand: false,
                                // Don't expand content automatically
                                builder: (context, scrollController) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 20,
                                    ),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    child: SingleChildScrollView(
                                      // Ensure content is scrollable
                                      controller: scrollController,
                                      child: Column(
                                        children: [
                                          // Default draggable handle
                                          Container(
                                            width: 40,
                                            height: 5,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[400],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              hProvider.habits[index].title,
                                              style: TextStyle(fontSize: 18),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }
                      },
                      onLongPress: () {
                        setState(() {
                          if (!isSelectionMode) {
                            isSelectionMode = true;
                            selectedItems = List.generate(
                              hProvider.habits.length,
                                  (index) => false,
                            );
                          }
                          selectedItems[index] = !selectedItems[index];
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(

                          color: selectedItems[index]  ? Colors.purple.shade100 : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [ ListTile(
                            leading: Checkbox(
                              value: hProvider.habits[index].isCompleted,
                              onChanged: isSelectionMode
                                ? null
                                  :(value) {
                                hProvider.toggleHabit(
                                  hProvider.habits[index].id!,
                                );
                              },
                            ),
                            title: Text(
                              hProvider.habits[index].title,
                              maxLines: 1,
                              style: TextStyle(
                                decoration:
                                    hProvider.habits[index].isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: isSelectionMode
                                      ? null
                                      :() {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Delete Habit'),
                                          content: const Text(
                                            'Are you sure you want to delete this habit?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed:() {
                                                hProvider.deleteHabit(
                                                  hProvider.habits[index].id!,
                                                );
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.delete),
                                ),
                                IconButton(
                                  onPressed: isSelectionMode
                                      ? null
                                      :() {
                                    if (hProvider.habits[index].isCompleted ==
                                        true) {
                                      null;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Habit is already completed',
                                          ),
                                        ),
                                      );
                                    } else {
                                      _showAddHabitDialog(
                                        context,
                                        habitM: hProvider.habits[index],
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.edit),
                                ),
                              ],
                            ),
                          ),
                            // if (selectedItems[index])
                            //   Positioned(
                            //     left: 5,
                            //     top: 5,
                            //     bottom: 5,
                            //     child: Icon(
                            //       Icons.check_circle,
                            //       color: Colors.purple, // Green color for checkmark
                            //       size: 24, // Adjust size if needed
                            //     ),
                            //   ),
                        ],
                    ),
                      ),
                    );

                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: isSelectionMode
          ?null
          : (){
          _showAddHabitDialog(context);
        }

      ),
    );
  }

  void _showAddHabitDialog(BuildContext context, {HabitModel? habitM}) {
    final TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        if (habitM != null) {
          _controller.text = habitM.title;
        }

        return AlertDialog(
          title: Text(habitM == null ? 'Add Habit' : 'Update Habit'),
          content: TextField(controller: _controller),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(habitM == null ? 'Add' : 'Update'),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  if (habitM == null) {
                    // Add new habit
                    context.read<HabitProvider>().addHabit(_controller.text);
                    setState(() {
                      selectedItems.add(false); // Add a new false entry for the new habit
                    });
                  } else {
                    // Update existing habit
                    context.read<HabitProvider>().updateHabitTitle(
                      habitM.id ?? 0,
                      _controller.text,
                    );
                  }
                  Navigator.pop(context);
                  _controller.clear();
                } else {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Please enter a title'),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
