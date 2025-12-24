import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:mobile_reporting/api/response_models/bill_response_model.dart';
import 'package:mobile_reporting/application_store.dart';
import 'package:mobile_reporting/enums/screen_type.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/models/bill_model.dart';
import 'package:mobile_reporting/screens/bill_screen.dart';
import 'package:mobile_reporting/screens/splash_screen.dart';
import 'package:mobile_reporting/services/bill_service.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:mobile_reporting/widgets/picker_widget.dart';

class BillsMainScreen extends StatefulWidget {
  const BillsMainScreen({super.key});

  @override
  State<BillsMainScreen> createState() => _BillsMainScreenState();
}

class _BillsMainScreenState extends State<BillsMainScreen> {
  final BillService _billService = BillService();

  List<BillModel> bills = [];
  double minimumAmount = 0;
  double maximumAmount = 0;
  String billNum = '';
  int? isLoading;

  DateTime date1 = DateTime.now();
  DateTime date2 = DateTime.now();
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: PickerWidget(
              screenType: ScreenType.billsScreen,
              showDateTypeChoose: false,
              showStoreFilter: true,
              showOldDate: false,
              getDate: (DateTime dt1,
                  DateTime dt2,
                  DateTime dt3,
                  DateTime dt4,
                  double? minimumAmount,
                  double? maximumAmount,
                  String? billNum) async {
                date1 = dt1;
                date2 = dt2;
                await updateBills(
                    dt1: dt1,
                    dt2: dt2,
                    minAmount: minimumAmount,
                    maxAmount: maximumAmount,
                    billNum: billNum);
              },
              onlyDayPicker: false,
            ),
          ),
          const Divider(
            height: 0,
            color: AppTheme.dividerColor,
            indent: 7,
            endIndent: 7,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 30,
                  child: TextField(
                    controller: searchController,
                    focusNode: searchFocus,
                    onTapOutside: (a) {
                      searchFocus.unfocus();
                    },
                    onChanged: (value) {
                      for (var element in bills) {
                        element.isVisible = true;
                      }
                      bills
                          .where((element) =>
                              !element.docNum.contains(value) &&
                              !element.userName.contains(value) &&
                              !element.amount
                                  .toStringAsFixed(2)
                                  .contains(value))
                          .forEach((element) {
                        element.isVisible = false;
                      });
                      setState(() {});
                    },
                    style: const TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 18,
                    ),
                    cursorColor: AppTheme.primaryBlue,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      hintText: 'ძებნა',
                      hintStyle: const TextStyle(
                        color: AppTheme.hintTextColor,
                        fontSize: 16,
                      ),
                      isDense: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: AppTheme.borderColor,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: AppTheme.borderColor,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: AppTheme.primaryBlue,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 0,
            color: AppTheme.dividerColor,
            indent: 7,
            endIndent: 7,
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                BillModel bill = application.selectedStoreId == null
                    ? bills
                        .where((element) => element.isVisible == true)
                        .elementAt(index)
                    : bills
                        .where((element) =>
                            element.isVisible == true &&
                            element.storeName ==
                                application.stores
                                    .firstWhere((element) =>
                                        element.id ==
                                        application.selectedStoreId)
                                    .name)
                        .elementAt(index);
                return InkWell(
                  onTap: () async {
                    if (isLoading == null) {
                      isLoading = index;
                      setState(() {});
                      await openBillDetails(billId: bill.id);
                      isLoading = null;
                      setState(() {});
                    }
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppTheme.dividerColor,
                          width: 0.5,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 130,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat("dd-MMM-yy HH:mm")
                                    .format(bill.tdate),
                                style: const TextStyle(
                                  color: AppTheme.secondaryTextColor,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '#${bill.docNum}',
                                style: const TextStyle(
                                  color: AppTheme.primaryTextColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 210,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bill.storeName,
                                style: const TextStyle(
                                  color: AppTheme.primaryTextColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                bill.userName,
                                style: const TextStyle(
                                  color: AppTheme.secondaryTextColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        isLoading == null || isLoading != index
                            ? RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: bill.amount.floor().toString(),
                                      style: const TextStyle(
                                        color: AppTheme.primaryBlue,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          '.${bill.amount.toStringAsFixed(2).substring(bill.amount.toStringAsFixed(2).length - 2)}',
                                      style: const TextStyle(
                                        color: AppTheme.primaryBlue,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SpinKitRing(
                                color: AppTheme.primaryBlue,
                                size: 25.0,
                                lineWidth: 3,
                              ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: application.selectedStoreId == null
                  ? bills.where((element) => element.isVisible == true).length
                  : bills
                      .where((element) =>
                          element.storeName ==
                              application.stores
                                  .firstWhere((element) =>
                                      element.id == application.selectedStoreId)
                                  .name &&
                          element.isVisible == true)
                      .length,
            ),
          ),
        ],
      );
  }

  Future<void> updateBills(
      {required DateTime dt1,
      required DateTime dt2,
      double? minAmount,
      double? maxAmount,
      String? billNum}) async {
    List<BillResponseModel> billsTemp = await _billService.getBills(
      startDate: dt1,
      endDate: dt2,
      minAmount: minAmount,
      maxAmount: maxAmount,
      billNum: billNum,
    );

    bills.clear();
    for (var e in billsTemp) {
      bills.add(BillModel(
          amount: e.amount,
          docNum: e.docNum,
          id: e.id,
          orderType: e.orderType,
          roomName: e.roomName,
          storeName: e.storeName,
          tdate: e.tdate,
          userName: e.userName));
    }
    setState(() {});
  }

  Future<void> openBillDetails({required int billId}) async {
    String? authToken = await getIt<PreferencesHelper>().getUserAuthToken();
    if (authToken == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const SplashScreen()));
      return;
    }

    final billDetails = await _billService.getBillDetails(billId: billId);

    if (billDetails == null) {
      return;
    }

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillScreen(
          bill: bills.where((element) => element.id == billId).first,
          billDetails: billDetails,
        ),
      ),
    );
  }
}
