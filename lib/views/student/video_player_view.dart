import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoPlayerView extends StatefulWidget {
  final String title;
  final String videoUrl;
  final String description;
  final int duration;
  final String courseTitle;

  const VideoPlayerView({
    super.key,
    required this.title,
    required this.videoUrl,
    required this.description,
    required this.duration,
    required this.courseTitle,
  });

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  bool isPlaying = false;
  double progress = 0.0;
  bool hasNotes = false;
  final notesController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> _launchVideo() async {
    final Uri url = Uri.parse(widget.videoUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      setState(() {
        isPlaying = true;
        progress = 0.1; // Mark as started
      });
    } else {
      Get.snackbar(
        'Error',
        'Could not open video',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade600, Colors.deepOrange.shade400],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              Get.snackbar('Bookmarked', 'Video saved to your bookmarks');
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Get.snackbar('Share', 'Share functionality');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Player Section
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.grey.shade900],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Play button overlay
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade600,
                              Colors.deepOrange.shade400,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.5),
                              spreadRadius: 5,
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.play_arrow, size: 50),
                          color: Colors.white,
                          onPressed: _launchVideo,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.duration} min',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Video type badge
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.play_circle,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Video',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress Bar
            if (progress > 0)
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.orange.shade600,
                ),
              ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Title
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.courseTitle,
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Video Title
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _launchVideo,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Watch on YouTube'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            progress = 1.0;
                          });
                          Get.snackbar(
                            'Completed',
                            'Video marked as completed',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Complete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Notes Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.note_alt,
                                color: Colors.orange.shade600,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'My Notes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: notesController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Write your notes here...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            onChanged: (value) {
                              setState(() {
                                hasNotes = value.isNotEmpty;
                              });
                            },
                          ),
                          if (hasNotes) ...[
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                Get.snackbar(
                                  'Saved',
                                  'Notes saved successfully',
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              },
                              icon: const Icon(Icons.save),
                              label: const Text('Save Notes'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade600,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
