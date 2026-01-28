import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:logistic/widgets/custom_button.dart';

import '../../constants/constants.dart';
import '../../routes.dart';
import '../../utils/services.dart';
import '../../widgets/widgets.dart';
import 'bloc/login_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String routeName = "login";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode focusNode = FocusNode();
  final _phone = TextEditingController();
  final _username = TextEditingController();
  final _bloc = LoginBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.grayBackground,
        body: BlocProvider.value(
          value: _bloc,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(focusNode);
            },
            child: Stack(
              children: [
                Container(
                    decoration: BoxDecoration(
                        color: AppColor.primary,
                        image: DecorationImage(
                            image: AssetImage(AssetImages.city),
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.bottomCenter,

                            // scale: 0.5,
                            repeat: ImageRepeat.repeatX)),
                    height: MediaQuery.sizeOf(context).height / 2,
                    width: double.infinity,
                    child: SafeArea(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            "app_name_client".tr(),
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )),
                Container(
                  // height: double.infinity,
                  width: double.infinity,

                  child: SingleChildScrollView(
                      child: BlocConsumer<LoginBloc, LoginState>(
                    listener: (context, state) {
                      if (state is LoginFailState) {
                        print(state.message.toString());
                        Services.showSnackBar(
                            context, state.message.toString(), AppColor.red);
                      } else if (state is LoginSuccessState) {
                        Navigator.pushNamed(context, Routes.codeEntry,
                            arguments: {
                              "phone": _phone
                                  .text, //.replaceAll(RegExp(r'[^0-9]'),'')
                            });
                      }
                    },
                    builder: (context, state) {
                      return Container(
                        child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              // mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                    height: MediaQuery.sizeOf(context).height *
                                        0.14),
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      color: AppColor.white,
                                      borderRadius: BorderRadius.circular(19)),
                                  child: Image.asset(AssetImages.brand),
                                ),
                                SizedBox(
                                    height: MediaQuery.sizeOf(context).height *
                                        0.10),
                                Container(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.45,
                                  width: double.infinity,
                                  margin: EdgeInsets.symmetric(horizontal: 16),
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  decoration: BoxDecoration(
                                      color: AppColor.white,
                                      boxShadow: [
                                        BoxShadow(
                                          spreadRadius: 2,
                                          blurRadius: 20,
                                          color:
                                              AppColor.black.withOpacity(0.2),
                                          offset: Offset(1.0, 1.0),
                                        )
                                      ],
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      // SizedBox(height: 25),
                                      Column(
                                        children: [
                                          Text(
                                            "Sign In / Sign Up",
                                            style: boldBlack.copyWith(
                                                fontSize: 18,
                                                color: AppColor.secondaryText),
                                          ),
                                          SizedBox(height: 10),
                                          Divider(thickness: 1)
                                        ],
                                      ),
                                      //  SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 21.0),
                                        child: InputField(
                                          title: "",//"name".tr(),
                                          value: _username,
                                          onChange: () {},
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter some text';
                                            }
                                            return null;
                                          },
                                          maxLength: 25,
                                          hint: "name".tr(),
                                        ),
                                      ),
                                      phoneNumberField(),

                                      Button(
                                          title: "Kirish",
                                          loading: (state is LoginLoadingState),
                                          onPress: () => onButtonPressed())
                                    ],
                                  ),
                                ),
                                // Spacer(),
                                SizedBox(height: 50),
                                Center(
                                    child: Text(
                                  "Ro‘yxatdan o‘tish tugmasini bosish orqali siz bizning Shartlarimizga rozilik bildirasiz",
                                  textAlign: TextAlign.center,
                                  style: lightBlack.copyWith(fontSize: 14),
                                )),
                                // SizedBox(height: 40)
                              ],
                            )),
                      );
                    },
                  )),
                ),
              ],
            ),
          ),
        ));
  }

  void onButtonPressed() {
    print("Validation:${_formKey.currentState!.validate()}");
    if (_formKey.currentState!.validate() && !_phone.text.isEmpty) {
      print("Phone:${_phone.value}");
      FocusScope.of(context).requestFocus(focusNode);
      _bloc.add(LoginEnterEvent(
          phone: _phone.text,//.replaceAll(RegExp(r'[^0-9]'), ''),
          name: _username.text));
      // Navigator.pushNamed(context, Routes.codeEntry);
    }
  }

  Widget phoneNumberField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21.0),
      child: IntlPhoneField(
        languageCode: "uz",
        // controller: _phone,
        // searchFieldI ,
        // autofocus: true,
        autovalidateMode: AutovalidateMode.disabled,
        textAlignVertical: TextAlignVertical.center,
        style: mediumBlack,
        dropdownTextStyle: mediumBlack,
        dropdownIconPosition: IconPosition.trailing,
        flagsButtonMargin: EdgeInsets.only(left: 10),
        pickerDialogStyle: PickerDialogStyle(
            countryNameStyle: mediumBlack, countryCodeStyle: boldBlack),
        disableLengthCheck: false,
        disableAutoFillHints: true,
        decoration: InputDecoration(
            labelText: 'Telefon raqam',
            floatingLabelBehavior: FloatingLabelBehavior.never,
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: AppColor.primary.withOpacity(0.5), width: 1.0),
                borderRadius: BorderRadius.circular(8)),
            border: OutlineInputBorder(
                borderSide: BorderSide(),
                borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColor.secondaryText.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(8)),
            errorBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: AppColor.red.withOpacity(0.2), width: 1),
                borderRadius: BorderRadius.circular(8)),
            focusColor: AppColor.primary),
        initialCountryCode: 'UZ',
        onChanged: (phone) {
          print(phone.completeNumber);
           _phone.text = phone.completeNumber;
        },

        validator: (value) {
          print("Value:${value!.completeNumber}");
          if (value.isValidNumber()) {
            print("Please enter some text");
            return 'Please enter some text';
          }
          return null;
        },
      ),
    );
  }
}
