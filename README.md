# 🎓 JeduAI Web V2 - Smart Learning & Assessment Platform

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-3.10+-blue.svg" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.10+-blue.svg" alt="Dart">
  <img src="https://img.shields.io/badge/Web-Ready-green.svg" alt="Web Ready">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License">
</div>

An AI-powered educational platform built with Flutter, featuring intelligent assessment generation, multi-language support, and real-time AI tutoring. **This is the web-optimized version ready for deployment.**

## 🌟 Key Features

### 🤖 AI-Powered Features
- **AI Assessment Generator**: Automatically creates quizzes with questions, options, and explanations
- **AI Tutor**: Real-time conversational learning assistant with multi-language support
- **Smart Translation**: 100+ language support for all content
- **Video Translation**: Real-time video translation with AI-generated subtitles (20+ languages)

### 👥 User Portals
- **Student Portal**: Dashboard, assessments, video player, AI tutor chat
- **Staff Portal**: Assessment creation, student monitoring, analytics
- **Admin Portal**: User management, system analytics, platform configuration

### 🎥 Video Translation Features
- Upload any video and translate to 20+ languages
- Real-time AI-powered transcription and translation
- Automatic subtitle generation with timing
- Voice-over generation with Text-to-Speech

## 🚀 Quick Start for Web Deployment

### Prerequisites
- Flutter SDK 3.10 or higher
- A code editor (VS Code recommended)
- A hosting account (Netlify, Vercel, or GitHub Pages)

### Step 1: Clone and Setup
```bash
git clone https://github.com/Somesh4206/jeduai-web-V2.git
cd jeduai-web-V2
flutter pub get
```

### Step 2: Build for Web
```bash
flutter build web --release
```
The built files will be in the `build/web/` directory.

### Step 3: Deploy to Hosting

#### Option A: Netlify (Recommended) 🌟
1. Go to [Netlify](https://app.netlify.com/)
2. **Drag and drop** the `build/web` folder onto the dashboard
3. Get your live URL instantly
4. Optional: Add a custom domain

#### Option B: Vercel
1. Go to [Vercel](https://vercel.com/)
2. Click "New Project"
3. Upload the `build/web` folder
4. Deploy and get your live URL

#### Option C: GitHub Pages
```bash
# Build the web app
flutter build web --release

# Copy to docs folder for GitHub Pages
cp -r build/web docs

# Push to GitHub
git add docs/
git commit -m "Add web build"
git push origin main
```
Then enable GitHub Pages in your repository settings.

### Step 4: Configure API Keys (Optional)
For full AI functionality, you'll need to set up API keys:

1. **Gemini API** (Required for AI features):
   - Get key from [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Add to your app configuration

2. **Firebase** (Required for authentication):
   - Create project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Email/Password authentication
   - Set up Firestore Database

## 🔑 Default Login Credentials

### For Testing Without Firebase
- **Admin**: `admin@vsb.edu` / Any password
- **Staff**: `staff@jeduai.com` / Any password  
- **Student**: `student@jeduai.com` / Any password

### With Firebase Setup
- **Default Admin**: `admin@vsb.edu` / `admin123` (auto-created)
- **New Users**: Can sign up with any email

## 🌐 Live Demo Features

Once deployed, your web app will include:

### ✅ Core Features
- **User Authentication** with Firebase
- **AI Tutor Chat** (multi-language support)
- **Text Translation** (100+ languages)
- **Video Translation** (20+ languages)
- **AI Assessment Generator**
- **Student, Staff & Admin Portals**
- **Real-time Database Sync**
- **Responsive Design** for all devices

### 📱 Supported Languages
English, Hindi, Tamil, Telugu, Kannada, Malayalam, Bengali, Marathi, Gujarati, Punjabi, Urdu, Spanish, French, German, Chinese, Japanese, Korean, Arabic, Portuguese, Russian, and 80+ more

## 🛠️ Technology Stack

- **Frontend**: Flutter 3.10+ with CanvasKit renderer
- **State Management**: GetX
- **Authentication**: Firebase Auth
- **Database**: Firestore
- **AI Services**: Google Gemini AI
- **UI Components**: Material Design 3
- **Video Processing**: video_player, flutter_tts

## 📁 Project Structure

```
jeduai-web-V2/
├── lib/
│   ├── views/           # UI screens
│   │   ├── auth/       # Login/signup
│   │   ├── student/    # Student portal
│   │   ├── staff/      # Staff portal
│   │   └── admin/      # Admin portal
│   ├── services/       # Business logic
│   ├── controllers/    # State management
│   ├── models/         # Data models
│   └── main.dart       # App entry point
├── web/                # Web-specific files
├── netlify.toml        # Netlify configuration
├── netlify-build.sh    # Build script
└── QUICK_DEPLOY.bat    # Windows deployment script
```

## 🚀 Deployment Scripts

### Quick Deploy (Windows)
Run `QUICK_DEPLOY.bat` for:
- Automated Flutter web build
- Opens build folder in Explorer
- Shows deployment options

### Netlify Configuration
The `netlify.toml` file includes:
- Build commands and redirects
- Security headers
- Caching rules for optimal performance

## 📞 Support

For deployment issues:
- Check [Flutter Web documentation](https://docs.flutter.dev/deployment/web)
- [Netlify documentation](https://docs.netlify.com/)
- [Vercel documentation](https://vercel.com/docs)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.

---

**🎉 Your JeduAI web app is ready to deploy and share with the world!**

**GitHub Repository**: https://github.com/Somesh4206/jeduai-web-V2.git
