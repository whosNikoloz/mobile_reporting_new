// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `All Stores`
  String get allBranches {
    return Intl.message('All Stores', name: 'allBranches', desc: '', args: []);
  }

  /// `Apr`
  String get aprShort {
    return Intl.message('Apr', name: 'aprShort', desc: '', args: []);
  }

  /// `Aug`
  String get augShort {
    return Intl.message('Aug', name: 'augShort', desc: '', args: []);
  }

  /// `AvgCheck`
  String get averageCheck {
    return Intl.message('AvgCheck', name: 'averageCheck', desc: '', args: []);
  }

  /// `Avg Check`
  String get avgCheck {
    return Intl.message('Avg Check', name: 'avgCheck', desc: '', args: []);
  }

  /// `Bills`
  String get bills {
    return Intl.message('Bills', name: 'bills', desc: '', args: []);
  }

  /// `Locations`
  String get branches {
    return Intl.message('Locations', name: 'branches', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Card`
  String get card {
    return Intl.message('Card', name: 'card', desc: '', args: []);
  }

  /// `Cash`
  String get cash {
    return Intl.message('Cash', name: 'cash', desc: '', args: []);
  }

  /// `Category`
  String get category {
    return Intl.message('Category', name: 'category', desc: '', args: []);
  }

  /// `Change`
  String get change {
    return Intl.message('Change', name: 'change', desc: '', args: []);
  }

  /// `Bills Count`
  String get checksFilter {
    return Intl.message(
      'Bills Count',
      name: 'checksFilter',
      desc: '',
      args: [],
    );
  }

  /// `Choose Day`
  String get chooseDay {
    return Intl.message('Choose Day', name: 'chooseDay', desc: '', args: []);
  }

  /// `Choose Month`
  String get chooseMonth {
    return Intl.message(
      'Choose Month',
      name: 'chooseMonth',
      desc: '',
      args: [],
    );
  }

  /// `Choose Week`
  String get chooseWeek {
    return Intl.message('Choose Week', name: 'chooseWeek', desc: '', args: []);
  }

  /// `Choose Year`
  String get chooseYear {
    return Intl.message('Choose Year', name: 'chooseYear', desc: '', args: []);
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Comparison`
  String get comparisonLabel {
    return Intl.message(
      'Comparison',
      name: 'comparisonLabel',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Consignation`
  String get consignation {
    return Intl.message(
      'Consignation',
      name: 'consignation',
      desc: '',
      args: [],
    );
  }

  /// `Current Value`
  String get currentValue {
    return Intl.message(
      'Current Value',
      name: 'currentValue',
      desc: '',
      args: [],
    );
  }

  /// `Day`
  String get day {
    return Intl.message('Day', name: 'day', desc: '', args: []);
  }

  /// `Dec`
  String get decShort {
    return Intl.message('Dec', name: 'decShort', desc: '', args: []);
  }

  /// `Discount`
  String get discount {
    return Intl.message('Discount', name: 'discount', desc: '', args: []);
  }

  /// `Display Value`
  String get displayValue {
    return Intl.message(
      'Display Value',
      name: 'displayValue',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Feb`
  String get febShort {
    return Intl.message('Feb', name: 'febShort', desc: '', args: []);
  }

  /// `Fri`
  String get fri {
    return Intl.message('Fri', name: 'fri', desc: '', args: []);
  }

  /// `Georgian`
  String get georgian {
    return Intl.message('Georgian', name: 'georgian', desc: '', args: []);
  }

  /// `Sales`
  String get income {
    return Intl.message('Sales', name: 'income', desc: '', args: []);
  }

  /// `Username or password is incorrect!`
  String get incorrectCredentials {
    return Intl.message(
      'Username or password is incorrect!',
      name: 'incorrectCredentials',
      desc: '',
      args: [],
    );
  }

  /// `Jan`
  String get janShort {
    return Intl.message('Jan', name: 'janShort', desc: '', args: []);
  }

  /// `Jul`
  String get julShort {
    return Intl.message('Jul', name: 'julShort', desc: '', args: []);
  }

  /// `Jun`
  String get junShort {
    return Intl.message('Jun', name: 'junShort', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Last Day`
  String get lastDay {
    return Intl.message('Last Day', name: 'lastDay', desc: '', args: []);
  }

  /// `Last Month`
  String get lastMonth {
    return Intl.message('Last Month', name: 'lastMonth', desc: '', args: []);
  }

  /// `Last Month Day`
  String get lastMonthDay {
    return Intl.message(
      'Last Month Day',
      name: 'lastMonthDay',
      desc: '',
      args: [],
    );
  }

  /// `Last Month`
  String get lastMonthOption {
    return Intl.message(
      'Last Month',
      name: 'lastMonthOption',
      desc: '',
      args: [],
    );
  }

  /// `Last Week`
  String get lastWeek {
    return Intl.message('Last Week', name: 'lastWeek', desc: '', args: []);
  }

  /// `Last Week Day`
  String get lastWeekDay {
    return Intl.message(
      'Last Week Day',
      name: 'lastWeekDay',
      desc: '',
      args: [],
    );
  }

  /// `Last Week`
  String get lastWeekOption {
    return Intl.message(
      'Last Week',
      name: 'lastWeekOption',
      desc: '',
      args: [],
    );
  }

  /// `Last Year`
  String get lastYear {
    return Intl.message('Last Year', name: 'lastYear', desc: '', args: []);
  }

  /// `Last Year Day`
  String get lastYearDay {
    return Intl.message(
      'Last Year Day',
      name: 'lastYearDay',
      desc: '',
      args: [],
    );
  }

  /// `Last Year Month`
  String get lastYearMonth {
    return Intl.message(
      'Last Year Month',
      name: 'lastYearMonth',
      desc: '',
      args: [],
    );
  }

  /// `Last Year`
  String get lastYearOption {
    return Intl.message(
      'Last Year',
      name: 'lastYearOption',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get logout {
    return Intl.message('Log Out', name: 'logout', desc: '', args: []);
  }

  /// `Loyalty`
  String get loyalty {
    return Intl.message('Loyalty', name: 'loyalty', desc: '', args: []);
  }

  /// `Mar`
  String get marShort {
    return Intl.message('Mar', name: 'marShort', desc: '', args: []);
  }

  /// `May`
  String get mayShort {
    return Intl.message('May', name: 'mayShort', desc: '', args: []);
  }

  /// `Mon`
  String get mon {
    return Intl.message('Mon', name: 'mon', desc: '', args: []);
  }

  /// `Month`
  String get month {
    return Intl.message('Month', name: 'month', desc: '', args: []);
  }

  /// `No data available`
  String get noDataAvailable {
    return Intl.message(
      'No data available',
      name: 'noDataAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Nov`
  String get novShort {
    return Intl.message('Nov', name: 'novShort', desc: '', args: []);
  }

  /// `Oct`
  String get octShort {
    return Intl.message('Oct', name: 'octShort', desc: '', args: []);
  }

  /// `Payment Method`
  String get paymentMethod {
    return Intl.message(
      'Payment Method',
      name: 'paymentMethod',
      desc: '',
      args: [],
    );
  }

  /// `Payments`
  String get payments {
    return Intl.message('Payments', name: 'payments', desc: '', args: []);
  }

  /// `Period`
  String get period {
    return Intl.message('Period', name: 'period', desc: '', args: []);
  }

  /// `Previous Value`
  String get previousValue {
    return Intl.message(
      'Previous Value',
      name: 'previousValue',
      desc: '',
      args: [],
    );
  }

  /// `Product`
  String get product {
    return Intl.message('Product', name: 'product', desc: '', args: []);
  }

  /// `Profit`
  String get profit {
    return Intl.message('Profit', name: 'profit', desc: '', args: []);
  }

  /// `Profit %`
  String get profitPercent {
    return Intl.message('Profit %', name: 'profitPercent', desc: '', args: []);
  }

  /// `Quantity`
  String get quantity {
    return Intl.message('Quantity', name: 'quantity', desc: '', args: []);
  }

  /// `Refund`
  String get refund {
    return Intl.message('Refund', name: 'refund', desc: '', args: []);
  }

  /// `Sales`
  String get sales {
    return Intl.message('Sales', name: 'sales', desc: '', args: []);
  }

  /// `Sales by Categories`
  String get salesByCategories {
    return Intl.message(
      'Sales by Categories',
      name: 'salesByCategories',
      desc: '',
      args: [],
    );
  }

  /// `Sales by Payment Methods`
  String get salesByPaymentMethods {
    return Intl.message(
      'Sales by Payment Methods',
      name: 'salesByPaymentMethods',
      desc: '',
      args: [],
    );
  }

  /// `Sales by Staffs`
  String get salesByStaffs {
    return Intl.message(
      'Sales by Staffs',
      name: 'salesByStaffs',
      desc: '',
      args: [],
    );
  }

  /// `Sales by Stores`
  String get salesByStores {
    return Intl.message(
      'Sales by Stores',
      name: 'salesByStores',
      desc: '',
      args: [],
    );
  }

  /// `Sales Overview`
  String get salesOverview {
    return Intl.message(
      'Sales Overview',
      name: 'salesOverview',
      desc: '',
      args: [],
    );
  }

  /// `Same Duration Back`
  String get sameDurationBack {
    return Intl.message(
      'Same Duration Back',
      name: 'sameDurationBack',
      desc: '',
      args: [],
    );
  }

  /// `Sat`
  String get sat {
    return Intl.message('Sat', name: 'sat', desc: '', args: []);
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Select Location`
  String get selectLocation {
    return Intl.message(
      'Select Location',
      name: 'selectLocation',
      desc: '',
      args: [],
    );
  }

  /// `Select Period`
  String get selectPeriod {
    return Intl.message(
      'Select Period',
      name: 'selectPeriod',
      desc: '',
      args: [],
    );
  }

  /// `Selected Period`
  String get selectedPeriod {
    return Intl.message(
      'Selected Period',
      name: 'selectedPeriod',
      desc: '',
      args: [],
    );
  }

  /// `Selfcost`
  String get selfcost {
    return Intl.message('Selfcost', name: 'selfcost', desc: '', args: []);
  }

  /// `Sep`
  String get sepShort {
    return Intl.message('Sep', name: 'sepShort', desc: '', args: []);
  }

  /// `Staff Member`
  String get staffMember {
    return Intl.message(
      'Staff Member',
      name: 'staffMember',
      desc: '',
      args: [],
    );
  }

  /// `Store`
  String get store {
    return Intl.message('Store', name: 'store', desc: '', args: []);
  }

  /// `Store Sales Overview`
  String get storeSalesOverview {
    return Intl.message(
      'Store Sales Overview',
      name: 'storeSalesOverview',
      desc: '',
      args: [],
    );
  }

  /// `Sun`
  String get sun {
    return Intl.message('Sun', name: 'sun', desc: '', args: []);
  }

  /// `Thu`
  String get thu {
    return Intl.message('Thu', name: 'thu', desc: '', args: []);
  }

  /// `Today vs Yesterday`
  String get todayVsYesterday {
    return Intl.message(
      'Today vs Yesterday',
      name: 'todayVsYesterday',
      desc: '',
      args: [],
    );
  }

  /// `Top Sales by Products`
  String get topSalesByProducts {
    return Intl.message(
      'Top Sales by Products',
      name: 'topSalesByProducts',
      desc: '',
      args: [],
    );
  }

  /// `Tue`
  String get tue {
    return Intl.message('Tue', name: 'tue', desc: '', args: []);
  }

  /// `Wed`
  String get wed {
    return Intl.message('Wed', name: 'wed', desc: '', args: []);
  }

  /// `Week`
  String get week {
    return Intl.message('Week', name: 'week', desc: '', args: []);
  }

  /// `Year`
  String get year {
    return Intl.message('Year', name: 'year', desc: '', args: []);
  }

  /// `Finances`
  String get finances {
    return Intl.message('Finances', name: 'finances', desc: '', args: []);
  }

  /// `Stock`
  String get stock {
    return Intl.message('Stock', name: 'stock', desc: '', args: []);
  }

  /// `Sales by Days`
  String get salesByDay {
    return Intl.message(
      'Sales by Days',
      name: 'salesByDay',
      desc: '',
      args: [],
    );
  }

  /// `Sales by Hours`
  String get salesByHours {
    return Intl.message(
      'Sales by Hours',
      name: 'salesByHours',
      desc: '',
      args: [],
    );
  }

  /// `Sales by Weekdays`
  String get salesByWeekday {
    return Intl.message(
      'Sales by Weekdays',
      name: 'salesByWeekday',
      desc: '',
      args: [],
    );
  }

  /// `Cash Flow`
  String get cashFlow {
    return Intl.message('Cash Flow', name: 'cashFlow', desc: '', args: []);
  }

  /// `Customer Sales`
  String get customerSales {
    return Intl.message(
      'Customer Sales',
      name: 'customerSales',
      desc: '',
      args: [],
    );
  }

  /// `Customer Returns`
  String get customerReturns {
    return Intl.message(
      'Customer Returns',
      name: 'customerReturns',
      desc: '',
      args: [],
    );
  }

  /// `Payments to Customers`
  String get paymentsToCustomers {
    return Intl.message(
      'Payments to Customers',
      name: 'paymentsToCustomers',
      desc: '',
      args: [],
    );
  }

  /// `Payments List`
  String get paymentsList {
    return Intl.message(
      'Payments List',
      name: 'paymentsList',
      desc: '',
      args: [],
    );
  }

  /// `Vendor Purchases`
  String get vendorPurchases {
    return Intl.message(
      'Vendor Purchases',
      name: 'vendorPurchases',
      desc: '',
      args: [],
    );
  }

  /// `Vendor Returns`
  String get vendorReturns {
    return Intl.message(
      'Vendor Returns',
      name: 'vendorReturns',
      desc: '',
      args: [],
    );
  }

  /// `Payments to Vendors`
  String get paymentsToVendors {
    return Intl.message(
      'Payments to Vendors',
      name: 'paymentsToVendors',
      desc: '',
      args: [],
    );
  }

  /// `Accounts Receivable`
  String get accountsReceivable {
    return Intl.message(
      'Accounts Receivable',
      name: 'accountsReceivable',
      desc: '',
      args: [],
    );
  }

  /// `Accounts Payable`
  String get accountsPayable {
    return Intl.message(
      'Accounts Payable',
      name: 'accountsPayable',
      desc: '',
      args: [],
    );
  }

  /// `Profit by Products`
  String get profitByProducts {
    return Intl.message(
      'Profit by Products',
      name: 'profitByProducts',
      desc: '',
      args: [],
    );
  }

  /// `Profit by Categories`
  String get profitByCategories {
    return Intl.message(
      'Profit by Categories',
      name: 'profitByCategories',
      desc: '',
      args: [],
    );
  }

  /// `Received Payments List`
  String get receivedPaymentsList {
    return Intl.message(
      'Received Payments List',
      name: 'receivedPaymentsList',
      desc: '',
      args: [],
    );
  }

  /// `Inventory Balance`
  String get inventoryBalance {
    return Intl.message(
      'Inventory Balance',
      name: 'inventoryBalance',
      desc: '',
      args: [],
    );
  }

  /// `Purchases Documents`
  String get purchasesDocuments {
    return Intl.message(
      'Purchases Documents',
      name: 'purchasesDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Purchases by Item - Summary`
  String get purchasesByItemSummary {
    return Intl.message(
      'Purchases by Item - Summary',
      name: 'purchasesByItemSummary',
      desc: '',
      args: [],
    );
  }

  /// `Purchases by Item - Detailed`
  String get purchasesByItemDetailed {
    return Intl.message(
      'Purchases by Item - Detailed',
      name: 'purchasesByItemDetailed',
      desc: '',
      args: [],
    );
  }

  /// `Sales by Item - Summary`
  String get salesByItemSummary {
    return Intl.message(
      'Sales by Item - Summary',
      name: 'salesByItemSummary',
      desc: '',
      args: [],
    );
  }

  /// `Sale Documents`
  String get saleDocuments {
    return Intl.message(
      'Sale Documents',
      name: 'saleDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Sales by Item - Detailed`
  String get salesByItemDetailed {
    return Intl.message(
      'Sales by Item - Detailed',
      name: 'salesByItemDetailed',
      desc: '',
      args: [],
    );
  }

  /// `Store Transfer Details`
  String get storeTransferDetails {
    return Intl.message(
      'Store Transfer Details',
      name: 'storeTransferDetails',
      desc: '',
      args: [],
    );
  }

  /// `Product Sales - Summary`
  String get productSalesSummary {
    return Intl.message(
      'Product Sales - Summary',
      name: 'productSalesSummary',
      desc: '',
      args: [],
    );
  }

  /// `Product Sales - Detailed`
  String get productSalesDetailed {
    return Intl.message(
      'Product Sales - Detailed',
      name: 'productSalesDetailed',
      desc: '',
      args: [],
    );
  }

  /// `Sale Documents Products - Summary`
  String get saleDocumentsProductsSummary {
    return Intl.message(
      'Sale Documents Products - Summary',
      name: 'saleDocumentsProductsSummary',
      desc: '',
      args: [],
    );
  }

  /// `Sale Documents Products - Detailed`
  String get saleDocumentsProductsDetailed {
    return Intl.message(
      'Sale Documents Products - Detailed',
      name: 'saleDocumentsProductsDetailed',
      desc: '',
      args: [],
    );
  }

  /// `Stock Movement`
  String get stockMovement {
    return Intl.message(
      'Stock Movement',
      name: 'stockMovement',
      desc: '',
      args: [],
    );
  }

  /// `Low stock Report`
  String get lowStockReport {
    return Intl.message(
      'Low stock Report',
      name: 'lowStockReport',
      desc: '',
      args: [],
    );
  }

  /// `Inventory Value`
  String get inventoryValue {
    return Intl.message(
      'Inventory Value',
      name: 'inventoryValue',
      desc: '',
      args: [],
    );
  }

  /// `Inventory Report`
  String get inventoryReport {
    return Intl.message(
      'Inventory Report',
      name: 'inventoryReport',
      desc: '',
      args: [],
    );
  }

  /// `Revenue Report`
  String get revenueReport {
    return Intl.message(
      'Revenue Report',
      name: 'revenueReport',
      desc: '',
      args: [],
    );
  }

  /// `Expense Report`
  String get expenseReport {
    return Intl.message(
      'Expense Report',
      name: 'expenseReport',
      desc: '',
      args: [],
    );
  }

  /// `Profit & Loss`
  String get profitAndLoss {
    return Intl.message(
      'Profit & Loss',
      name: 'profitAndLoss',
      desc: '',
      args: [],
    );
  }

  /// `Staff Performance`
  String get staffPerformance {
    return Intl.message(
      'Staff Performance',
      name: 'staffPerformance',
      desc: '',
      args: [],
    );
  }

  /// `Attendance Report`
  String get attendanceReport {
    return Intl.message(
      'Attendance Report',
      name: 'attendanceReport',
      desc: '',
      args: [],
    );
  }

  /// `Commission Report`
  String get commissionReport {
    return Intl.message(
      'Commission Report',
      name: 'commissionReport',
      desc: '',
      args: [],
    );
  }

  /// `Shift Report`
  String get shiftReport {
    return Intl.message(
      'Shift Report',
      name: 'shiftReport',
      desc: '',
      args: [],
    );
  }

  /// `Hours Worked`
  String get hoursWorked {
    return Intl.message(
      'Hours Worked',
      name: 'hoursWorked',
      desc: '',
      args: [],
    );
  }

  /// `Productivity Report`
  String get productivityReport {
    return Intl.message(
      'Productivity Report',
      name: 'productivityReport',
      desc: '',
      args: [],
    );
  }

  /// `Hourly Sales Overview`
  String get hourlySalesOverview {
    return Intl.message(
      'Hourly Sales Overview',
      name: 'hourlySalesOverview',
      desc: '',
      args: [],
    );
  }

  /// `Weekday Sales Overview`
  String get weekdaySalesOverview {
    return Intl.message(
      'Weekday Sales Overview',
      name: 'weekdaySalesOverview',
      desc: '',
      args: [],
    );
  }

  /// `Daily Sales Overview`
  String get dailySalesOverview {
    return Intl.message(
      'Daily Sales Overview',
      name: 'dailySalesOverview',
      desc: '',
      args: [],
    );
  }

  /// `Monthly Sales Overview`
  String get monthlySalesOverview {
    return Intl.message(
      'Monthly Sales Overview',
      name: 'monthlySalesOverview',
      desc: '',
      args: [],
    );
  }

  /// `Weekday`
  String get weekday {
    return Intl.message('Weekday', name: 'weekday', desc: '', args: []);
  }

  /// `Checks is the number of checks`
  String get checksDescription {
    return Intl.message(
      'Checks is the number of checks',
      name: 'checksDescription',
      desc: '',
      args: [],
    );
  }

  /// `AvgCheck is the average check value`
  String get avgCheckDescription {
    return Intl.message(
      'AvgCheck is the average check value',
      name: 'avgCheckDescription',
      desc: '',
      args: [],
    );
  }

  /// `Sales is the amount`
  String get salesDescription {
    return Intl.message(
      'Sales is the amount',
      name: 'salesDescription',
      desc: '',
      args: [],
    );
  }

  /// `No orders found`
  String get noOrdersFound {
    return Intl.message(
      'No orders found',
      name: 'noOrdersFound',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message('Dashboard', name: 'dashboard', desc: '', args: []);
  }

  /// `Reports`
  String get reports {
    return Intl.message('Reports', name: 'reports', desc: '', args: []);
  }

  /// `Orders`
  String get orders {
    return Intl.message('Orders', name: 'orders', desc: '', args: []);
  }

  /// `Log In`
  String get logIn {
    return Intl.message('Log In', name: 'logIn', desc: '', args: []);
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Order`
  String get order {
    return Intl.message('Order', name: 'order', desc: '', args: []);
  }

  /// `User`
  String get user {
    return Intl.message('User', name: 'user', desc: '', args: []);
  }

  /// `Time`
  String get time {
    return Intl.message('Time', name: 'time', desc: '', args: []);
  }

  /// `Location`
  String get location {
    return Intl.message('Location', name: 'location', desc: '', args: []);
  }

  /// `Amount`
  String get amount {
    return Intl.message('Amount', name: 'amount', desc: '', args: []);
  }

  /// `Paytype`
  String get paytype {
    return Intl.message('Paytype', name: 'paytype', desc: '', args: []);
  }

  /// `Items`
  String get items {
    return Intl.message('Items', name: 'items', desc: '', args: []);
  }

  /// `Item`
  String get item {
    return Intl.message('Item', name: 'item', desc: '', args: []);
  }

  /// `Qty`
  String get qty {
    return Intl.message('Qty', name: 'qty', desc: '', args: []);
  }

  /// `Total`
  String get total {
    return Intl.message('Total', name: 'total', desc: '', args: []);
  }

  /// `Failed to load order details`
  String get orderDetailsLoadFailed {
    return Intl.message(
      'Failed to load order details',
      name: 'orderDetailsLoadFailed',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'az'),
      Locale.fromSubtags(languageCode: 'ka'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
