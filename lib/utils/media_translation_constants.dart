/// Media Translation Module Constants
/// 
/// This file contains all constants used in the media translation module
library;

class MediaTranslationConstants {
  // Supported file extensions
  static const List<String> audioExtensions = ['mp3', 'wav', 'm4a', 'ogg', 'flac', 'aac'];
  static const List<String> videoExtensions = ['mp4', 'mov', 'mkv', 'webm', 'avi'];
  
  // File size limits (in bytes)
  static const int maxAudioSize = 25 * 1024 * 1024; // 25 MB
  static const int maxVideoSize = 100 * 1024 * 1024; // 100 MB
  
  // Processing steps
  static const List<String> processingSteps = [
    'Uploading',
    'Extracting Audio',
    'Transcribing',
    'Translating',
    'Generating Files',
    'Completed',
  ];
  
  // Language codes mapping for Whisper (ISO 639-1)
  static const Map<String, String> whisperLanguageCodes = {
    'English': 'en',
    'Tamil': 'ta',
    'Hindi': 'hi',
    'Telugu': 'te',
    'Kannada': 'kn',
    'Malayalam': 'ml',
    'Bengali': 'bn',
    'Marathi': 'mr',
    'Gujarati': 'gu',
    'Punjabi': 'pa',
    'Urdu': 'ur',
    'Spanish': 'es',
    'French': 'fr',
    'German': 'de',
    'Chinese': 'zh',
    'Japanese': 'ja',
    'Korean': 'ko',
    'Arabic': 'ar',
    'Russian': 'ru',
    'Portuguese': 'pt',
    'Italian': 'it',
    'Dutch': 'nl',
    'Turkish': 'tr',
    'Polish': 'pl',
    'Vietnamese': 'vi',
    'Thai': 'th',
    'Indonesian': 'id',
  };
  
  // Language codes for NLLB-200 (3-letter codes)
  static const Map<String, String> nllbLanguageCodes = {
    'English': 'eng_Latn',
    'Tamil': 'tam_Taml',
    'Hindi': 'hin_Deva',
    'Telugu': 'tel_Telu',
    'Kannada': 'kan_Knda',
    'Malayalam': 'mal_Mlym',
    'Bengali': 'ben_Beng',
    'Marathi': 'mar_Deva',
    'Gujarati': 'guj_Gujr',
    'Punjabi': 'pan_Guru',
    'Urdu': 'urd_Arab',
    'Spanish': 'spa_Latn',
    'French': 'fra_Latn',
    'German': 'deu_Latn',
    'Chinese': 'zho_Hans',
    'Japanese': 'jpn_Jpan',
    'Korean': 'kor_Hang',
    'Arabic': 'arb_Arab',
    'Russian': 'rus_Cyrl',
    'Portuguese': 'por_Latn',
    'Italian': 'ita_Latn',
    'Dutch': 'nld_Latn',
    'Turkish': 'tur_Latn',
    'Polish': 'pol_Latn',
    'Vietnamese': 'vie_Latn',
    'Thai': 'tha_Thai',
    'Indonesian': 'ind_Latn',
  };
  
  // Supported languages list
  static List<String> get supportedLanguages => whisperLanguageCodes.keys.toList();
  
  // Get Whisper language code
  static String getWhisperCode(String language) {
    return whisperLanguageCodes[language] ?? 'en';
  }
  
  // Get NLLB language code
  static String getNllbCode(String language) {
    return nllbLanguageCodes[language] ?? 'eng_Latn';
  }
  
  // Status messages
  static const String statusUploading = 'Uploading file...';
  static const String statusExtracting = 'Extracting audio...';
  static const String statusTranscribing = 'Transcribing audio...';
  static const String statusTranslating = 'Translating text...';
  static const String statusGenerating = 'Generating output files...';
  static const String statusCompleted = 'Translation completed!';
  static const String statusFailed = 'Translation failed';
  
  // Error messages
  static const String errorInvalidFile = 'Invalid file format';
  static const String errorFileTooLarge = 'File size exceeds limit';
  static const String errorNoToken = 'Hugging Face token not configured';
  static const String errorTranscriptionFailed = 'Transcription failed';
  static const String errorTranslationFailed = 'Translation failed';
  static const String errorNetworkIssue = 'Network error occurred';
  static const String errorTimeout = 'Request timed out';
  
  // API Configuration
  static const int apiTimeout = 120; // seconds
  static const int maxRetries = 3;
  static const int retryDelay = 2; // seconds
}
