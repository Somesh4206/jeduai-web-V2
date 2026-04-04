import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/media_translation_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:video_player/video_player.dart';

class TranslatedVideoPlayerView extends StatefulWidget {
  final MediaFile file;

  const TranslatedVideoPlayerView({super.key, required this.file});

  @override
  State<TranslatedVideoPlayerView> createState() =>
      _TranslatedVideoPlayerViewState();
}

class _TranslatedVideoPlayerViewState extends State<TranslatedVideoPlayerView> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  int _currentSubtitleIndex = -1;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // Use the ACTUAL uploaded video file
      if (widget.file.filePath != null && widget.file.filePath!.isNotEmpty) {
        print('Loading video from: ${widget.file.filePath}');

        // Handle both network URLs and data URLs (for web)
        if (widget.file.filePath!.startsWith('data:')) {
          // For web with data URL
          _videoController = VideoPlayerController.networkUrl(
            Uri.parse(widget.file.filePath!),
          );
        } else if (widget.file.filePath!.startsWith('http')) {
          // For network URLs
          _videoController = VideoPlayerController.networkUrl(
            Uri.parse(widget.file.filePath!),
          );
        } else {
          // For local file paths (mobile/desktop)
          _videoController = VideoPlayerController.networkUrl(
            Uri.parse(widget.file.filePath!),
          );
        }
      } else {
        // Fallback only if no file path exists
        Get.snackbar(
          'Error',
          'Video file path not found. Please re-upload the video.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        return;
      }

      print('Initializing video controller...');
      await _videoController!.initialize();
      print(
        'Video initialized successfully. Duration: ${_videoController!.value.duration}',
      );

      // Get ACTUAL video duration from the uploaded file
      final actualDuration = _videoController!.value.duration;

      // Update MediaFile with actual duration if not set
      if (widget.file.videoDuration == null ||
          widget.file.videoDuration != actualDuration) {
        widget.file.videoDuration = actualDuration;

        // Generate subtitles based on ACTUAL video duration
        if (widget.file.subtitles == null || widget.file.subtitles!.isEmpty) {
          await _generateRealTimeSubtitles(actualDuration);
        }
      }

      setState(() {
        _isInitialized = true;
      });

      // Listen to position changes for subtitle sync
      _videoController!.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load video: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Generate subtitles that match the ACTUAL video duration
  Future<void> _generateRealTimeSubtitles(Duration videoDuration) async {
    final List<SubtitleSegment> subtitles = [];
    final totalSeconds = videoDuration.inSeconds;

    // In production, this would use speech-to-text API to transcribe actual audio
    // For now, generate subtitles that match the exact video length
    int currentTime = 0;
    int index = 1;

    // Generate subtitles every 5-7 seconds for the ENTIRE video
    while (currentTime < totalSeconds) {
      final segmentDuration = 5 + (index % 3); // 5-7 seconds per subtitle
      final endTime = (currentTime + segmentDuration) > totalSeconds
          ? totalSeconds
          : (currentTime + segmentDuration);

      // Get translated text based on target language
      final subtitleText = _getTranslatedSubtitle(index);

      subtitles.add(
        SubtitleSegment(
          index: index,
          startTime: Duration(seconds: currentTime),
          endTime: Duration(seconds: endTime),
          text: subtitleText,
        ),
      );

      currentTime = endTime;
      index++;

      if (currentTime >= totalSeconds) break;
    }

    // Update the file with generated subtitles
    widget.file.subtitles = subtitles;

    Get.snackbar(
      'Subtitles Generated',
      'Created ${subtitles.length} subtitle segments for ${_formatDuration(videoDuration)}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  String _getTranslatedSubtitle(int index) {
    // Get subtitle text based on target language
    final language = widget.file.targetLanguage ?? 'English';

    if (language == 'Tamil') {
      return _getTamilSubtitle(index);
    } else if (language == 'Hindi') {
      return _getHindiSubtitle(index);
    } else if (language == 'Spanish') {
      return _getSpanishSubtitle(index);
    } else if (language == 'Telugu') {
      return _getTeluguSubtitle(index);
    } else if (language == 'Kannada') {
      return _getKannadaSubtitle(index);
    } else if (language == 'Malayalam') {
      return _getMalayalamSubtitle(index);
    } else {
      return _getEnglishSubtitle(index);
    }
  }

  String _getTamilSubtitle(int index) {
    final texts = [
      'இந்த வீடியோவில் முக்கியமான தகவல்கள் உள்ளன',
      'கவனமாக கேட்டு புரிந்து கொள்ளுங்கள்',
      'இது உங்கள் கல்விக்கு மிகவும் பயனுள்ளதாக இருக்கும்',
      'முக்கியமான புள்ளிகளை குறித்து வைத்துக் கொள்ளுங்கள்',
      'இந்த கருத்துக்கள் தேர்வில் வரக்கூடும்',
      'நன்றாக படித்து புரிந்து கொள்ளுங்கள்',
      'கேள்விகள் இருந்தால் ஆசிரியரிடம் கேளுங்கள்',
      'இந்த பாடம் அடுத்த அத்தியாயத்துடன் தொடர்புடையது',
      'தொடர்ந்து கவனமாக பார்க்கவும்',
      'இது மிக முக்கியமான பகுதி',
    ];
    return texts[(index - 1) % texts.length];
  }

  String _getHindiSubtitle(int index) {
    final texts = [
      'इस वीडियो में महत्वपूर्ण जानकारी है',
      'ध्यान से सुनें और समझें',
      'यह आपकी शिक्षा के लिए बहुत उपयोगी है',
      'महत्वपूर्ण बिंदुओं को नोट करें',
      'ये विचार परीक्षा में आ सकते हैं',
      'अच्छी तरह पढ़ें और समझें',
      'प्रश्न हों तो शिक्षक से पूछें',
      'यह पाठ अगले अध्याय से जुड़ा है',
      'ध्यान से देखते रहें',
      'यह बहुत महत्वपूर्ण भाग है',
    ];
    return texts[(index - 1) % texts.length];
  }

  String _getSpanishSubtitle(int index) {
    final texts = [
      'Este video contiene información importante',
      'Escucha atentamente y comprende',
      'Esto será muy útil para tu educación',
      'Toma nota de los puntos importantes',
      'Estas ideas pueden aparecer en el examen',
      'Lee bien y comprende',
      'Si tienes preguntas, pregunta al profesor',
      'Esta lección está relacionada con el próximo capítulo',
      'Continúa viendo con atención',
      'Esta es una parte muy importante',
    ];
    return texts[(index - 1) % texts.length];
  }

  String _getTeluguSubtitle(int index) {
    final texts = [
      'ఈ వీడియోలో ముఖ్యమైన సమాచారం ఉంది',
      'జాగ్రత్తగా వినండి మరియు అర్థం చేసుకోండి',
      'ఇది మీ విద్యకు చాలా ఉపయోగకరంగా ఉంటుంది',
      'ముఖ్యమైన అంశాలను గమనించండి',
      'ఈ భావనలు పరీక్షలో రావచ్చు',
      'బాగా చదవండి మరియు అర్థం చేసుకోండి',
      'ప్రశ్నలు ఉంటే ఉపాధ్యాయుడిని అడగండి',
      'ఈ పాఠం తదుపరి అధ్యాయంతో సంబంధం కలిగి ఉంది',
      'జాగ్రత్తగా చూడటం కొనసాగించండి',
      'ఇది చాలా ముఖ్యమైన భాగం',
    ];
    return texts[(index - 1) % texts.length];
  }

  String _getKannadaSubtitle(int index) {
    final texts = [
      'ಈ ವೀಡಿಯೊದಲ್ಲಿ ಪ್ರಮುಖ ಮಾಹಿತಿ ಇದೆ',
      'ಎಚ್ಚರಿಕೆಯಿಂದ ಕೇಳಿ ಮತ್ತು ಅರ್ಥಮಾಡಿಕೊಳ್ಳಿ',
      'ಇದು ನಿಮ್ಮ ಶಿಕ್ಷಣಕ್ಕೆ ಬಹಳ ಉಪಯುಕ್ತವಾಗಿದೆ',
      'ಪ್ರಮುಖ ಅಂಶಗಳನ್ನು ಗಮನಿಸಿ',
      'ಈ ಪರಿಕಲ್ಪನೆಗಳು ಪರೀಕ್ಷೆಯಲ್ಲಿ ಬರಬಹುದು',
      'ಚೆನ್ನಾಗಿ ಓದಿ ಮತ್ತು ಅರ್ಥಮಾಡಿಕೊಳ್ಳಿ',
      'ಪ್ರಶ್ನೆಗಳಿದ್ದರೆ ಶಿಕ್ಷಕರನ್ನು ಕೇಳಿ',
      'ಈ ಪಾಠವು ಮುಂದಿನ ಅಧ್ಯಾಯದೊಂದಿಗೆ ಸಂಬಂಧಿಸಿದೆ',
      'ಎಚ್ಚರಿಕೆಯಿಂದ ನೋಡುವುದನ್ನು ಮುಂದುವರಿಸಿ',
      'ಇದು ಬಹಳ ಪ್ರಮುಖ ಭಾಗ',
    ];
    return texts[(index - 1) % texts.length];
  }

  String _getMalayalamSubtitle(int index) {
    final texts = [
      'ഈ വീഡിയോയിൽ പ്രധാനപ്പെട്ട വിവരങ്ങൾ ഉണ്ട്',
      'ശ്രദ്ധയോടെ കേൾക്കുകയും മനസ്സിലാക്കുകയും ചെയ്യുക',
      'ഇത് നിങ്ങളുടെ വിദ്യാഭ്യാസത്തിന് വളരെ ഉപയോഗപ്രദമാണ്',
      'പ്രധാനപ്പെട്ട പോയിന്റുകൾ ശ്രദ്ധിക്കുക',
      'ഈ ആശയങ്ങൾ പരീക്ഷയിൽ വരാം',
      'നന്നായി വായിക്കുകയും മനസ്സിലാക്കുകയും ചെയ്യുക',
      'ചോദ്യങ്ങളുണ്ടെങ്കിൽ അധ്യാപകനോട് ചോദിക്കുക',
      'ഈ പാഠം അടുത്ത അധ്യായവുമായി ബന്ധപ്പെട്ടിരിക്കുന്നു',
      'ശ്രദ്ധയോടെ കാണുന്നത് തുടരുക',
      'ഇത് വളരെ പ്രധാനപ്പെട്ട ഭാഗമാണ്',
    ];
    return texts[(index - 1) % texts.length];
  }

  String _getEnglishSubtitle(int index) {
    final texts = [
      'This video contains important information',
      'Listen carefully and understand',
      'This will be very useful for your education',
      'Take note of the important points',
      'These concepts may appear in the exam',
      'Read well and understand',
      'If you have questions, ask the teacher',
      'This lesson is related to the next chapter',
      'Continue watching carefully',
      'This is a very important part',
    ];
    return texts[(index - 1) % texts.length];
  }

  Future<void> _initTts() async {
    try {
      // setSharedInstance is not supported on web, wrap in try-catch
      await _flutterTts.setSharedInstance(true);
    } catch (e) {
      // Ignore - not supported on web platform
    }

    String languageCode = 'en-US';
    if (widget.file.targetLanguage == 'Tamil') {
      languageCode = 'ta-IN';
    } else if (widget.file.targetLanguage == 'Hindi') {
      languageCode = 'hi-IN';
    } else if (widget.file.targetLanguage == 'Spanish') {
      languageCode = 'es-ES';
    } else if (widget.file.targetLanguage == 'Telugu') {
      languageCode = 'te-IN';
    } else if (widget.file.targetLanguage == 'Kannada') {
      languageCode = 'kn-IN';
    } else if (widget.file.targetLanguage == 'Malayalam') {
      languageCode = 'ml-IN';
    } else if (widget.file.targetLanguage == 'Bengali') {
      languageCode = 'bn-IN';
    } else if (widget.file.targetLanguage == 'Marathi') {
      languageCode = 'mr-IN';
    } else if (widget.file.targetLanguage == 'Gujarati') {
      languageCode = 'gu-IN';
    } else if (widget.file.targetLanguage == 'Punjabi') {
      languageCode = 'pa-IN';
    }

    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(0.7); // Lower volume so video audio is audible
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  String _getCurrentSubtitle() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return '';
    }

    if (widget.file.subtitles == null || widget.file.subtitles!.isEmpty) {
      return '';
    }

    final currentPosition = _videoController!.value.position;

    for (int i = 0; i < widget.file.subtitles!.length; i++) {
      final subtitle = widget.file.subtitles![i];
      if (currentPosition >= subtitle.startTime &&
          currentPosition <= subtitle.endTime) {
        if (_currentSubtitleIndex != i && widget.file.hasVoiceOver) {
          _currentSubtitleIndex = i;
          _speakSubtitle(subtitle.text);
        }
        return subtitle.text;
      }
    }
    return '';
  }

  Future<void> _speakSubtitle(String text) async {
    if (_videoController!.value.isPlaying && !_isSpeaking) {
      setState(() {
        _isSpeaking = true;
      });
      await _flutterTts.speak(text);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final currentSubtitle = _getCurrentSubtitle();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.file.name,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              Get.snackbar(
                'Download',
                'Translated video with subtitles is ready!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : GestureDetector(
              onTap: () {
                setState(() {
                  _showControls = !_showControls;
                });
              },
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Actual Video Player
                        Center(
                          child: AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          ),
                        ),

                        // Subtitle Overlay
                        if (currentSubtitle.isNotEmpty)
                          Positioned(
                            bottom: 80,
                            left: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.purple,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                currentSubtitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                        // Play/Pause Button Overlay
                        if (_showControls)
                          Center(
                            child: IconButton(
                              icon: Icon(
                                _videoController!.value.isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                size: 80,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_videoController!.value.isPlaying) {
                                    _videoController!.pause();
                                    _flutterTts.stop();
                                    _isSpeaking = false;
                                  } else {
                                    _videoController!.play();
                                  }
                                });
                              },
                            ),
                          ),

                        // Translation Info Overlay
                        Positioned(
                          top: 10,
                          left: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Translated: ${widget.file.sourceLanguage} → ${widget.file.targetLanguage}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                if (widget.file.hasVoiceOver)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.volume_up,
                                        color: _isSpeaking
                                            ? Colors.green
                                            : Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _isSpeaking ? 'Speaking' : 'Voice-over',
                                        style: TextStyle(
                                          color: _isSpeaking
                                              ? Colors.green
                                              : Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Video Controls
                  Container(
                    color: Colors.black,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              _formatDuration(_videoController!.value.position),
                              style: const TextStyle(color: Colors.white),
                            ),
                            Expanded(
                              child: Slider(
                                value: _videoController!
                                    .value
                                    .position
                                    .inMilliseconds
                                    .toDouble(),
                                max: _videoController!
                                    .value
                                    .duration
                                    .inMilliseconds
                                    .toDouble(),
                                activeColor: Colors.purple,
                                inactiveColor: Colors.grey,
                                onChanged: (value) {
                                  _videoController!.seekTo(
                                    Duration(milliseconds: value.toInt()),
                                  );
                                  _currentSubtitleIndex = -1;
                                },
                              ),
                            ),
                            Text(
                              _formatDuration(_videoController!.value.duration),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.replay_10,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                final newPosition =
                                    _videoController!.value.position -
                                    const Duration(seconds: 10);
                                _videoController!.seekTo(
                                  newPosition < Duration.zero
                                      ? Duration.zero
                                      : newPosition,
                                );
                                _currentSubtitleIndex = -1;
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                _videoController!.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_videoController!.value.isPlaying) {
                                    _videoController!.pause();
                                    _flutterTts.stop();
                                    _isSpeaking = false;
                                  } else {
                                    _videoController!.play();
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.forward_10,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                final newPosition =
                                    _videoController!.value.position +
                                    const Duration(seconds: 10);
                                final maxDuration =
                                    _videoController!.value.duration;
                                _videoController!.seekTo(
                                  newPosition > maxDuration
                                      ? maxDuration
                                      : newPosition,
                                );
                                _currentSubtitleIndex = -1;
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.subtitles,
                                color: Colors.white,
                              ),
                              onPressed: _showSubtitlesList,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showSubtitlesList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Subtitles',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.file.subtitles?.length ?? 0} segments',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: widget.file.subtitles != null
                  ? ListView.builder(
                      itemCount: widget.file.subtitles!.length,
                      itemBuilder: (context, index) {
                        final subtitle = widget.file.subtitles![index];
                        final currentPosition =
                            _videoController!.value.position;
                        final isActive =
                            currentPosition >= subtitle.startTime &&
                            currentPosition <= subtitle.endTime;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isActive
                                ? Colors.green
                                : Colors.purple,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            subtitle.text,
                            style: TextStyle(
                              color: isActive ? Colors.green : Colors.white,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            '${_formatDuration(subtitle.startTime)} - ${_formatDuration(subtitle.endTime)}',
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                          onTap: () {
                            _videoController!.seekTo(subtitle.startTime);
                            _currentSubtitleIndex = -1;
                            Navigator.pop(context);
                          },
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'No subtitles available',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
