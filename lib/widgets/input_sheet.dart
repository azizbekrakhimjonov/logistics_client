import 'package:flutter/material.dart';
import 'package:logistic/widgets/button.dart';

import '../constants/constants.dart';
import 'input_field.dart';

class InputSheet extends StatefulWidget {
  final GlobalKey sheet;
  final Function closeSheet;
  final Function onDone;
  const InputSheet({
    super.key,
    required this.sheet,
    required this.closeSheet,
    required this.onDone,
  });

  @override
  State<InputSheet> createState() => _InputSheetState();
}

class _InputSheetState extends State<InputSheet> {
  final _comment = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode focusNode = FocusNode();
  final _controller = DraggableScrollableController();
  var keyboardSize = 0.0;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _comment.addListener(() {
      setState(() {
        _hasText = _comment.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _comment.dispose();
    focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant InputSheet oldWidget) {
    keyboardSize = MediaQuery.of(context).viewInsets.bottom /
        MediaQuery.of(context).size.height;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(focusNode);
      },
      child: Form(
        key: _formKey,
        child: DraggableScrollableSheet(
          key: widget.sheet,
          controller: _controller,
          initialChildSize: 0.4 + keyboardSize,
          minChildSize: 0.4 + keyboardSize,
          maxChildSize: 0.9,
          snap: false,
          // snapSizes: const [0.7],
          builder:
              (BuildContext context, ScrollController scrollController) {
            return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                ),
                // padding: EdgeInsets.symmetric(horizontal: 35, vertical: 25),
                child: SingleChildScrollView(
                  // reverse: true,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  controller: scrollController,
                  child: Column(
                    children: [
                      // SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: () {
                                widget.closeSheet();
                                Navigator.pop(context);
                                FocusScope.of(context)
                                    .requestFocus(focusNode);
                              },
                              icon: const Icon(Icons.close)),
                        ],
                      ),

                      Text("Sement",
                          style: mediumBlack.copyWith(fontSize: 20)),
                      const SizedBox(height: 5),
                      Text("Miqdorni tanlang",
                          style: lightBlack.copyWith(
                              color: AppColor.secondaryText)),
                      const SizedBox(height: 25),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 21.0),
                        child: InputField(
                          title: "", //"name".tr(),
                          value: _comment,
                          onChange: () {},
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                          maxLength: 25,
                          hint: "e.g Cement, 100kg",
                        ),
                      ),
                      const SizedBox(height: 35),
                      DefaultButton(
                        disable: !_hasText,
                        title: "Tayyor",
                        onPress: () {
                          // _controller.jumpTo(size)
                          if (_comment.text.isNotEmpty) {
                            widget.onDone(_comment.text);
                          }
                        },
                      )
                    ],
                  ),
                ));
          },
        ),
      ),
    );
  }
}
