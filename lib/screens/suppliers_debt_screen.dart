import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_reporting/api/response_models/suppliers_debt_response_model.dart';
import 'package:mobile_reporting/application_store.dart';
import 'package:mobile_reporting/enums/screen_type.dart';
import 'package:mobile_reporting/helpers/currency_helper.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/localization/generated/l10n.dart';
import 'package:mobile_reporting/main.dart';
import 'package:mobile_reporting/screens/sign_in_screen.dart';
import 'package:mobile_reporting/services/reports_service.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:mobile_reporting/widgets/picker_widget.dart';
import 'package:mobile_reporting/widgets/profile_popover_widget.dart';
import 'package:mobile_reporting/widgets/rotating_logo_loader.dart';

class SuppliersDebtScreen extends StatefulWidget {
  const SuppliersDebtScreen({super.key});

  @override
  State<SuppliersDebtScreen> createState() => _SuppliersDebtScreenState();
}

class _SuppliersDebtScreenState extends State<SuppliersDebtScreen> {
  final ReportsService _reportsService = ReportsService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _filtersLoaded = false;
  String _searchQuery = '';

  List<SuppliersDebtResponseModel> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _pageSize = 20;

  DateTime _beforeDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    23,
    59,
  );

  String? _companyName;
  String? _email;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFilters();
    _loadUserData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFilters() async {
    await application.loadFilters();
    if (mounted) {
      setState(() {
        _beforeDate = application.endCurrentPeriod ?? _beforeDate;
        _filtersLoaded = true;
      });
    }
  }

  Future<void> _loadUserData() async {
    _companyName = await getIt<PreferencesHelper>().getCompanyName();
    _email = await getIt<PreferencesHelper>().getEmail();
    final savedLang = await getIt<PreferencesHelper>().getLang();
    if (savedLang != null) _selectedLanguage = savedLang;
    if (mounted) setState(() {});
  }

  void _changeLanguage(String langCode) async {
    setState(() => _selectedLanguage = langCode);
    await getIt<PreferencesHelper>().setLang(langCode);
    if (mounted) ReportingApp.of(context).setLocale(Locale(langCode));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  void _resetAndLoad() {
    setState(() {
      _items = [];
      _currentPage = 1;
      _hasMore = true;
    });
    _loadData();
  }

  Future<void> _loadData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final results = await _reportsService.getSuppliersDebt(
        beforeDate: _beforeDate,
        page: _currentPage,
        pageSize: _pageSize,
      );
      setState(() {
        if (results != null) {
          _items = results;
          _hasMore = results.length == _pageSize;
        }
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final results = await _reportsService.getSuppliersDebt(
        beforeDate: _beforeDate,
        page: nextPage,
        pageSize: _pageSize,
      );
      setState(() {
        if (results != null && results.isNotEmpty) {
          _items.addAll(results);
          _currentPage = nextPage;
          _hasMore = results.length == _pageSize;
        } else {
          _hasMore = false;
        }
        _isLoadingMore = false;
      });
    } catch (_) {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: AppTheme.primaryTextColor),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Text(
              l10n.accountsPayable,
              style: const TextStyle(
                color: AppTheme.primaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Bold',
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  icon: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(21),
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: SvgPicture.asset(
                          'assets/icons/user.svg',
                          colorFilter: const ColorFilter.mode(
                            AppTheme.primaryBlue,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    showProfilePopover(
                      context: context,
                      name: _companyName ?? 'Name',
                      email: _email ?? 'Email@gmail.com',
                      currentLangCode: _selectedLanguage,
                      onLanguageChanged: _changeLanguage,
                      onLogout: () async {
                        await getIt<PreferencesHelper>().clearCompanyName();
                        await getIt<PreferencesHelper>().clearLang();
                        await getIt<PreferencesHelper>().clearType();
                        await getIt<PreferencesHelper>().clearUserAuthToken();
                        await getIt<PreferencesHelper>().clearUserName();
                        await getIt<PreferencesHelper>().clearEmail();
                        await getIt<PreferencesHelper>().clearAccountLang();
                        await getIt<PreferencesHelper>().clearDatabase();
                        await getIt<PreferencesHelper>().clearUrl();
                        if (!mounted) return;
                        // ignore: use_build_context_synchronously
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignInScreen()),
                          (route) => false,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: !_filtersLoaded
          ? Center(child: RotatingLogoLoader())
          : Column(
              children: [
                PickerWidget(
                  screenType: ScreenType.reportssScreen,
                  showCompareDateFilter: false,
                  showStoreFilter: false,
                  onlyDayPicker: true,
                  getDate: (dt1, dt2, dt3, dt4, min, max, bill) async {
                    _beforeDate = dt2;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _resetAndLoad();
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) =>
                          setState(() => _searchQuery = val.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: l10n.search,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 4, 0),
                          child: SvgPicture.asset(
                            'assets/icons/search.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              AppTheme.primaryBlue,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                                child: Icon(Icons.close,
                                    size: 16, color: Colors.grey.shade600),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoading && _items.isEmpty
                      ? Center(child: RotatingLogoLoader())
                      : ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          children: [
                            if (_items.isNotEmpty)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    _buildTableHeader(),
                                    ...() {
                                      final filtered = _items
                                          .where((item) =>
                                              item.name
                                                  .toLowerCase()
                                                  .contains(_searchQuery) ||
                                              item.code
                                                  .toLowerCase()
                                                  .contains(_searchQuery))
                                          .toList();
                                      return List.generate(filtered.length,
                                          (i) => _buildRow(filtered[i], i));
                                    }(),
                                    if (_hasMore)
                                      const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 16),
                                        child:
                                            Center(child: RotatingLogoLoader()),
                                      ),
                                  ],
                                ),
                              )
                            else
                              SizedBox(
                                height: 300,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.bar_chart,
                                          size: 48,
                                          color: Colors.grey.shade300),
                                      const SizedBox(height: 16),
                                      Text(
                                        l10n.noDataAvailable,
                                        style: TextStyle(
                                            color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: const [
          Expanded(
            flex: 8,
            child: Text(
              'Supplier',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Balance',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(SuppliersDebtResponseModel item, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (item.code.isNotEmpty)
                  Text(
                    item.code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              CurrencyHelper.format(item.rest,
                  showSymbol: false, showDecimals: false),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
