import 'package:flutter/material.dart';

class Client2DViewPage extends StatelessWidget {
  const Client2DViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final projectId = args["projectId"] as String;

    // ⚠️ Manually listed images (no DB, no dynamic listing)
    final List<String> images = [
      'assets/models/test.jpeg',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("2D View")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              images[index],
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
