class Project {
  final String id;
  final String title;
  final String description;
  final String bannerImage;
  final String creatorId; // Store the ID of the creator
  final List<String> memberIds; // Store only member IDs

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.bannerImage,
    required this.creatorId,
    required this.memberIds,
  });

  // Create a factory method to deserialize JSON data into a Project object
  factory Project.fromJson(Map<String, dynamic> json, String image,String id) {
    //These are optional fields
    final desc = json.containsKey("description") ? json['description'] : "";
    final mbs = json.containsKey("members") ? List<String>.from(json['members']) : [];
    return Project(
      id: id,
      title: json['title'],
      description: desc,
      bannerImage: image,
      creatorId: json['creator'],
      memberIds: mbs as List<String>,
    );
  }
  //
  // // Convert a Project object to a JSON map
  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'title': title,
  //     'description': description,
  //     'bannerImage': bannerImage,
  //     'creator': creatorId,
  //     'members': memberIds,
  //   };
  // }
}
