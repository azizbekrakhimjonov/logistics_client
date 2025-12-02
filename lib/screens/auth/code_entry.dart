import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistic/constants/app_text_style.dart';
import 'package:logistic/constants/colors.dart';
import 'package:logistic/routes.dart';
import 'package:logistic/widgets/bottom_cursor.dart';
import 'package:logistic/widgets/custom_button.dart';

import '../../utils/services.dart';
import 'bloc/login_bloc.dart';

class CodeEntryScreen extends StatefulWidget {
  const CodeEntryScreen({super.key});
  static const String routeName = "code-entry";

  @override
  State<CodeEntryScreen> createState() => _CodeEntryScreenState();
}

class _CodeEntryScreenState extends State<CodeEntryScreen> {
  final controller = TextEditingController();
  final _bloc = LoginBloc();
  final interval = const Duration(seconds: 1);
  final int timerMaxSeconds = 180;
  int currentSeconds = 0;
  dynamic args;
  Timer? timer;


  startTimeout([int? milliseconds]) {
    var duration = interval;
    timer = Timer.periodic(duration, (timer) {
      setState(() {
        currentSeconds = timer.tick;
        if (timer.tick >= timerMaxSeconds) timer.cancel();
      });
    });
  }
stopTimer() {
  if (timer != null && timer!.isActive) {
    timer!.cancel();
  }
}
  

  @override
  void initState() {
    startTimeout();
    super.initState();
  }
  
  @override
  void didChangeDependencies() {
    setState(() {
      args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    });
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
    
    print('dispose, mounted: $mounted');

  }


  @override
  Widget build(BuildContext context) {
    print("Controller:${controller.text}");
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColor.primary),
      body: BlocProvider.value(
        value: _bloc,
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginFailState) {
                  print(state.message.toString());
                   Services.showSnackBar(
                    context,state.message.toString(), AppColor.errorRed);
                } else if (state is LoginSuccessState) {
                  Navigator.pushNamedAndRemoveUntil(context, Routes.mainScreen, (route) => false);
                }
          },
          builder: (context, state) {
            return Container(
                child: Column(
              children: [
                Container(
                  height: 80,
                  width: double.infinity,
                  color: AppColor.primary,
                  child: Column(
                    //  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Raqamni tasdiqlash",
                        style: boldBlack.copyWith(
                            color: AppColor.white, fontSize: 25),
                      ),
                      const SizedBox(height: 5),
                      Text("4ta sonli kodni shu yerga kiriting",
                          style: lightBlack.copyWith(color: AppColor.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 45),
                OnlyBottomCursor(controller: controller),
                const SizedBox(height: 25),
                Text(
                  '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}:${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}',
                  textAlign: TextAlign.center,
                  style: boldBlack.copyWith(color: AppColor.secondaryText),
                ),
                const Spacer(),
                Button(
                    title: "Tasdiqlash",
                    onPress: () {
                      _bloc.add(CodeEntryEvent(phone: args["phone"], opt: controller.text));
                      // Navigator.pushNamed(context, Routes.mainScreen);
                    },
                    disable: controller.text.length != 4),
                const SizedBox(height: 20)
              ],
            ));
          },
        ),
      ),
    );
  }
}
