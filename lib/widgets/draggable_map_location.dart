import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:logistic/models/user.dart';
import 'package:logistic/screens/mainScreen/bloc/main_bloc.dart';
import 'package:logistic/widgets/custom_button.dart';
import 'package:logistic/widgets/widgets.dart';

import '../constants/constants.dart';
import '../models/user_content.dart';

class DraggableMapLocation extends StatelessWidget {
  final List<dynamic> address;
  final GlobalKey sheet;
  final Function openSheet;
  final TextEditingController textController;
  final double size;
  final Function setLocation;
  const DraggableMapLocation(
      {super.key,
      required this.address,
      required this.sheet,
      required this.openSheet,
      required this.textController,
      required this.setLocation,
      required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DraggableScrollableSheet(
        key: sheet,
        initialChildSize: 0.4,
        minChildSize: 0.15,
        maxChildSize: 0.5,
        snap: true,
        snapSizes: const [0.3],
        builder: (BuildContext context, ScrollController scrollController) {
          return DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    locationRow(),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(),
                    ),
                    address.isNotEmpty ?
                       Container(
                      width: double.infinity,
                      // color: AppColor.errorRed,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: (address as List<MyAddress>)
                                .map((e) => InkWell(
                                  onTap: () => setLocation(e.id,e.long,e.lat),
                                  child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                                        margin: EdgeInsets.symmetric(horizontal: 5,vertical: 15),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: AppColor.white,
                                            boxShadow: [
                                              BoxShadow(
                                                spreadRadius: 1,
                                                blurRadius: 10,
                                                color: AppColor.black
                                                    .withOpacity(0.2),
                                                offset: Offset(1.0, 6.0),
                                              )
                                            ]),
                                        child: Text(e.name),
                                      ),
                                ))
                                .toList(),
                          ),
                        ),
                      ),
                    ):SizedBox(),
                    
                    
                    SizedBox(height: 25),
                    DefaultButton(title: "Tayyor", onPress: () => openSheet(),disable: false)
                    //  TextButton(
                    //     onPressed: () => openSheet(), child: Text("send").tr()),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget locationRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SvgPicture.asset(AssetImages.circle),
          ),
          SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Boshlang‘ich manzil",
                style: regularText.copyWith(color: AppColor.secondaryText),
              ),
              SizedBox(height: 5),
              Container(
                height: 50,
                width: size,
                child: TextFormField(
                  maxLines: 2,
                  minLines: 1,
                  textAlign: TextAlign.start,
                  readOnly: true,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none),
                  controller: textController,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
