import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logistic/models/payment.dart';
import 'package:logistic/repositories/services_repository.dart';
import 'package:logistic/utils/utils.dart';
import 'package:logistic/routes.dart';
import 'package:logistic/utils/navigation_services.dart';

import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../widgets/widgets.dart';

class PaymentType extends StatefulWidget {
  final GlobalKey sheet;
  final Function closeSheet;
  final int driverId;
  final int preorderId;

  const PaymentType({
    super.key,
    required this.sheet, 
    required this.closeSheet,
    required this.driverId,
    required this.preorderId,
  });

  @override
  State<PaymentType> createState() => _PaymentTypeState();
}

class _PaymentTypeState extends State<PaymentType> {
  var selectedId = 0;
  var type = [
    PaymentCategory(title: "", image: AssetImages.paymeImage, id: 1),
    PaymentCategory(title: "", image: AssetImages.uzumImage, id: 2),
    PaymentCategory(title: "", image: AssetImages.clickImage, id: 3),
  ];
  bool _isLoading = false;
  final ServicesRepository _repository = ServicesRepository();
  
  String _getPaymentTypeString(int id) {
    switch (id) {
      case 1:
        return "payme";
      case 2:
        return "uzum";
      case 3:
        return "click";
      case 4:
        return "cash";
      default:
        return "";
    }
  }
  
  Future<void> _createOrder() async {
    if (selectedId == 0) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      String paymentType = _getPaymentTypeString(selectedId);
      var result = await _repository.createOrder(
        widget.driverId,
        widget.preorderId,
        paymentType,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      // Show success message and close
      Services.showSnackBar(context, "Buyurtma muvaffaqiyatli yaratildi", AppColor.primary);
      widget.closeSheet();
      
      // Navigate back to main screen - it will refresh automatically via initState
      // Use pushReplacement to ensure MainScreen refreshes
      Navigator.of(context).pushReplacementNamed(Routes.mainScreen);
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Show error message
      Services.showSnackBar(context, e.toString(), AppColor.errorRed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            // blurRadius: 8.0,
            spreadRadius: 1,
            blurRadius: 5,
            color: AppColor.black.withOpacity(0.2),
            offset: const Offset(1.0, 1.0),
          ),
        ]),
        child: DraggableScrollableSheet(
          key: widget.sheet,
          initialChildSize: 0.8,
          minChildSize: 0.7,
          maxChildSize: 0.9,
          snap: false,
          snapSizes: const [0.8],
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
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  // padding: EdgeInsets.symmetric(horizontal: 35, vertical: 25),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                onPressed: () {
                                  widget.closeSheet();
                                },
                                icon: const Icon(Icons.close)),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              Text(
                                "To'lov usulini tanlang",
                                style: boldBlack.copyWith(fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Buyurtmani yakunlash uchun to'lov usulini tanlang",
                                style: regularText.copyWith(
                                  fontSize: 14,
                                  color: AppColor.secondaryText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        ...type.map((e) => typeItem(e)),
                        // const SizedBox(height: 20),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 25),
                             child: Text("Boshqa usullar",
                                  style: mediumBlack.copyWith(fontSize: 15),
                                  textAlign: TextAlign.left),
                           ),
                         ],
                       ),
                       typeItem(PaymentCategory(title: "", image: AssetImages.cash, id: 4)),
                        
                        // rowText("Sement", "6 880 000so‘m"),
                        // rowText("Yuk tashish mashinasi", "120 000so‘m"),
                        // const SizedBox(height: 25),

                        const SizedBox(height: 35),
                        DefaultButton(
                          disable: selectedId == 0 || _isLoading,
                          title: _isLoading ? "Kuting..." : "Tayyor",
                          onPress: () {
                            _createOrder();
                          },
                        )
                      ],
                    ),
                  )),
            );
          },
        ),
      ),
    );
  }
 
 Widget typeItem(type) {
   bool isSelected = type.id == selectedId;
   return Container(
     padding: const EdgeInsets.symmetric(horizontal: 16),
     child: Column(
       children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                width: 100,
                child: Image.asset(type.image,fit: type.id == 4 ? BoxFit.contain : BoxFit.cover)),
                type.id == 4 ? Text("Naqd tolov",style: regularText.copyWith(fontSize: 13),) : Container()
            ],
          ),
          IconButton(onPressed: (){
            setState(() {
              selectedId = type.id;
            });
          }, icon: Icon(isSelected ? Icons.check_circle: Icons.circle), color: isSelected ?AppColor.primary:AppColor.grayText,iconSize: 30,)
         ],),
        type.id < 3 ? const Divider(thickness: 1,color: AppColor.gray): const SizedBox(),
       ],
  
     ),
   );
 }

}