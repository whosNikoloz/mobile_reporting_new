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

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Georgian`
  String get georgian {
    return Intl.message('Georgian', name: 'georgian', desc: '', args: []);
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Log Out`
  String get logout {
    return Intl.message('Log Out', name: 'logout', desc: '', args: []);
  }

  /// `Your profile information`
  String get profileInfo {
    return Intl.message(
      'Your profile information',
      name: 'profileInfo',
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

  /// `Statistics`
  String get statistics {
    return Intl.message('Statistics', name: 'statistics', desc: '', args: []);
  }

  /// `Orders`
  String get orders {
    return Intl.message('Orders', name: 'orders', desc: '', args: []);
  }

  /// `Finances`
  String get finances {
    return Intl.message('Finances', name: 'finances', desc: '', args: []);
  }

  /// `Checks`
  String get checks {
    return Intl.message('Checks', name: 'checks', desc: '', args: []);
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

  /// `General`
  String get general {
    return Intl.message('General', name: 'general', desc: '', args: []);
  }

  /// `Payments`
  String get payments {
    return Intl.message('Payments', name: 'payments', desc: '', args: []);
  }

  /// `Sales`
  String get sales {
    return Intl.message('Sales', name: 'sales', desc: '', args: []);
  }

  /// `Selfcost`
  String get selfcost {
    return Intl.message('Selfcost', name: 'selfcost', desc: '', args: []);
  }

  /// `Profit`
  String get profit {
    return Intl.message('Profit', name: 'profit', desc: '', args: []);
  }

  /// `Avg Check`
  String get avgCheck {
    return Intl.message('Avg Check', name: 'avgCheck', desc: '', args: []);
  }

  /// `Profit %`
  String get profitPercent {
    return Intl.message('Profit %', name: 'profitPercent', desc: '', args: []);
  }

  /// `Bills`
  String get bills {
    return Intl.message('Bills', name: 'bills', desc: '', args: []);
  }

  /// `Discount`
  String get discount {
    return Intl.message('Discount', name: 'discount', desc: '', args: []);
  }

  /// `Refund`
  String get refund {
    return Intl.message('Refund', name: 'refund', desc: '', args: []);
  }

  /// `Cash`
  String get cash {
    return Intl.message('Cash', name: 'cash', desc: '', args: []);
  }

  /// `Card`
  String get card {
    return Intl.message('Card', name: 'card', desc: '', args: []);
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

  /// `Loyalty`
  String get loyalty {
    return Intl.message('Loyalty', name: 'loyalty', desc: '', args: []);
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

  /// `Total Bills`
  String get totalBills {
    return Intl.message('Total Bills', name: 'totalBills', desc: '', args: []);
  }

  /// `Total Amount`
  String get totalAmount {
    return Intl.message(
      'Total Amount',
      name: 'totalAmount',
      desc: '',
      args: [],
    );
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

  /// `Today vs Yesterday`
  String get todayVsYesterday {
    return Intl.message(
      'Today vs Yesterday',
      name: 'todayVsYesterday',
      desc: '',
      args: [],
    );
  }

  /// `All Stores`
  String get allBranches {
    return Intl.message('All Stores', name: 'allBranches', desc: '', args: []);
  }

  /// `Comparison`
  String get comparisonLabel {
    return Intl.message(
      'Compare to',
      name: 'comparisonLabel',
      desc: '',
      args: [],
    );
  }

  /// `Last Day`
  String get lastDay {
    return Intl.message('Last Day', name: 'lastDay', desc: '', args: []);
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

  /// `Last Month Day`
  String get lastMonthDay {
    return Intl.message(
      'Last Month Day',
      name: 'lastMonthDay',
      desc: '',
      args: [],
    );
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

  /// `Choose Day`
  String get chooseDay {
    return Intl.message('Choose Day', name: 'chooseDay', desc: '', args: []);
  }

  /// `Last Week`
  String get lastWeek {
    return Intl.message('Last Week', name: 'lastWeek', desc: '', args: []);
  }

  /// `Choose Week`
  String get chooseWeek {
    return Intl.message('Choose Week', name: 'chooseWeek', desc: '', args: []);
  }

  /// `Last Month`
  String get lastMonth {
    return Intl.message('Last Month', name: 'lastMonth', desc: '', args: []);
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

  /// `Choose Month`
  String get chooseMonth {
    return Intl.message(
      'Choose Month',
      name: 'chooseMonth',
      desc: '',
      args: [],
    );
  }

  /// `Last Year`
  String get lastYear {
    return Intl.message('Last Year', name: 'lastYear', desc: '', args: []);
  }

  /// `Choose Year`
  String get chooseYear {
    return Intl.message('Choose Year', name: 'chooseYear', desc: '', args: []);
  }

  /// `Period`
  String get period {
    return Intl.message('Period', name: 'period', desc: '', args: []);
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

  /// `Locations`
  String get branches {
    return Intl.message('Locations', name: 'branches', desc: '', args: []);
  }

  /// `Select Store`
  String get selectStore {
    return Intl.message(
      'Select Store',
      name: 'selectStore',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Day`
  String get day {
    return Intl.message('Day', name: 'day', desc: '', args: []);
  }

  /// `Week`
  String get week {
    return Intl.message('Week', name: 'week', desc: '', args: []);
  }

  /// `Month`
  String get month {
    return Intl.message('Month', name: 'month', desc: '', args: []);
  }

  /// `Year`
  String get year {
    return Intl.message('Year', name: 'year', desc: '', args: []);
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

  /// `Last Week`
  String get lastWeekOption {
    return Intl.message(
      'Last Week',
      name: 'lastWeekOption',
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

  /// `Last Year`
  String get lastYearOption {
    return Intl.message(
      'Last Year',
      name: 'lastYearOption',
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

  /// `Mon`
  String get mon {
    return Intl.message('Mon', name: 'mon', desc: '', args: []);
  }

  /// `Tue`
  String get tue {
    return Intl.message('Tue', name: 'tue', desc: '', args: []);
  }

  /// `Wed`
  String get wed {
    return Intl.message('Wed', name: 'wed', desc: '', args: []);
  }

  /// `Thu`
  String get thu {
    return Intl.message('Thu', name: 'thu', desc: '', args: []);
  }

  /// `Fri`
  String get fri {
    return Intl.message('Fri', name: 'fri', desc: '', args: []);
  }

  /// `Sat`
  String get sat {
    return Intl.message('Sat', name: 'sat', desc: '', args: []);
  }

  /// `Sun`
  String get sun {
    return Intl.message('Sun', name: 'sun', desc: '', args: []);
  }

  /// `Jan`
  String get janShort {
    return Intl.message('Jan', name: 'janShort', desc: '', args: []);
  }

  /// `Feb`
  String get febShort {
    return Intl.message('Feb', name: 'febShort', desc: '', args: []);
  }

  /// `Mar`
  String get marShort {
    return Intl.message('Mar', name: 'marShort', desc: '', args: []);
  }

  /// `Apr`
  String get aprShort {
    return Intl.message('Apr', name: 'aprShort', desc: '', args: []);
  }

  /// `May`
  String get mayShort {
    return Intl.message('May', name: 'mayShort', desc: '', args: []);
  }

  /// `Jun`
  String get junShort {
    return Intl.message('Jun', name: 'junShort', desc: '', args: []);
  }

  /// `Jul`
  String get julShort {
    return Intl.message('Jul', name: 'julShort', desc: '', args: []);
  }

  /// `Aug`
  String get augShort {
    return Intl.message('Aug', name: 'augShort', desc: '', args: []);
  }

  /// `Sep`
  String get sepShort {
    return Intl.message('Sep', name: 'sepShort', desc: '', args: []);
  }

  /// `Oct`
  String get octShort {
    return Intl.message('Oct', name: 'octShort', desc: '', args: []);
  }

  /// `Nov`
  String get novShort {
    return Intl.message('Nov', name: 'novShort', desc: '', args: []);
  }

  /// `Dec`
  String get decShort {
    return Intl.message('Dec', name: 'decShort', desc: '', args: []);
  }

  /// `Staff`
  String get staff {
    return Intl.message('Staff', name: 'staff', desc: '', args: []);
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

  /// `Sales by Weekday`
  String get salesByWeekday {
    return Intl.message(
      'Sales by Weekday',
      name: 'salesByWeekday',
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

  /// `Inventory Report`
  String get inventoryReport {
    return Intl.message(
      'Inventory Report',
      name: 'inventoryReport',
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

  /// `Income`
  String get income {
    return Intl.message('Income', name: 'income', desc: '', args: []);
  }

  /// `Checks`
  String get checksFilter {
    return Intl.message('Checks', name: 'checksFilter', desc: '', args: []);
  }

  /// `Average Check`
  String get averageCheck {
    return Intl.message(
      'Average Check',
      name: 'averageCheck',
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

  /// `Sales Overview`
  String get salesOverview {
    return Intl.message(
      'Sales Overview',
      name: 'salesOverview',
      desc: '',
      args: [],
    );
  }

  /// `Select Filter`
  String get selectFilter {
    return Intl.message(
      'Select Filter',
      name: 'selectFilter',
      desc: '',
      args: [],
    );
  }

  /// `Hour`
  String get hour {
    return Intl.message('Hour', name: 'hour', desc: '', args: []);
  }

  /// `Weekday`
  String get weekday {
    return Intl.message('Weekday', name: 'weekday', desc: '', args: []);
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
