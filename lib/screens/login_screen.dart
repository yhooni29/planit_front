import 'package:flutter/material.dart';

import '../widgets/planit_mascot.dart';
import 'home_screen.dart';
import 'profile/profile_widgets.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final id = idController.text.trim();
    final password = passwordController.text;
    if (id.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('아이디와 비밀번호를 입력해 주세요.')));
      return;
    }
    FocusScope.of(context).unfocus();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(loginId: id)),
    );
  }

  InputDecoration _decoration(String hint, IconData icon, {Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF90A5B5), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF6992B0), size: 21),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFDDEBF4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFDDEBF4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: profileBlue, width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) => Theme(
    data: profileTheme(context).copyWith(
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: profileBlue,
        selectionColor: profileButton,
        selectionHandleColor: profileBlue,
      ),
    ),
    child: Scaffold(
      backgroundColor: const Color(0xFFF0F5F9),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [profileSurface, Color(0xFFF0F8FE)],
              ),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: const Color(0xFFB9E4F8), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1829ACF0),
                  blurRadius: 32,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: Color(0x08073365),
                  blurRadius: 16,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 600;
                return SingleChildScrollView(
                  key: const ValueKey('login-scroll'),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: compact ? 20 : 36,
                      ),
                      child: AutofillGroup(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                width: compact ? 60 : 104,
                                height: compact ? 60 : 104,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Colors.white, Color(0xFFDFF3FF)],
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFD3EBF9),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x0E0077CC),
                                      blurRadius: 20,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: PlanitMascot(size: compact ? 50 : 86),
                              ),
                            ),
                            SizedBox(height: compact ? 10 : 16),
                            Text.rich(
                              const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Plan',
                                    style: TextStyle(color: profileInk),
                                  ),
                                  TextSpan(
                                    text: 'it',
                                    style: TextStyle(color: profileBlue),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: compact ? 36 : 46,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -1.5,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: compact ? 10 : 14),
                            const Text(
                              '우리의 약속을 더 쉽고 즐겁게',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: profileInk,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -.5,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '함께 만드는 더 좋은 하루',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF6C879A),
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: compact ? 20 : 32),
                            const Text(
                              '아이디',
                              style: TextStyle(
                                color: profileInk,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              key: const ValueKey('login-id'),
                              controller: idController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.username],
                              autocorrect: false,
                              style: const TextStyle(
                                color: profileInk,
                                fontSize: 14,
                              ),
                              decoration: _decoration(
                                '아이디를 입력하세요',
                                Icons.person_outline_rounded,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '비밀번호',
                              style: TextStyle(
                                color: profileInk,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              key: const ValueKey('login-password'),
                              controller: passwordController,
                              obscureText: !isPasswordVisible,
                              autocorrect: false,
                              enableSuggestions: false,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              scrollPadding: const EdgeInsets.only(bottom: 96),
                              style: const TextStyle(
                                color: profileInk,
                                fontSize: 14,
                              ),
                              onSubmitted: (_) => _login(),
                              decoration: _decoration(
                                '비밀번호를 입력하세요',
                                Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  tooltip: isPasswordVisible
                                      ? '비밀번호 숨기기'
                                      : '비밀번호 보기',
                                  icon: Icon(
                                    isPasswordVisible
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF6992B0),
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                    () =>
                                        isPasswordVisible = !isPasswordVisible,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: compact ? 20 : 24),
                            ElevatedButton(
                              key: const ValueKey('login-submit'),
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: profileBlue,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: profileButton,
                                minimumSize: const Size.fromHeight(52),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '로그인',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 18),
                                ],
                              ),
                            ),
                            SizedBox(height: compact ? 8 : 16),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 2,
                              children: [
                                const Text(
                                  '아직 회원이 아니신가요?',
                                  style: TextStyle(
                                    color: Color(0xFF6C879A),
                                    fontSize: 12,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SignupScreen(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: profileBlue,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                  ),
                                  child: const Text(
                                    '회원가입',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}
