@echo off
echo 🚀 JeduAI Quick Web Deployment Script
echo =====================================

echo.
echo 📦 Step 1: Building Flutter web app...
flutter build web --release

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Build failed! Please check the errors above.
    pause
    exit /b 1
)

echo.
echo ✅ Build successful! Web app is ready at: build/web/
echo.

echo 📁 Step 2: Opening build folder...
explorer "build\web"

echo.
echo 🌐 Step 3: Deployment Options:
echo.
echo 1. Netlify (Recommended):
echo    - Go to https://app.netlify.com/
echo    - Drag and drop the 'build\web' folder
echo.
echo 2. Vercel:
echo    - Go to https://vercel.com/
echo    - Click "New Project" and upload 'build\web'
echo.
echo 3. GitHub Pages:
echo    - Upload contents to a GitHub repository
echo    - Enable Pages in repository settings
echo.

echo 🔑 Default Login Credentials:
echo    Admin: admin@vsb.edu / admin123
echo    New users can sign up with any email
echo.

echo 📱 Your app is also running locally at:
echo    http://localhost:8080
echo.

echo 🎉 Ready to deploy! The build folder is open in Explorer.
echo.
pause
