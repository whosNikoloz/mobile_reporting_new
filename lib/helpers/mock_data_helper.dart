import 'dart:math';
import 'package:mobile_reporting/models/hourly_sales_model.dart';
import 'package:mobile_reporting/models/report_group_and_value_model.dart';
import 'package:mobile_reporting/models/report_value_qty_model.dart';

class MockDataHelper {
  static final Random _random = Random();

  /// Generates mock data for restaurant dashboard
  static List<ReportGroupAndValueModel> getRestaurantMockData() {
    return [
      _createMockReport(
        tag: 'SALES',
        name: 'გაყიდვები',
        type: 'AMOUNT',
        currentValue: 15000 + _random.nextDouble() * 5000,
        oldValue: 12000 + _random.nextDouble() * 4000,
      ),
      _createMockReport(
        tag: 'RECEIPTS',
        name: 'ჩეკების რაოდენობა',
        type: 'COUNT',
        currentValue: 120 + _random.nextDouble() * 30,
        oldValue: 100 + _random.nextDouble() * 25,
      ),
      _createMockReport(
        tag: 'AVERAGE',
        name: 'საშუალო ჩეკი',
        type: 'AMOUNT',
        currentValue: 125 + _random.nextDouble() * 25,
        oldValue: 115 + _random.nextDouble() * 20,
      ),
      _createMockReport(
        tag: 'DISCOUNT',
        name: 'ფასდაკლება',
        type: 'AMOUNT',
        currentValue: 500 + _random.nextDouble() * 200,
        oldValue: 450 + _random.nextDouble() * 150,
      ),
      _createMockReport(
        tag: 'GUESTS',
        name: 'სტუმრები',
        type: 'COUNT',
        currentValue: 250 + _random.nextDouble() * 50,
        oldValue: 220 + _random.nextDouble() * 40,
      ),
      _createMockReport(
        tag: 'AVERAGETIME',
        name: 'საშუალო დრო',
        type: 'TIME',
        currentValue: 45 + _random.nextDouble() * 15,
        oldValue: 50 + _random.nextDouble() * 10,
      ),
      _createMockReport(
        tag: 'MONEY',
        name: 'შემოსული თანხა',
        type: 'AMOUNT',
        currentValue: 14500 + _random.nextDouble() * 4500,
        oldValue: 11800 + _random.nextDouble() * 3800,
      ),
    ];
  }

  /// Generates mock data for retail dashboard
  static List<ReportGroupAndValueModel> getRetailMockData() {
    return [
      _createMockReport(
        tag: 'RETAIL_SALES',
        name: 'რეალიზაცია',
        type: 'AMOUNT',
        currentValue: 25000 + _random.nextDouble() * 10000,
        oldValue: 20000 + _random.nextDouble() * 8000,
      ),
      _createMockReport(
        tag: 'RETAIL_PROFIT',
        name: 'მოგება',
        type: 'AMOUNT',
        currentValue: 5000 + _random.nextDouble() * 2000,
        oldValue: 4000 + _random.nextDouble() * 1500,
      ),
      _createMockReport(
        tag: 'RETAIL_DISCOUNT_AMOUNT',
        name: 'ფასდაკლება',
        type: 'AMOUNT',
        currentValue: 800 + _random.nextDouble() * 300,
        oldValue: 700 + _random.nextDouble() * 250,
      ),
      _createMockReport(
        tag: 'RETAIL_DISCOUNT_PERCENT',
        name: 'ფასდაკლების პროცენტი',
        type: 'PERCENT',
        currentValue: 3.2 + _random.nextDouble() * 1.5,
        oldValue: 3.5 + _random.nextDouble() * 1.0,
      ),
      _createMockReport(
        tag: 'RETAIL_AVERAGE',
        name: 'საშუალო ჩეკი',
        type: 'AMOUNT',
        currentValue: 85 + _random.nextDouble() * 20,
        oldValue: 75 + _random.nextDouble() * 15,
      ),
      _createMockReport(
        tag: 'RETAIL_SALES_CNT',
        name: 'ჩეკების რაოდენობა',
        type: 'COUNT',
        currentValue: 290 + _random.nextDouble() * 60,
        oldValue: 265 + _random.nextDouble() * 50,
      ),
      _createMockReport(
        tag: 'RETAIL_SERVICE_AMOUNT',
        name: 'გაწეული მომსახურება',
        type: 'AMOUNT',
        currentValue: 1200 + _random.nextDouble() * 400,
        oldValue: 1000 + _random.nextDouble() * 300,
      ),
      _createMockReport(
        tag: 'RETAIL_IN_AMOUNT',
        name: 'შემოსული თანხა',
        type: 'AMOUNT',
        currentValue: 24000 + _random.nextDouble() * 9500,
        oldValue: 19500 + _random.nextDouble() * 7500,
      ),
      _createMockReport(
        tag: 'RETAIL_OUT_MONEY',
        name: 'გასული თანხა',
        type: 'AMOUNT',
        currentValue: 500 + _random.nextDouble() * 200,
        oldValue: 450 + _random.nextDouble() * 150,
      ),
      _createMockReport(
        tag: 'RETAIL_IN_MONEY',
        name: 'შემოსული თანხა',
        type: 'AMOUNT',
        currentValue: 23500 + _random.nextDouble() * 9300,
        oldValue: 19050 + _random.nextDouble() * 7350,
      ),
      _createMockReport(
        tag: 'RETAIL_PURCHASE',
        name: 'შესყიდვები',
        type: 'AMOUNT',
        currentValue: 18000 + _random.nextDouble() * 6000,
        oldValue: 15000 + _random.nextDouble() * 5000,
      ),
      _createMockReport(
        tag: 'RETAIL_CUTOFF',
        name: 'ჩამოწერილი საქონელი',
        type: 'AMOUNT',
        currentValue: 300 + _random.nextDouble() * 100,
        oldValue: 280 + _random.nextDouble() * 90,
      ),
      _createMockReport(
        tag: 'RETAIL_REST',
        name: 'საქონელის ნაშთი',
        type: 'AMOUNT',
        currentValue: 45000 + _random.nextDouble() * 15000,
        oldValue: 42000 + _random.nextDouble() * 13000,
      ),
      _createMockReport(
        tag: 'RETAIL_RETURN_CUSTOMER',
        name: 'დაბრუნება მყიდველისგან',
        type: 'AMOUNT',
        currentValue: 200 + _random.nextDouble() * 80,
        oldValue: 180 + _random.nextDouble() * 70,
      ),
      _createMockReport(
        tag: 'RETAIL_RETURN_VENDOR',
        name: 'დაბრუნება მომწოდებლებთან',
        type: 'AMOUNT',
        currentValue: 150 + _random.nextDouble() * 60,
        oldValue: 140 + _random.nextDouble() * 50,
      ),
      _createMockReport(
        tag: 'RETAIL_DEBT_CUSTOMER',
        name: 'მყიდველების დავალიანება',
        type: 'AMOUNT',
        currentValue: 3500 + _random.nextDouble() * 1000,
        oldValue: 3200 + _random.nextDouble() * 900,
      ),
      _createMockReport(
        tag: 'RETAIL_DEBT_VENDOR',
        name: 'დავალიანება მომწოდებლებთან',
        type: 'AMOUNT',
        currentValue: 2800 + _random.nextDouble() * 800,
        oldValue: 2600 + _random.nextDouble() * 700,
      ),
    ];
  }

  /// Generates mock sales by days data for chart
  static ReportGroupAndValueModel getSalesByDaysMockData() {
    final daysInMonth = DateTime(
      DateTime.now().year,
      DateTime.now().month + 1,
      0,
    ).day;

    List<ReportValueQtyModel> dailySales = [];
    for (int day = 1; day <= daysInMonth; day++) {
      dailySales.add(
        ReportValueQtyModel(
          id: day,
          name: day.toString().padLeft(2, '0'),
          currentValue: 800 + _random.nextDouble() * 400,
          oldValue: 750 + _random.nextDouble() * 350,
          currentQuantity: 0,
          oldQuantity: 0,
        ),
      );
    }

    return ReportGroupAndValueModel(
      tag: 'SALES_BY_DAYS',
      name: 'გაყიდვები დღეებით',
      type: 'CHART',
      values: dailySales,
    );
  }

  /// Helper method to create a mock report with a single value
  static ReportGroupAndValueModel _createMockReport({
    required String tag,
    required String name,
    required String type,
    required double currentValue,
    required double oldValue,
  }) {
    return ReportGroupAndValueModel(
      tag: tag,
      name: name,
      type: type,
      values: [
        ReportValueQtyModel(
          id: -1,
          name: '',
          currentValue: currentValue,
          oldValue: oldValue,
          currentQuantity: 0,
          oldQuantity: 0,
        ),
      ],
    );
  }

  /// Simulates async data loading with delay
  static Future<List<ReportGroupAndValueModel>> getMockDataAsync({
    bool isRestaurant = true,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    await Future.delayed(delay);
    return isRestaurant ? getRestaurantMockData() : getRetailMockData();
  }

  /// Simulates async chart data loading with delay
  static Future<ReportGroupAndValueModel> getSalesByDaysMockDataAsync({
    Duration delay = const Duration(milliseconds: 300),
  }) async {
    await Future.delayed(delay);
    return getSalesByDaysMockData();
  }

  // ==================== NEW DESIGN DATA ====================

  /// Generates General section metrics for new dashboard design
  static List<ReportGroupAndValueModel> getGeneralMetrics() {
    double sales = 15000 + _random.nextDouble() * 5000;
    double sellcost = sales * (0.65 + _random.nextDouble() * 0.1); // 65-75% of sales
    double profit = sales - sellcost;
    double profitPercent = (profit / sales) * 100;

    return [
      _createMockReport(
        tag: 'SALES',
        name: 'Sales',
        type: 'AMOUNT',
        currentValue: sales,
        oldValue: sales * (0.8 + _random.nextDouble() * 0.2),
      ),
      _createMockReport(
        tag: 'SELLCOST',
        name: 'Sellcost',
        type: 'AMOUNT',
        currentValue: sellcost,
        oldValue: sellcost * (0.9 + _random.nextDouble() * 0.15),
      ),
      _createMockReport(
        tag: 'PROFIT_PERCENT',
        name: 'Profit %',
        type: 'PERCENT',
        currentValue: profitPercent,
        oldValue: profitPercent * (0.9 + _random.nextDouble() * 0.2),
      ),
      _createMockReport(
        tag: 'PROFIT',
        name: 'Profit',
        type: 'AMOUNT',
        currentValue: profit,
        oldValue: profit * (0.85 + _random.nextDouble() * 0.2),
      ),
      _createMockReport(
        tag: 'BILLS_COUNT',
        name: 'Bills Count',
        type: 'COUNT',
        currentValue: 200 + _random.nextDouble() * 100,
        oldValue: 180 + _random.nextDouble() * 80,
      ),
      _createMockReport(
        tag: 'AVG_CHECK',
        name: 'Avg Check',
        type: 'AMOUNT',
        currentValue: 120 + _random.nextDouble() * 30,
        oldValue: 110 + _random.nextDouble() * 25,
      ),
      _createMockReport(
        tag: 'DISCOUNT',
        name: 'Discount',
        type: 'AMOUNT',
        currentValue: 400 + _random.nextDouble() * 200,
        oldValue: 350 + _random.nextDouble() * 180,
      ),
      _createMockReport(
        tag: 'REFUND',
        name: 'Refund',
        type: 'AMOUNT',
        currentValue: 200 + _random.nextDouble() * 150,
        oldValue: 180 + _random.nextDouble() * 120,
      ),
    ];
  }

  /// Generates Payments section metrics for new dashboard design
  static List<ReportGroupAndValueModel> getPaymentMetrics() {
    double totalSales = 15000 + _random.nextDouble() * 5000;
    double cash = totalSales * (0.3 + _random.nextDouble() * 0.2);
    double card = totalSales * (0.4 + _random.nextDouble() * 0.2);
    double consignation = totalSales * (0.1 + _random.nextDouble() * 0.1);
    double loyalty = totalSales * (0.05 + _random.nextDouble() * 0.05);

    return [
      _createMockReport(
        tag: 'CASH',
        name: 'Cash',
        type: 'AMOUNT',
        currentValue: cash,
        oldValue: cash * (0.85 + _random.nextDouble() * 0.25),
      ),
      _createMockReport(
        tag: 'CARD',
        name: 'Card',
        type: 'AMOUNT',
        currentValue: card,
        oldValue: card * (0.9 + _random.nextDouble() * 0.2),
      ),
      _createMockReport(
        tag: 'CONSIGNATION',
        name: 'Consignation',
        type: 'AMOUNT',
        currentValue: consignation,
        oldValue: consignation * (0.8 + _random.nextDouble() * 0.3),
      ),
      _createMockReport(
        tag: 'LOYALTY',
        name: 'Loyalty',
        type: 'AMOUNT',
        currentValue: loyalty,
        oldValue: loyalty * (0.85 + _random.nextDouble() * 0.25),
      ),
    ];
  }

  /// Generates Sales by Hours data for chart
  static List<HourlySalesModel> getSalesByHoursMockData() {
    return [
      HourlySalesModel(
        timeRange: '8:00-9:59',
        value: 30 + _random.nextDouble() * 20,
      ),
      HourlySalesModel(
        timeRange: '10:00-11:59',
        value: 40 + _random.nextDouble() * 20,
      ),
      HourlySalesModel(
        timeRange: '12:00-13:59',
        value: 60 + _random.nextDouble() * 30,
      ),
      HourlySalesModel(
        timeRange: '14:00-15:59',
        value: 45 + _random.nextDouble() * 25,
      ),
      HourlySalesModel(
        timeRange: '16:00-17:59',
        value: 55 + _random.nextDouble() * 30,
      ),
      HourlySalesModel(
        timeRange: '18:00-19:59',
        value: 70 + _random.nextDouble() * 30,
      ),
      HourlySalesModel(
        timeRange: '20:00-21:59',
        value: 80 + _random.nextDouble() * 20,
      ),
    ];
  }
}
