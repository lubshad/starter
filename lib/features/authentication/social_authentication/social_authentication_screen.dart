import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../exporter.dart';
import '../../../widgets/loading_button.dart';
import 'email_and_password_mixin.dart';

class SocialAuthenticationScreen extends StatefulWidget {
  static const String path = "/social-authentication";

  const SocialAuthenticationScreen({super.key});

  @override
  State<SocialAuthenticationScreen> createState() =>
      _SocialAuthenticationScreenState();
}

class _SocialAuthenticationScreenState extends State<SocialAuthenticationScreen>
    with EmailPasswordMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: primaryColor),
          const LoginBackground(),
          LoginBottomSheet(
            child: Form(
              key: formKey,
              child: Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: Theme.of(context).inputDecorationTheme
                      .copyWith(hintStyle: hintStyle.copyWith(fontSize: 15.sp)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Log in", style: context.labelLarge),
                    gapLarge,
                    TextFormField(
                      autofillHints: const [AutofillHints.url],
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.next,
                      controller: domainController,
                      validator: (value) =>
                          domainValidator(domainController, required: true),
                      decoration: InputDecoration(
                        suffixIcon: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [SvgPicture.asset(Assets.svgs.domainGlobe)],
                        ),
                        hintText: "https://yourcompany.com",
                      ),
                    ),
                    gapLarge,
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: usernameController,
                      validator: validateUsername,
                      decoration: InputDecoration(
                        suffixIcon: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(Assets.svgs.personOutline),
                          ],
                        ),
                        hintText: "Enter username",
                      ),
                    ),
                    gapLarge,
                    TextFormField(
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (value) => signInWithEmailAndPassword(),
                      obscureText: !passwordVisible,
                      validator: passwordValidator,
                      controller: passwordController,
                      decoration: InputDecoration(
                        errorText: passwordError,
                        hintText: "Password",
                        suffixIcon: IconButton(
                          onPressed: touglePasswordVisibility,
                          icon: SvgPicture.asset(Assets.svgs.lockOutline),
                        ),
                      ),
                    ),
                    gapXL,
                    LoadingButton(
                      buttonLoading: loginButtonLoading,
                      text: "SUBMIT",
                      onPressed: signInWithEmailAndPassword,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // void navigateForgotPassword() {}

  // void signupAction() {}
}

class LoginBottomSheet extends StatelessWidget {
  const LoginBottomSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(paddingLarge),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: paddingXL,
          vertical: paddingXL * 1.5,
        ),
        child: child,
      ),
    );
  }
}

class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key, this.assetImage});

  final String? assetImage;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100.h,
      right: 40.h,
      left: 40.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your app description here.",
            style: context.labelLarge.copyWith(color: Colors.white),
          ),
          gapXL,
          Row(
            children: [
              Expanded(
                child: SvgPicture.asset(
                  assetImage ?? Assets.svgs.loginGraphics,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String? domainValidator(
  TextEditingController controller, {
  bool required = false,
}) {
  if (required && controller.text.isEmpty) {
    return "Domain is required";
  } else if (controller.text.isNotEmpty) {
    var uri = Uri.tryParse(controller.text);
    if (uri?.hasScheme == false) {
      controller.text = "https://${controller.text}";
      uri = Uri.tryParse(controller.text);
      controller.text = controller.text;
    }

    if (uri == null ||
        !uri.hasScheme ||
        !["https", "http"].contains(uri.scheme) ||
        uri.authority == "" ||
        !uri.authority.contains(".") ||
        uri.authority.split(".").last.length < 2) {
      return "Enter a valid url eg:(www.touch2scan.com)";
    }
    return null;
  }
  return null;
}
