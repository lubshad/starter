
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../exporter.dart';
import '../../../widgets/form_header.dart';
import '../../../widgets/loading_button.dart';
import 'email_and_password_mixin.dart';
import 'google_oauth_mixin.dart';

class SocialAuthenticationScreen extends StatefulWidget {
  static const String path = "/social-authentication";

  const SocialAuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<SocialAuthenticationScreen> createState() =>
      _SocialAuthenticationScreenState();
}

class _SocialAuthenticationScreenState extends State<SocialAuthenticationScreen>
    with GoogleOauthMixin, EmailPasswordMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(paddingLarge),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        paddingLarge,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: paddingLarge,
                      vertical: paddingXL,
                    ),
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          Assets.svgs.study,
                          width: 100,
                        ),
                        gapLarge,
                        Text(
                          "Log in",
                          style: context.titleLarge,
                        ),
                        gapLarge,
                        FormHeader(
                          label: "Email",
                          child: TextFormField(
                            controller: emailController,
                            validator: emailValidator,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.email_outlined),
                              hintText: "Email",
                            ),
                          ),
                        ),
                        gapLarge,
                        FormHeader(
                          label: "Password",
                          child: TextFormField(
                            obscureText: !passwordVisible,
                            validator: passwordValidator,
                            controller: passwordController,
                            decoration: InputDecoration(
                                errorText: passwordError,
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                ),
                                hintText: "Password",
                                suffixIcon: IconButton(
                                    onPressed: touglePasswordVisibility,
                                    icon: Icon(visibilityIcon))),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                              onPressed: navigateForgotPassword,
                              child: Text(
                                "Forget Password?",
                                style: context.labelLarge.copyWith(
                                  color: Colors.grey,
                                ),
                              )),
                        ),
                        gapLarge,
                        LoadingButtonV2(
                            buttonLoading: loginButtonLoading,
                            text: "Log In",
                            onPressed: signInWithEmailAndPassword),
                        gap,
                        const Text("OR"),
                        gap,
                        LoadingButtonV2(
                          icon: SvgPicture.asset(
                            Assets.svgs.icons8Google,
                            height: paddingXL,
                          ),
                          backgroundColor: Colors.black,
                          buttonLoading: buttonLoading,
                          text: "Sign In With Google",
                          onPressed: signInWithGoogle,
                        ),
                      ],
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Do not have an account?",
                      style: context.labelLarge.copyWith(
                        color: Colors.black.withOpacity(.5),
                      ),
                    ),
                    // gapSmall,
                    TextButton(
                      style: TextButton.styleFrom(
                        // padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: signupAction,
                      child: Text(
                        "Sign Up",
                        style: context.bodyLarge,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void navigateForgotPassword() {}

  void signupAction() {}
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