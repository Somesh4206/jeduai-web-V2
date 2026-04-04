import 'package:get/get.dart';
import '../views/auth/premium_login_page.dart';
import '../views/auth/signup_view.dart';
import '../views/landing/landing_page.dart';
import '../views/student/student_dashboard_view.dart';
import '../views/student/student_profile_view.dart';
import '../views/staff/staff_dashboard_view.dart';
import '../views/staff/staff_profile_view.dart';
import '../views/admin/admin_dashboard_view.dart';
import '../controllers/auth_controller.dart';
import '../controllers/student_controller.dart';
import '../controllers/staff_controller.dart';
import '../controllers/admin_controller.dart';
import '../controllers/translation_controller.dart';
import '../controllers/online_class_controller.dart';
import '../services/online_class_service.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';
import '../services/video_conference_service.dart';

class AppRoutes {
  static final routes = [
    GetPage(
      name: '/',
      page: () => LandingPage(),
    ),
    GetPage(
      name: '/home',
      page: () => LandingPage(),
    ),
    GetPage(
      name: '/login',
      page: () => PremiumLoginPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<UserService>(() => UserService());
        Get.lazyPut<NotificationService>(() => NotificationService());
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: '/signup',
      page: () => SignupView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<UserService>(() => UserService());
        Get.lazyPut<NotificationService>(() => NotificationService());
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: '/student/dashboard',
      page: () => StudentDashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<UserService>(() => UserService());
        Get.lazyPut<NotificationService>(() => NotificationService());
        Get.lazyPut<AuthController>(() => AuthController());
        Get.lazyPut<StudentController>(() => StudentController());
        Get.lazyPut<TranslationController>(() => TranslationController());
        Get.lazyPut<OnlineClassService>(() => OnlineClassService());
        Get.lazyPut<OnlineClassController>(() => OnlineClassController());
        Get.lazyPut<VideoConferenceService>(() => VideoConferenceService());
      }),
    ),
    GetPage(
      name: '/staff/dashboard',
      page: () => StaffDashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<UserService>(() => UserService());
        Get.lazyPut<NotificationService>(() => NotificationService());
        Get.lazyPut<AuthController>(() => AuthController());
        Get.lazyPut<StaffController>(() => StaffController());
        Get.lazyPut<OnlineClassService>(() => OnlineClassService());
        Get.lazyPut<OnlineClassController>(() => OnlineClassController());
        Get.lazyPut<VideoConferenceService>(() => VideoConferenceService());
      }),
    ),
    GetPage(
      name: '/admin/dashboard',
      page: () => AdminDashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<UserService>(() => UserService());
        Get.lazyPut<NotificationService>(() => NotificationService());
        Get.lazyPut<AuthController>(() => AuthController());
        Get.lazyPut<AdminController>(() => AdminController());
        Get.lazyPut<OnlineClassService>(() => OnlineClassService());
        Get.lazyPut<OnlineClassController>(() => OnlineClassController());
      }),
    ),
    GetPage(name: '/student/profile', page: () => const StudentProfileView()),
    GetPage(name: '/staff/profile', page: () => const StaffProfileView()),
  ];
}
