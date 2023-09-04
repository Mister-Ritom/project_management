import 'dart:typed_data';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_management/models/project_model.dart';
import 'package:project_management/pocketbase_options.dart';

import '../models/task_model.dart';

class TaskDialog extends StatefulWidget {
  final Project project;
  final Task? task;
  final VoidCallback onRefresh;
  const TaskDialog({super.key, required this.project,
    required this.onRefresh, this.task});

  @override
  State<StatefulWidget> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    if (widget.task!=null) {
      _titleController.text = widget.task!.taskName;
      _descriptionController.text = widget.task!.taskDescription;
      _dateController.text = widget.task!.todoDate.toIso8601String();
    }
    super.initState();
  }

  void _createTask(String title,String description,String date) async {
    try  {
      final pb = PocketbaseGetter.pb;
      final task = Task(
          recordId: '',
          taskName: title,
          taskDescription: description,
          todoDate: DateTime.parse(date),
          hasFinished: false,
          project: widget.project,
      );
       await pb.collection('tasks').create(body: task.toJson());
       widget.onRefresh();
      if (context.mounted) {
        Navigator.of(context).pop(); // Close the dialog
      }
    }
    catch(e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong"),
          ),
        );
      }
    }
  }

  void _editTask(String title,String description,String date) async {
    try  {
      final pb = PocketbaseGetter.pb;
      final task = Task(
        recordId: widget.task?.recordId??'',
        taskName: title,
        taskDescription: description,
        todoDate: DateTime.parse(date),
        hasFinished: false,
        project: widget.project,
      );
      await pb.collection('tasks').update(task.recordId, body: task.toJson());
      widget.onRefresh();
      if (context.mounted) {
        Navigator.of(context).pop(); // Close the dialog
      }
    }
    catch(e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    //return a task adding dialog with name,description,date
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            width: size.width>720?size.width*0.6:size.width*0.8,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  //add a border
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${widget.task==null? "Add" : "Edit"} task to ${widget.project.title}",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    )
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    //border on all sides
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    //border on all sides
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.calendar_today),
                        labelText: "Due Date",
                        border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          //get today's date
                          firstDate: DateTime.now(),
                          //DateTime.now() - not to allow to choose before today.
                          lastDate: DateTime(2101)
                      );
                      if (pickedDate != null) {
                        //pickedDate = pickedDate;
                        String formattedDate = pickedDate.toIso8601String();
                        _dateController.text = formattedDate;
                      }
                    }
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        // Add button logic here
                        String title = _titleController.text;
                        String description = _descriptionController.text;
                        String date = _dateController.text;

                        // Validate and handle project creation
                        if (title.isNotEmpty&&date.isNotEmpty) {
                          if (widget.task!=null)
                            _editTask(title,description,date);
                          else _createTask(title,description,date);
                        } else {
                          // Show an error message if the title is empty
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Title and date cannot be empty"),
                            ),
                          );
                        }
                      },
                      child: Text(widget.task==null? "Add" : "Edit"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

}