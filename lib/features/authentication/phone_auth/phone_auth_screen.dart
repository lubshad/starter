// ignore_for_file: use_build_context_synchronously
import 'package:auto_size_text/auto_size_text.dart';
import 'package:country_code_picker/country_code_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import '../../../exporter.dart';
import '../../../widgets/form_header.dart';
import '../../../widgets/loading_button.dart';
import 'phone_auth_mixin.dart';

class PhoneVerification extends StatefulWidget {
  static const String path = "/phone-verification";

  const PhoneVerification({super.key});

  @override
  State<PhoneVerification> createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification>
    with PhoneAuthMixin {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (pageController.page == 1) {
          pageController.previousPage(
            duration: animationDuration,
            curve: Curves.fastOutSlowIn,
          );
        } else if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          SystemNavigator.pop(animated: true);
        }
      },
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent),
        extendBodyBehindAppBar: true,
        body: Builder(
          builder: (context) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: SizeUtils.height * .2,
                  child: Assets.pngs.loginBackground.image(fit: BoxFit.cover),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: AnimatedBuilder(
                    animation: pageController,
                    builder: (context, child) {
                      return AnimatedContainer(
                        duration: animationDuration,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(paddingXL),
                          ),
                        ),
                        height: containerHeight,
                        child: PageView(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: pageController,
                          children: [
                            buildPhoneSection(context),
                            buildOtpSection(context),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Padding buildOtpSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(paddingXL),
      child: Form(
        key: pinformKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("OTP Verification", style: context.bodySmall),
            gapLarge,
            AutoSizeText(
              "We have sent a verification code to your phone number",
              style: context.bodySmall.copyWith(color: Color(0xff959595)),
              maxLines: 1,
            ),
            gapLarge,
            Pinput(
              defaultPinTheme: PinTheme(
                margin: EdgeInsets.all(paddingSmall),
                textStyle: context.bodySmall.copyWith(
                  color: Color(0xff1C1F1D),
                ),
                height: 55.fSize,
                width: 75.fSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(padding),
                  border: Border.all(color: Color(0xffDCDBDB)),
                ),
              ),
              autofocus: true,
              forceErrorState: otpErrorText != null,
              errorText: otpErrorText,
              controller: pincodeController,
              length: otpLenth,
              validator: pinValidation,
            ),
            gapLarge,

            RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: AnimatedBuilder(
                      animation: stopwatchValue,
                      builder: (context, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: isTimeOut ? resendOtp : null,
                              style: shrinkedButton,
                              child: const Text("Resend OTP "),
                            ),
                            if (!isTimeOut)
                              Text(
                                "in $timeRemaining seconds",
                                style: context.labelLarge,
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            gapXL,
            LoadingButton(
              buttonLoading: buttonLoading,
              text: "Validate",
              onPressed: validateOtp,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPhoneSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(paddingXL),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Unlock Your Experience, Log In and Get Started!",
              style: context.bodySmall,
            ),
            gapLarge,
            FormHeader(
              label: "Mobile No",
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CountryCodePicker(
                    alignLeft: false,
                    textStyle: context.bodySmall.copyWith(
                      color: Color(0xff3F4255),
                    ),
                    showFlag: false,
                    padding: EdgeInsets.zero,
                    onChanged: onCountryChanged,
                    initialSelection: selectedCountry.name,
                    favorite: ["+91", "+966"],
                  ),
                  Expanded(
                    child: TextFormField(
                      textAlignVertical: TextAlignVertical.top,
                      style: context.bodySmall,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      keyboardType: TextInputType.number,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      validator: validatePhone,
                      controller: phoneController,
                      decoration: InputDecoration(
                        hintStyle: context.bodySmall.copyWith(
                          color: Color(0xffD2D2D2),
                        ),
                        contentPadding: EdgeInsets.zero,
                        hintText: "00000 00000",
                        errorText: phoneErrorText,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffDCDBDB)),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffDCDBDB)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffDCDBDB)),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),

                        // prefixIcon: SizedBox(
                        //   width: 0,
                        //   child: Align(
                        //     alignment: Alignment.center,
                        //     child: AnimatedBuilder(
                        //       animation: LocationService.i,
                        //       builder: (context, child) {
                        //         return AutoSizeText(
                        //           selectedCountry.dialCode ?? "+966",
                        //           style: context.bodySmall.copyWith(
                        //             color: Color(0xff3F4255),
                        //           ),
                        //           maxLines: 1,
                        //         );
                        //       },
                        //     ),
                        //   ),
                        // ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            gapLarge,
            Row(
              children: [
                Checkbox(
                  visualDensity: VisualDensity.compact,
                  side: BorderSide(color: Color(0xffCFCFCF)),
                  value: tandcChecked,
                  onChanged: (_) => tougleTandC(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                AutoSizeText(
                  "I have read the T&C and Privacy Policy",
                  style: context.bodySmall.copyWith(color: Color(0xff959595)),
                  maxLines: 1,
                ),
              ],
            ),
            gapLarge,
            LoadingButton(
              buttonLoading: buttonLoading,
              onPressed: sendOtp,
              text: 'Next',
            ),
          ],
        ),
      ),
    );
  }
}
