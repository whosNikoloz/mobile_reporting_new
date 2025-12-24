import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_reporting/api/response_models/bill_details_response_model.dart';
import 'package:mobile_reporting/application_store.dart';
import 'package:mobile_reporting/models/bill_model.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key, required this.bill, required this.billDetails});

  final BillModel bill;

  final BillDetailsResponseModel billDetails;

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  bool isFastFood = application.isFastFood ?? false;

  @override
  Widget build(BuildContext context) {
    double sum = 0;
    for (var element in widget.billDetails.products) {
      sum += element.quantity * element.price;
    }

    double paidCash = 0;
    widget.billDetails.payments
        .where((element) => element.isCash == true)
        .forEach(
          (e) => paidCash += e.amount,
        );

    double paidCard = 0;
    widget.billDetails.payments
        .where((element) => element.isCash == false)
        .forEach(
          (e) => paidCard += e.amount,
        );

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            child: Row(
              children: [
                Text(
                  'ჩეკის ნომერი',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  widget.bill.docNum,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            child: Row(
              children: [
                Text(
                  'ფილიალი',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  widget.bill.storeName,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          if (!isFastFood)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5,
              ),
              child: Row(
                children: [
                  Text(
                    'დარბაზი',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.bill.roomName,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          if (!isFastFood)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5,
              ),
              child: Row(
                children: [
                  Text(
                    'მიმტანი',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.bill.userName,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              top: 5,
              bottom: 10,
            ),
            child: Row(
              children: [
                Text(
                  'თარიღი',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd MMM yyyy - HH:mm').format(widget.bill.tdate),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 0,
            color: Colors.grey.shade500,
            indent: 7,
            endIndent: 7,
          ),
          ListView.separated(
            separatorBuilder: (context, index) => Divider(
              height: 0,
              color: Colors.grey.shade500,
              indent: 7,
              endIndent: 7,
            ),
            shrinkWrap: true,
            itemCount: widget.billDetails.products.length,
            itemBuilder: (context, index) {
              double total =
                  widget.billDetails.products.elementAt(index).price *
                      widget.billDetails.products.elementAt(index).quantity;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.billDetails.products.elementAt(index).name,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${widget.billDetails.products.elementAt(index).quantity.floor().toString()} x ${widget.billDetails.products.elementAt(index).price.toStringAsFixed(2)} ₾',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: total.floor().toString(),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 20,
                            ),
                          ),
                          TextSpan(
                            text:
                                '.${total.toStringAsFixed(2).substring(total.toStringAsFixed(2).length - 2)} ₾',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Divider(
            height: 0,
            color: Colors.grey.shade500,
            indent: 7,
            endIndent: 7,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            child: Row(
              children: [
                const Spacer(),
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'ჯამი: ${sum.floor().toString()}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 18,
                        ),
                      ),
                      TextSpan(
                        text:
                            '.${sum.toStringAsFixed(2).substring(sum.toStringAsFixed(2).length - 2)} ₾',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (paidCard != 0)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              child: Row(
                children: [
                  const Spacer(),
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              'გადახდა ბარათით: ${paidCard.floor().toString()}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text:
                              '.${paidCard.toStringAsFixed(2).substring(paidCard.toStringAsFixed(2).length - 2)} ₾',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (paidCash != 0)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              child: Row(
                children: [
                  const Spacer(),
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              'გადახდა ნაღდით: ${paidCash.floor().toString()}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text:
                              '.${paidCash.toStringAsFixed(2).substring(paidCash.toStringAsFixed(2).length - 2)} ₾',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
      appBar: AppBar(
        leading: IconButton(
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Colors.grey.shade900,
        titleSpacing: 0,
        title: Text(
          '#${widget.bill.docNum}',
          style: TextStyle(
            color: Colors.grey.shade300,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}
