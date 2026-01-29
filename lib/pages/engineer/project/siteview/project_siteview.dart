import 'package:flutter/material.dart';

class ProjectSiteViewPage extends StatelessWidget {
  final String projectId;
  final String projectName;

  const ProjectSiteViewPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "SiteView\nProject: $projectName\nID: $projectId",
        textAlign: TextAlign.center,
      ),
    );
  }
}
