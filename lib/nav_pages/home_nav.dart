import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:project_management/models/project_model.dart';
import 'package:project_management/models/task_model.dart';
import 'package:project_management/pocketbase_options.dart';

class HomeNav extends StatefulWidget {
  const HomeNav({Key? key}) : super(key: key);

  @override
  State<HomeNav> createState() => _HomeNavState();
}
class _HomeNavState extends State<HomeNav> {

  final pb = PocketbaseGetter.pb;
  List<Project>? _projects;
  List<Task>? _tasks;

  String? getAvatarUrl() {
    if (pb.authStore.model.data["avatar"] == null) {
      return null;
    }
    final avatarName = pb.authStore.model.data["avatar"];
    return pb.getFileUrl(pb.authStore.model, avatarName).toString();
  }

  String _getBannerImage(RecordModel model) {
    if (model.data["banner"] == null || model.data["banner"] == "") {
      return "";
    }
    final name = model.data["banner"];
    return pb.getFileUrl(model, name).toString();
  }

  Future<List<Project>> getProjects() async {
    final resultList = await pb.collection('projects').getList(
      page: 1,
      perPage: 50,
      filter: 'creator = "${pb.authStore.model.id}"',
      sort: 'created',
    );
    return resultList.items.map((e) => Project.fromJson(e.data,_getBannerImage(e),e.id)).toList();
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

  void _updateTask(Task task) async {
    await pb.collection('tasks').update(task.recordId, body: task.toJson());
  }

  void _openAllProjects() {

  }

  void _openProject(Project project) {
    Navigator.of(context).pushNamed('/project',arguments: project);
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 720;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          //Padding so it doesn't collide with the sidebar
          padding: EdgeInsets.only(left: isDesktop? 96 : 0),
          child: Column(
            children: [
              buildGreeting(isDesktop, context),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Your Projects",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  TextButton(onPressed: _openAllProjects, child: const Text("See all")),
                ],
              ),
            ],
          ),
        ),
        //a list of all projects
        if (_projects == null) const Center(child: CircularProgressIndicator(),)
        else
        SizedBox(
          height: 175,
          width: double.infinity,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            // Only show 5 projects in home
            itemCount: _projects!.length>5? 5 : _projects!.length,
            shrinkWrap: true,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, index) {
              final project = _projects![index];
              return buildProject(project);
            }, separatorBuilder: (BuildContext context, int index) { return const SizedBox(width: 8,); },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
          child: Text("Your tasks",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        if (_tasks == null) const Center(child: CircularProgressIndicator(),)
        else
          if (isDesktop)
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: _tasks!.length,
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width>720
                      &&MediaQuery.of(context).size.width<980?2 : 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio:
                  MediaQuery.of(context).size.width>900?2 : 3,
                ),
                itemBuilder: (context, index) {
                  return buildTask(_tasks![index],isDesktop);
                },
              ),
            )
          else
            //Listview for the projects
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _tasks!.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  return buildTask(_tasks![index],isDesktop);
                },
              ),
            ),
      ],
    );
  }

  Widget buildTask(Task task,bool isDesktop) {
    return Card(
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
      elevation: 12,
      margin: EdgeInsets.only(left: isDesktop? 0 : 16, right: isDesktop? 0 : 16, top: 4),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              task.taskName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                task.taskDescription,
                maxLines: MediaQuery.of(context).size.width>900? 2 : 1,//Perfect sizing don't change
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
              child: Row(
                children: [
                  TextButton(
                    onPressed:()=> _openProject(task.project),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                          task.project.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                  Text(
                    "Due: ${task.todoDate.toIso8601String().split("T")[0]}",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
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
                        //Tell user that they cannot uncheck using scaffold message
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
    );
  }

  Widget buildProject(Project project) {
    //build a card showing information about the project
    return InkWell(
      onTap: () => _openProject(project),
      child: Container(
        width: 210,
        height: 150,
        //set the container background image
        decoration: BoxDecoration(
          image: project.bannerImage.isNotEmpty? DecorationImage(
            image: NetworkImage(project.bannerImage),
            fit: BoxFit.fill,
          ) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
          elevation: 12,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(project.title, style: Theme.of(context).textTheme.titleLarge,),
                const SizedBox(height: 8,),
                Text(project.description, maxLines: 5, overflow: TextOverflow.ellipsis,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGreeting(bool isDesktop, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 8, top: 12, right: 16, bottom: 12),
        child: Row(
          children: [
            Column(
              children: [
                Text("Hey, ${pb.authStore.model.data["name"]}",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text("Welcome back to your dashboard",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8,),
                if (_tasks!=null)
                  Text(
                    "You have ${_tasks?.length} tasks left for today",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16,),
            ProfilePicture(
              name: pb.authStore.model.data["name"],
              radius: isDesktop? 42 : 21, fontsize: 16,
              img: getAvatarUrl(),
            ),
          ],
        ),
      );
  }

  void onState() async {
    final projects = await getProjects();
    final List<Task> tasks = [];
    for (Project project in projects) {
      final projectTasks = await getTasks(project.id);
      tasks.addAll(projectTasks);
    }
    setState(() {
      _tasks = tasks;
      _projects = projects;
    });
  }

  @override
  void initState() {
    onState();
    super.initState();
  }

}