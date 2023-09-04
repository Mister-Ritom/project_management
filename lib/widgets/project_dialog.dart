import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_management/pocketbase_options.dart';

class CreateProjectDialog extends StatefulWidget {
  const CreateProjectDialog({super.key});

  @override
  State<StatefulWidget> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<String> membersId = <String>[];
  Uint8List? _bannerImage;

  Future<void> _pickBannerImage() async {
    // Pick image using image_picker
    ImagePicker picker = ImagePicker();
    final xFile  = await picker.pickImage(source: ImageSource.gallery);
    if (xFile!=null) {
      final file = _bannerImage = await xFile.readAsBytes();
      setState(() {
        _bannerImage = file;
      });
    }
  }
  bool _startsWith(Uint8List data, Uint8List prefix) {
    if (data.length < prefix.length) {
      return false;
    }
    for (var i = 0; i < prefix.length; i++) {
      if (data[i] != prefix[i]) {
        return false;
      }
    }
    return true;
  }
  String getImageFormat(Uint8List data) {
    // Define magic numbers or headers for each format
    final pngMagic = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]);
    final jpegMagic = Uint8List.fromList([255, 216]);
    final webpMagic = Uint8List.fromList([82, 73, 70, 70]);

    // Check if the data matches any of the magic numbers
    if (_startsWith(data, pngMagic)) {
      return "png";
    } else if (_startsWith(data, jpegMagic)) {
      return "jpg";
    } else if (_startsWith(data, webpMagic)) {
      return "webp";
    } else {
      return "unknown";
    }
  }

  void _createProject(String title,String description) async {
    try  {
      final pb = PocketbaseGetter.pb;
      final body = <String, dynamic>{
        "title": title,
        "description": description,
        "creator": pb.authStore.model!.id,
      };
      await pb.collection('projects').create(
          body: body,
          files: [
            if (_bannerImage != null)
              http.MultipartFile.fromBytes("banner", _bannerImage!,filename: "banner.${getImageFormat(_bannerImage!)}"),
        ],
      );
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

  Widget _getBannerButton() {
    if (_bannerImage!=null) {
      return InkWell(
        onTap: _pickBannerImage,
        child: Container(
          padding: const EdgeInsets.all(12.0),
            //rounded borders
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Image.memory(_bannerImage!,width: 96,height: 96,),
        )
      );
    }
    else {
      //IconButton for adding banner image to the project
      return  IconButton(
        icon: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Icon(Icons.add_a_photo_outlined,size: 64,),
        ),
        onPressed: _pickBannerImage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: size.width>720?size.width*0.6:size.width*0.8,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              //get the appropriate button
              _getBannerButton(),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
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
              //Textfield for adding members separated by comma
              TextField(
                decoration: const InputDecoration(
                  labelText: "Members",
                  //border on all sides
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  membersId = value.split(",");
                },
              ),
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

                      // Validate and handle project creation
                      if (title.isNotEmpty) {
                        _createProject(title,description);
                      } else {
                        // Show an error message if the title is empty
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Title cannot be empty"),
                          ),
                        );
                      }
                    },
                    child: const Text("Add"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

}