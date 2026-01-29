import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Client3DViewPage extends StatelessWidget {
  const Client3DViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final projectId = args["projectId"] as String;
    final modelPath = 'assets/models/test.glb';

    return Scaffold(
      appBar: AppBar(title: const Text("3D View")),
      body: ModelViewer(
        src: modelPath,
        autoRotate: true,
        cameraControls: true,
        backgroundColor: Colors.white,
      ),
    );
  }
}
