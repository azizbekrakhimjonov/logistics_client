import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logistic/constants/app_text_style.dart';
import 'package:logistic/utils/navigation_services.dart';
import 'package:logistic/utils/shared_pref.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/constants.dart';
import '../../models/user_content.dart';
import '../../routes.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final Uri _url = Uri.parse('https://flutter.dev');
  late UserContent? userData;


  Widget buildListTile(String title, String icon, Function tapHandler) {
    return ListTile(
      splashColor: AppColor.primary.withOpacity(0.3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 35),
      leading: SvgPicture.asset(icon, width: 35, height: 35),
      title: Text(title, style: mediumBlack.copyWith(fontSize: 18)),
      onTap: () => tapHandler(),
    );
  }
   @override
  void didChangeDependencies() async {
    getUser();
    super.didChangeDependencies();
  }

  void getUser() async {
    print("object");
    dynamic user = await SharedPref().read("user");
    setState(() {
      userData = UserContent.fromJson(user);
      debugPrint("userData: $userData");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            color: AppColor.primary,
            // padding: EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            child: Stack(
              children: <Widget>[
                SvgPicture.asset(
                  AssetImages.drawerLayer,
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height * 0.33,
                ),
                Container(
                  child: const Column(
                    children: <Widget>[],
                  ),
                ),
                Positioned(
                  top: 66,
                  left: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width:
                            84, // Adjust the width and height as per your requirement
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3.0,
                          ),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl:
                                userData!.user.picCompress??"",
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    const CupertinoActivityIndicator(),
                            // CircularProgressIndicator(value: downloadProgress.progress),
                            errorWidget: (context, url, error) =>
                                Image.asset(AssetImages.defaultImage,fit: BoxFit.cover),

                          ),
                          // Image.network(
                          //   "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                          //   fit: BoxFit.cover,
                          //   errorBuilder: (context, url, error) => Image.asset(
                          //       AssetImages.defaultImage,
                          //       height: 84,
                          //       width: 84,
                          //       fit: BoxFit.fill),
                          // ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: 300,
                        child: Text(
                         userData?.user.name ?? "",
                          style: mediumBlack.copyWith(
                              fontSize: 23, color: AppColor.white),
                          maxLines: 2,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          buildListTile(
            'myOrders'.tr(),
            AssetImages.order,
            () {
              Navigator.pushNamed(context, Routes.myOrders);
            },
          ),
          buildListTile(
            'account'.tr(),
            AssetImages.profile,
            () {
               Navigator.pushNamed(context, Routes.account);
            },
          ),
          buildListTile(
              'driver'.tr(),
              AssetImages.driver,
              // () {
              _launchUrl
              // },
              ),
          buildListTile(
            'settings'.tr(),
            AssetImages.setting,
            () {
              Navigator.pushNamed(context, Routes.languageChange);
            },
          ),
          buildListTile(
            'help'.tr(),
            AssetImages.info,
            () {
              Navigator.of(context).pop();
            },
          ),
          const Spacer(),
          // Expanded(
          //   child: Container(),
          // ),
          Padding(
            padding: const EdgeInsets.all(35.0),
            child: OutlinedButton(
              onPressed: () async {
                SharedPref().remove("token");
                SharedPref().remove("refresh_token");
                SharedPref().remove("user");

                Navigator.pushNamedAndRemoveUntil(
                    context, Routes.login, (route) => false);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColor.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text("exit".tr(),
                  style: mediumBlack.copyWith(
                      color: AppColor.secondaryText, fontSize: 20)),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
}
