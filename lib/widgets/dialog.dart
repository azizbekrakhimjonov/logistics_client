
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../routes.dart';

class MyDialog extends StatelessWidget {
  final Function hideModal;
  final Function onDone;
  const MyDialog({super.key,required this.hideModal,required this.onDone});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      // title: const Text('Alert'),
      content: Text(
        'Sizning yakunlanmagan zakazingiz bor. Davom ettirishni xohlaysizmi?',
        style: boldBlack,
      ),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          child: Text("Yo'q", style: mediumBlack),
          onPressed: () {
            Navigator.pop(context);
            hideModal();
            // return false;
          },
        ),
        CupertinoDialogAction(
          child: Text('Ha', style: mediumBlack.copyWith(color: AppColor.red)),
          isDestructiveAction: true,
          onPressed: () {
            
            // setState(() {});
            Navigator.pop(context);
            onDone();
    

            // Do something destructive.
          },
        ),
      ],
    );
  }
}

// To show the dialog, call the following code:

