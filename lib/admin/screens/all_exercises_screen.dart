import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class AllExercisesScreen extends StatefulWidget {
  const AllExercisesScreen({super.key});

  @override
  State<AllExercisesScreen> createState() => _AllExercisesScreenState();
}

class _AllExercisesScreenState extends State<AllExercisesScreen> {
  List<Map<String, dynamic>> exercises = [];
  String? playingVideoPath;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('exercises').get();
      exercises = snapshot.docs.map((doc) => doc.data()).toList();
      setState(() => isLoading = false);
    } catch (e) {
      print('❌ Error fetching exercises: $e');
    }
  }

  Future<void> playVideo(String videoPath) async {
    try {
      final videoUrl = await FirebaseStorage.instance.ref(videoPath).getDownloadURL();
      _videoController?.dispose();
      _chewieController?.dispose();

      _videoController = VideoPlayerController.network(videoUrl);
      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
      );

      setState(() {
        playingVideoPath = videoPath;
      });
    } catch (e) {
      print('❌ Error loading video: $e');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5F8FA),
      appBar: AppBar(
        title: const Text("All Exercises"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Exercise Library", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: ListView.separated(
                        itemCount: exercises.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final exercise = exercises[index];
                          return ListTile(
                            title: Text(exercise['name'] ?? 'Unknown'),
                            trailing: const Icon(Icons.play_circle, color: Color(0xFF14abc2)),
                            onTap: () => playVideo(exercise['videoPath']),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_chewieController != null && playingVideoPath != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Now Playing", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 200,
                            child: Chewie(controller: _chewieController!),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
