import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ndialog/ndialog.dart';
import 'package:mobile_reporting/theme/app_theme.dart';

TextEditingController pinTextController = TextEditingController();

Future<double?> showCalculatorDialog(
    {required String header, required String initialAmount, required context, required bool hasDotButton}) async {
  FocusNode pinCodeFocusNode = FocusNode();
  bool calcIsClean = true;
  pinTextController.text = initialAmount.toString();
  double? amount = await NDialog(
    dialogStyle: DialogStyle(
      titleDivider: true,
      backgroundColor: Colors.grey.shade900,
    ),
    content: StatefulBuilder(
      builder: (context, setState) {
        pinCodeFocusNode.requestFocus();
        return SizedBox(
          width: Platform.isWindows ? 350 : MediaQuery.of(context).size.width,
          child: Wrap(
            children: [
              const SizedBox(
                height: 10,
                width: 10,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 30,
                  ),
                  const Spacer(),
                  Text(
                    header,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    splashRadius: 25,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.close_outlined,
                      color: AppTheme.primaryBlue,
                    ),
                    onPressed: () {
                      Navigator.pop(context, null);
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
                width: 10,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: Platform.isWindows ? 17 : 0,
                ),
                height: 50.0,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primaryBlue,
                    width: 2,
                  ),
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: TextField(
                    focusNode: Platform.isWindows ? pinCodeFocusNode : null,
                    inputFormatters: <TextInputFormatter>[
                      hasDotButton
                          ? FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
                          : FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                      FilteringTextInputFormatter.deny(RegExp('^00+')),
                      FilteringTextInputFormatter.deny(RegExp('^01+')),
                      FilteringTextInputFormatter.deny(RegExp('^02+')),
                      FilteringTextInputFormatter.deny(RegExp('^03+')),
                      FilteringTextInputFormatter.deny(RegExp('^04+')),
                      FilteringTextInputFormatter.deny(RegExp('^05+')),
                      FilteringTextInputFormatter.deny(RegExp('^06+')),
                      FilteringTextInputFormatter.deny(RegExp('^07+')),
                      FilteringTextInputFormatter.deny(RegExp('^08+')),
                      FilteringTextInputFormatter.deny(RegExp('^09+')),
                    ],
                    keyboardType: hasDotButton ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
                    autofocus: Platform.isWindows ? true : false,
                    readOnly: Platform.isWindows ? false : true,
                    onSubmitted: (e) {
                      Navigator.pop(context, double.parse(pinTextController.text));
                    },
                    controller: pinTextController,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 20,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
                width: 10,
              ),
              SizedBox(
                child: StaggeredGrid.count(
                  axisDirection: AxisDirection.down,
                  crossAxisCount: 9,
                  mainAxisSpacing: 3,
                  crossAxisSpacing: 3,
                  children: [
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 2,
                      child: getButton('1', onPressed: () {
                        if (pinTextController.text != '0') {
                          pinTextController.text += '1';
                        } else {
                          pinTextController.text = '1';
                        }
                        if (!Platform.isWindows && calcIsClean) {
                          pinTextController.text = '1';
                          calcIsClean = false;
                        }
                        setState(() {});
                      }, context: context),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 2,
                      child: getButton('2', onPressed: () {
                        if (pinTextController.text != '0') {
                          pinTextController.text += '2';
                        } else {
                          pinTextController.text = '2';
                        }
                        if (!Platform.isWindows && calcIsClean) {
                          pinTextController.text = '2';
                          calcIsClean = false;
                        }
                        setState(() {});
                      }, context: context),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 2,
                      child: getButton('3', onPressed: () {
                        if (pinTextController.text != '0') {
                          pinTextController.text += '3';
                        } else {
                          pinTextController.text = '3';
                        }
                        if (!Platform.isWindows && calcIsClean) {
                          pinTextController.text = '3';
                          calcIsClean = false;
                        }
                        setState(() {});
                      }, context: context),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 3,
                      mainAxisCellCount: 2,
                      child: getButton(
                        '<<',
                        onPressed: () {
                          if (pinTextController.text.isNotEmpty) {
                            pinTextController.text = pinTextController.text.substring(0, pinTextController.text.length - 1);
                          }
                          setState(() {});
                        },
                        context: context,
                      ),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 2,
                      child: getButton('4', onPressed: () {
                        if (pinTextController.text != '0') {
                          pinTextController.text += '4';
                        } else {
                          pinTextController.text = '4';
                        }
                        if (!Platform.isWindows && calcIsClean) {
                          pinTextController.text = '4';
                          calcIsClean = false;
                        }
                        setState(() {});
                      }, context: context),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 2,
                      child: getButton('5', onPressed: () {
                        if (pinTextController.text != '0') {
                          pinTextController.text += '5';
                        } else {
                          pinTextController.text = '5';
                        }
                        if (!Platform.isWindows && calcIsClean) {
                          pinTextController.text = '5';
                          calcIsClean = false;
                        }
                        setState(() {});
                      }, context: context),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 2,
                      child: getButton('6', onPressed: () {
                        if (pinTextController.text != '0') {
                          pinTextController.text += '6';
                        } else {
                          pinTextController.text = '6';
                        }
                        if (!Platform.isWindows && calcIsClean) {
                          pinTextController.text = '6';
                          calcIsClean = false;
                        }
                        setState(() {});
                      }, context: context),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 3,
                      mainAxisCellCount: 6,
                      child: getButton(
                        'OK',
                        onPressed: () {
                          Navigator.pop(context, double.parse(pinTextController.text));
                        },
                        context: context,
                      ),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 2,
                      child: getButton('7', onPressed: () {
                        if (pinTextController.text != '0') {
                          pinTextController.text += '7';
                        } else {
                          pinTextController.text = '7';
                        }
                        if (!Platform.isWindows && calcIsClean) {
                          pinTextController.text = '7';
                          calcIsClean = false;
                        }
                        setState(() {});
                      }, context: context),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 2,
                      child: getButton('8', onPressed: () {
                        if (pinTextController.text != '0') {
                          pinTextController.text += '8';
                        } else {
                          pinTextController.text = '8';
                        }
                        if (!Platform.isWindows && calcIsClean) {
                          pinTextController.text = '8';
                          calcIsClean = false;
                        }
                        setState(() {});
                      }, context: context),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 2,
                      child: getButton('9', onPressed: () {
                        if (pinTextController.text != '0') {
                          pinTextController.text += '9';
                        } else {
                          pinTextController.text = '9';
                        }
                        if (!Platform.isWindows && calcIsClean) {
                          pinTextController.text = '9';
                          calcIsClean = false;
                        }
                        setState(() {});
                      }, context: context),
                    ),
                    if (hasDotButton)
                      StaggeredGridTile.count(
                        crossAxisCellCount: 2,
                        mainAxisCellCount: 2,
                        child: getButton('.', onPressed: () {
                          if (!pinTextController.text.contains('.')) {
                            pinTextController.text += '.';
                          }
                          setState(() {});
                        }, context: context),
                      ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: hasDotButton ? 2 : 4,
                      mainAxisCellCount: 2,
                      child: getButton('0', onPressed: () {
                        if (pinTextController.text != '0') {
                          pinTextController.text += '0';
                        }
                        setState(() {});
                      }, context: context),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 2,
                      child: getButton('C', onPressed: () {
                        pinTextController.text = '';
                        calcIsClean = true;
                        setState(() {});
                      }, context: context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  ).show(context);

  return amount;
}

Widget getButton(String text, {required VoidCallback onPressed, required context}) {
  return SizedBox(
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        side: const BorderSide(
          width: 2.0,
          color: AppTheme.primaryBlue,
        ),
        backgroundColor: Colors.black38,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w500,
          fontSize: 25.0,
        ),
      ),
    ),
  );
}
