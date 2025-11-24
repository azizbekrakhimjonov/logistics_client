import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logistic/constants/app_text_style.dart';
import 'package:logistic/constants/colors.dart';
import 'package:logistic/constants/images.dart';
import 'package:logistic/models/user_content.dart';
import 'package:logistic/screens/auth/account/bloc/account_bloc.dart';
import 'package:logistic/utils/services.dart';
import 'package:logistic/widgets/custom_loading.dart';

import '../../../utils/shared_pref.dart';
import '../../../widgets/widgets.dart';

class AccountAppBar extends StatefulWidget {
  const AccountAppBar({Key? key}) : super(key: key);
  static const String routeName = "account";

  @override
  State<AccountAppBar> createState() => _AccountAppBarState();
}

class _AccountAppBarState extends State<AccountAppBar> {
  final _username = TextEditingController(text: "");
  final _phone = TextEditingController();
  FocusNode focusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late UserContent userData;
  XFile? imageFile;
  final AccountBloc _bloc = AccountBloc();

  @override
  void didChangeDependencies() {
    getUser();
    super.didChangeDependencies();
  }

  void getUser() async {
    dynamic user = await SharedPref().read("user");
    setState(() {
      userData = UserContent.fromJson(user);
      _username.text = userData.user.name ?? "";
      _phone.text = userData.user.username;
    });
    print("phone:${_phone.text}");
  }

  void pickedFile(pickedFile) {
    setState(() {
      imageFile = pickedFile!;
    });
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: AppColor.primary, // Set your desired color here
    // ));
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColor.primary,
        statusBarIconBrightness: Brightness.light,
      ),
      child: BlocProvider.value(
        value: _bloc,
        child: Scaffold(
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(focusNode);
            },
            child: BlocConsumer<AccountBloc, AccountState>(
              listener: (context, state) {
                 if (state is AccountLoading) {
                   CustomLoadingDialog.show(context);
                 } else if (state is AccountSuccessState) {
                   CustomLoadingDialog.hide(context);
                 } else if (state is AccountErrorState){
                   CustomLoadingDialog.hide(context);
                   Services.showSnackBar(context, state.message, AppColor.red);
                 }
              },
              builder: (context, state) {
                return Material(
                  child: CustomScrollView(
                    // physics: NeverScrollableScrollPhysics(),
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: MySliverAppBar(
                            expandedHeight: 110.0,
                            userData: userData.user,
                            imageFile: imageFile,
                            pickedFile: pickedFile),
                      ),
                      SliverToBoxAdapter(
                          child: SingleChildScrollView(
                        reverse: true,
                        child: Container(
                          child: Form(
                            key: _formKey,
                            child: Column(children: [
                              const SizedBox(
                                height: 50,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 21.0),
                                child: InputField(
                                  title: "name".tr(),
                                  value: _username,
                                  onChange: () {},
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                  maxLength: 25,
                                  hint: userData.user.name ?? "",
                                  radius: 17,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 21.0),
                                child: InputField(
                                  title: "phone".tr(),
                                  value: _phone,
                                  onChange: () {},
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.phone,
                                  maxLength: 13,
                                  hint: userData.user.username,
                                  radius: 17,
                                  readOnly: true,
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ))
                    ],
                  ),
                );
              },
            ),
          ),
          floatingActionButton: Container(
            margin: EdgeInsets.symmetric(vertical: 30),
            height: 50,
            child: DefaultButton(
                disable: false,
                title: "save".tr(),
                onPress: () {
                  _bloc.add(EditProfileEvent(
                      photo: imageFile?.path ?? '',
                      name: _username.text,
                      phoneNumber: userData.user.username));
                }),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }
}

class MySliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final User userData;
  final XFile? imageFile;
  final ImagePicker _picker = ImagePicker();
  final ValueChanged<XFile?> pickedFile;

  MySliverAppBar(
      {required this.expandedHeight,
      required this.imageFile,
      required this.userData,
      required this.pickedFile});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(color: AppColor.primary),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColor.white,
            ),
          ),
        ),
        Center(
          child: Opacity(
            opacity: shrinkOffset / expandedHeight,
            child: Text(
              'account_settings'.tr(),
              style: boldBlack.copyWith(color: AppColor.white, fontSize: 25),
              maxLines: 2,
            ),
          ),
        ),
        Positioned(
          top: expandedHeight / 4 - shrinkOffset,
          right: 30, //MediaQuery.of(context).size.width / 4,
          left: MediaQuery.of(context).size.width / 7,
          child: Opacity(
            opacity: (1 - shrinkOffset / expandedHeight),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      'account_settings'.tr(),
                      style: boldBlack.copyWith(
                          color: AppColor.white, fontSize: 25),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 5),
                  ],
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Column(
                  children: [
                    SizedBox(height: 10),
                    Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: SizedBox(
                        height: 85,
                        width: 85,
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: ((builder) => bottomSheet()),
                            );
                          },
                          child: CircleAvatar(
                            radius: 58,
                            backgroundImage: _image("state"),
                            backgroundColor: AppColor.gray,
                            child: Stack(children: [
                              Align(
                                alignment: Alignment.bottomRight,
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white,
                                  child: Center(
                                      child: IconButton(
                                    focusColor: AppColor.orange,
                                    icon: Icon(
                                      Icons.camera_alt_rounded,
                                      color: AppColor.primary,
                                    ),
                                    onPressed: () {
                                      // print("press");
                                      // showModalBottomSheet(
                                      //   context: context,
                                      //   builder: ((builder) => bottomSheet()),
                                      // );
                                    },
                                  )),
                                ),
                              ),
                            ]),
                          ),
                        ),

                        // CircularProfileAvatar(
                        //   '',
                        //   child: Image.asset(
                        //     AssetImages.defaultImage,
                        //     fit: BoxFit.fill,
                        //   ),
                        //   radius: 85,
                        //   backgroundColor: Colors.transparent,
                        //   borderColor: Colors.white,
                        //   borderWidth: 4,
                        // ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _image(state) {
    if (imageFile == null) {
      if (userData.url != '') {
        print("user:${userData.url}");
        return CachedNetworkImageProvider(
          userData.url,
          errorListener: (p0) => AssetImage(
            AssetImages.defaultImage,
          ) as ImageProvider,
        );
      } else {
        return AssetImage(
          AssetImages.defaultImage,
        ) as ImageProvider;
      }
    } else {
      return FileImage(File(imageFile!.path)) as ImageProvider;
    }
  }

  Widget bottomSheet() {
    return Container(
      height: 150.0,
      width: double.infinity, // MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      child: Column(
        children: <Widget>[
          Text("Profil rasmini tanlang".tr(),
                  style: boldBlack.copyWith(fontSize: 20))
              .tr(),
          SizedBox(height: 20),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _button("Kameradan".tr(), () => takePhoto(ImageSource.camera),
                    Icons.camera),
                SizedBox(height: 20),
                _button("Gallareyadan".tr(), () => takePhoto(ImageSource.gallery),
                    Icons.image),
              ])
        ],
      ),
    );
  }

  Widget _button(String title, Function func, dynamic icon) {
    return InkWell(
      onTap: () => func(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: AppColor.primary),
          SizedBox(width: 10),
          Text(title, style: boldBlack).tr()
        ],
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    final XFile? pickedFiles = await _picker.pickImage(
      source: source,
    );
    pickedFile(pickedFiles);
    // setState(() {
    //   _imageFile = pickedFile!;
    // });
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
