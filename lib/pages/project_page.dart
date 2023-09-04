import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:project_management/models/project_model.dart';

import '../models/task_model.dart';
import '../pocketbase_options.dart';
import '../widgets/task_dialog.dart';

class ProjectPage extends StatefulWidget {

  const ProjectPage({Key? key}) : super(key: key);

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}
class _ProjectPageState extends State<ProjectPage> {

  final pb = PocketbaseGetter.pb;
  String _hoverTaskId = "";

  String _getBannerImage(RecordModel model) {
    if (model.data["banner"] == null || model.data["banner"] == "") {
      return "";
    }
    final name = model.data["banner"];
    return pb.getFileUrl(model, name).toString();
  }

  void _openAddTaskDialog(Project project,Task? task) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return TaskDialog(project: project, onRefresh:()=> {
          setState(() {}) //Reload on add/edit
        },task: task,);
      },
    );
  }

  void _updateTask(Task task) async {
    await pb.collection('tasks').update(task.recordId, body:task.toJson());
  }

  Future<List<Task>> getTasks(String projectId) async {
    //TODO for some reason expand is not working
    final List<Task> tasks = [];

    final resultList = await pb.collection('tasks').getList(
      page: 1,
      perPage: 50,
      filter: 'project = "$projectId" && hasFinished=false',
      sort: 'created',
    );
    for (RecordModel model in resultList.items) {
      final projectRecord = await pb.collection('projects').getOne(model.data["project"]);
      final project = Project.fromJson(projectRecord.data,_getBannerImage(projectRecord),projectRecord.id);
      tasks.add(Task.fromJson(model.data,model.id,project));
    }
    return tasks;
  }

  bool isDueToday(Task task) {
    final now = DateTime.now();
    final dueDate = task.todoDate;
    return dueDate.year == now.year && dueDate.month == now.month && dueDate.day == now.day;
  }

  List<Task> getTasksDueToday(List<Task> tasks) {
    return tasks.where((task) => isDueToday(task)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Project;
    return Scaffold(
      appBar: AppBar(
        title: Text(args.title),
        //actions for menu and adding members
        actions: [
          IconButton(
            tooltip: 'Add members',
            onPressed: () {},
            icon: const Icon(Icons.person_add_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>_openAddTaskDialog(args,null),
        tooltip: "Add task",
        //rounded shape
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0),
        ),
        //change hover color
        hoverColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          //list of tasks due today
          Expanded(
            child: FutureBuilder<List<Task>>( //I want it to update everytime
              future: getTasks(args.id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final tasks = snapshot.data!;
                  final tasksDueToday = getTasksDueToday(tasks);
                  return Column(
                    children: [
                      // Tasks due today
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Tasks due today',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: SingleChildScrollView(
                          child: Wrap(
                            children: List.generate(
                              tasksDueToday.length,
                                  (index) => buildTaskCard(tasksDueToday[index]),
                            ),
                          ),
                        ),
                      ),
                      // Unfinished tasks
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: Text(
                      //     'Unfinished tasks',
                      //     style: Theme.of(context).textTheme.headlineSmall,
                      //   ),
                      // ),
                      // Expanded(
                      //   flex: 1,
                      //   child: SingleChildScrollView(
                      //     child: Wrap(
                      //       children: List.generate(
                      //         tasks.length,
                      //             (index) => buildTaskCard(tasks[index]),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget buildTaskCard(Task task) {
    final width = MediaQuery.of(context).size.width > 720
        ? MediaQuery.of(context).size.width / 4
        : MediaQuery.of(context).size.width / 3;
    return SizedBox(
      width: width,
      height: width/1.5,
      child: Material(
        //rounded corners shape
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Colors.transparent,
        child: Padding(
          padding:const EdgeInsets.only(left: 16, right: 16, top: 4),
          child: MouseRegion(
            onEnter: (_) {
              setState(() {
                _hoverTaskId = task.recordId;
              });
            },
            onExit: (_) {
              setState(() {
                _hoverTaskId = "";
              });
            },
            child: Container(
              //add a border
              decoration: BoxDecoration(
                //shadow
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(16.0),
                //gradient
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                ),
                border: Border.all(
                  color: _hoverTaskId == task.recordId
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                  width: 2,
                ),
              ),
              child: Container(
                //a white background
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              task.taskName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Visibility(
                            visible: _hoverTaskId == task.recordId,
                            child: IconButton(
                              onPressed: () {
                                _openAddTaskDialog(task.project,task);
                              },
                              icon: const Icon(Icons.edit_outlined,size: 24,),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        task.taskDescription,
                        maxLines: MediaQuery.of(context).size.width > 900 ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Text(
                              "Due: ${task.todoDate.toIso8601String().split("T")[0]}",
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            const Spacer(),
                            Checkbox(
                              value: task.hasFinished,
                              onChanged: (value) {
                                if (value!) {
                                  setState(() {
                                    task.hasFinished = value;
                                  });
                                  _updateTask(task);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Can not uncheck a finished task"),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


}