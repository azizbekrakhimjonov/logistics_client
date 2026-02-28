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
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final Uri _url = Uri.parse('https://flutter.dev');
  late UserContent? userData;


  Widget _buildDrawerName(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) {
      return const SizedBox.shrink();
    }
    final parts = trimmed.split(RegExp(r'\s+'));
    final nameWidget = parts.length >= 2
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                parts.first,
                style: boldBlack.copyWith(
                  fontSize: 23,
                  color: AppColor.white,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                parts.sublist(1).join(" "),
                style: boldBlack.copyWith(
                  fontSize: 23,
                  color: AppColor.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          )
        : Text(
            trimmed,
            style: boldBlack.copyWith(
              fontSize: 23,
              color: AppColor.white,
            ),
            textAlign: TextAlign.center,
          );
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 24, right: 24),
      child: nameWidget,
    );
  }

  Widget buildListTile(String title, String icon, Function tapHandler) {
    return ListTile(
      splashColor: AppColor.primary.withOpacity(0.3),
      contentPadding: EdgeInsets.symmetric(horizontal: 35),
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
      userData = UserContent.fromJsonSafe(user);
      debugPrint("userData: ${userData}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.38,
            width: double.infinity,
            color: AppColor.primary,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          border: Border.all(
                            color: AppColor.white,
                            width: 3.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: userData?.user.picCompress ?? "",
                            fit: BoxFit.cover,
                            width: 96,
                            height: 96,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    const Center(
                                        child: CupertinoActivityIndicator(
                                            color: AppColor.white)),
                            errorWidget: (context, url, error) =>
                                Image.asset(AssetImages.defaultImage,
                                    fit: BoxFit.cover, width: 96, height: 96),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildDrawerName(userData?.user.name ?? ""),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
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
              Navigator.pushNamed(context, Routes.help);
            },
          ),
          Spacer(),
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
              child: Text("exit".tr(),
                  style: mediumBlack.copyWith(
                      color: AppColor.secondaryText, fontSize: 20)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColor.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
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
