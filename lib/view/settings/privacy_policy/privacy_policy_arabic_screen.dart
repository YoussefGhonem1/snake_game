import 'package:flutter/material.dart';
import 'package:snake_game/core/constants/game_colors.dart';

class PrivacyPolicyArabicScreen extends StatelessWidget {
  const PrivacyPolicyArabicScreen({super.key});

  ColorHelper get colorHelper => ColorHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "سياسة الخصوصية",
          style: TextStyle(
            color: colorHelper.appTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorHelper.appBackgroundColor,
        iconTheme: IconThemeData(color: colorHelper.appIconColor),
      ),
      backgroundColor: colorHelper.appBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "سياسة الخصوصية",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorHelper.primary,
                ),
              ),
              Text(
                "تاريخ الإصدار: 4 يوليو 2025",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorHelper.appTextColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "مرحبًا بك في لعبة الثعابين! خصوصيتك مهمة بالنسبة لنا. توضح هذه السياسة كيف نجمع بياناتك ونستخدمها ونحميها.",
                style: TextStyle(fontSize: 16, color: colorHelper.appTextColor),
              ),
              const SizedBox(height: 20),
              _sectionTitle("1. المعلومات التي نجمعها"),
              _sectionContent(
                "• المعلومات الشخصية: الاسم، البريد الإلكتروني، وكلمة المرور.\n"
                "• بيانات اللعبة: الدرجات والمستويات المفتوحة.\n"
                "• بيانات الإعلانات: Unity Ads .",
              ),
              _sectionTitle("2. كيفية استخدام معلوماتك"),
              _sectionContent(
                "• وظائف اللعبة: التسجيل، تسجيل الدخول، والتخصيص.\n"
                "• تتبع التقدم: حفظ واستعادة التقدم.\n"
                "•عرض الإعلانات:Unity Ads\n"
                " • إدارة الحساب: تعديل أو حذف الحساب.",
              ),
              _sectionTitle("3. تخزين البيانات والأمان"),
              _sectionContent(
                "نستخدم Firebase لتخزين بياناتك بأمان واستعادتها عبر أي جهاز.",
              ),
              _sectionTitle("4. خدمات الطرف الثالث"),
              _sectionContent(
                "• Firebase (لتخزين الحساب والنتائج).\n"
                "• Unity Ads (لعرض الإعلانات).",
              ),
              _sectionTitle("5. حقوق المستخدم"),
              _sectionContent(
                "• يمكنك تعديل اسمك من خلال الإعدادات > الملف الشخصي.\n"
                "• يمكنك حذف حسابك وبياناتك بالكامل من خلال:\n"
                "  الرئيسية > الإعدادات > الملف الشخصي > حذف الحساب.\n"
                "• أو تواصل معنا عبر البريد الإلكتروني.",
              ),
              _sectionTitle("6. خصوصية الأطفال"),
              _sectionContent(
                "إذا قدم الطفل بيانات دون إذن الوالدين، نرجو التواصل معنا لحذفها.",
              ),
              _sectionTitle("7. تحديثات سياسة الخصوصية"),
              _sectionContent(
                "قد نقوم بتحديث هذه السياسة، وسيتم إخطارك داخل اللعبة.",
              ),
              _sectionTitle("8. تواصل معنا"),
              _sectionContent("البريد الإلكتروني: f1ale1h@gmail.com"),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorHelper.primary,
        ),
      ),
    );
  }

  Widget _sectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        content,
        style: TextStyle(fontSize: 16, color: colorHelper.appTextColor),
      ),
    );
  }
}
