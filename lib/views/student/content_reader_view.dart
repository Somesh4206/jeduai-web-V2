import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContentReaderView extends StatefulWidget {
  final String title;
  final String courseTitle;
  final String content;
  final int duration;
  final String type; // 'Reading' or 'Article'

  const ContentReaderView({
    super.key,
    required this.title,
    required this.courseTitle,
    required this.content,
    required this.duration,
    required this.type,
  });

  @override
  State<ContentReaderView> createState() => _ContentReaderViewState();
}

class _ContentReaderViewState extends State<ContentReaderView> {
  double fontSize = 16.0;
  bool isDarkMode = false;
  double progress = 0.0;
  final scrollController = ScrollController();
  bool showFloatingButton = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.hasClients) {
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.position.pixels;
      setState(() {
        progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
        showFloatingButton = currentScroll > 200;
      });
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.cyan.shade400],
            ),
          ),
        ),
        actions: [
          // Font size controls
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: () {
              setState(() {
                if (fontSize > 12) fontSize -= 2;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: () {
              setState(() {
                if (fontSize < 24) fontSize += 2;
              });
            },
          ),
          // Dark mode toggle
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
          // Bookmark
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              Get.snackbar('Bookmarked', 'Content saved to your bookmarks');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.type == 'Reading'
                              ? Icons.menu_book
                              : Icons.article,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.courseTitle,
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Reading time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.duration} min read',
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Medium',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Content
                  Text(
                    widget.content,
                    style: TextStyle(
                      fontSize: fontSize,
                      height: 1.8,
                      color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Completion Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.snackbar(
                          'Completed',
                          'Content marked as completed',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Mark as Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: showFloatingButton
          ? FloatingActionButton(
              onPressed: () {
                scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              backgroundColor: Colors.blue.shade600,
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }
}
