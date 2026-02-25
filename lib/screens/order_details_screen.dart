import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_reporting/api/response_models/order_details_response_model.dart';
import 'package:mobile_reporting/helpers/currency_helper.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/localization/generated/l10n.dart';
import 'package:mobile_reporting/main.dart';
import 'package:mobile_reporting/screens/sign_in_screen.dart';
import 'package:mobile_reporting/services/order_details_service.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:mobile_reporting/widgets/profile_popover_widget.dart';
import 'package:mobile_reporting/widgets/rotating_logo_loader.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;
  final String orderNumber;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    required this.orderNumber,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final OrderDetailsService _service = OrderDetailsService();

  OrderDetailsResponseModel? _order;
  bool _isLoading = true;
  String? _errorMessage;

  String? _companyName;
  String? _email;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _companyName = await getIt<PreferencesHelper>().getCompanyName();
    _email = await getIt<PreferencesHelper>().getEmail();
    final savedLang = await getIt<PreferencesHelper>().getLang();
    if (savedLang != null) {
      _selectedLanguage = savedLang;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _changeLanguage(String langCode) async {
    setState(() {
      _selectedLanguage = langCode;
    });
    await getIt<PreferencesHelper>().setLang(langCode);
    if (mounted) {
      ReportingApp.of(context).setLocale(Locale(langCode));
    }
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _service.getOrderDetails(orderId: widget.orderId);
      if (!mounted) return;

      setState(() {
        _order = result;
        if (result == null) {
          _errorMessage = S.current.orderDetailsLoadFailed;
        }
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = S.current.orderDetailsLoadFailed;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final order = _order;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(order),
            Expanded(
              child: _isLoading
                  ? Center(child: RotatingLogoLoader())
                  : _errorMessage != null || order == null
                      ? Center(
                          child: Text(
                            l10n.noDataAvailable,
                            style: const TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildOrderTitleRow(order),
                              const SizedBox(height: 16),
                              _buildInfoGrid(order, l10n),
                              const SizedBox(height: 24),
                              _buildItemsSection(order, l10n),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(OrderDetailsResponseModel? order) {
    final titleNumber = order?.orderNumber ?? widget.orderNumber;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor,
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: AppTheme.primaryTextColor,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '${S.of(context).order} #$titleNumber',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryTextColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Container(
                width: 42,
                height: 30,
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
                      colorFilter: ColorFilter.mode(
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
                  name: _companyName ?? "Name",
                  email: _email ?? "Email@gmail.com",
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
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                      (route) => false,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTitleRow(OrderDetailsResponseModel order) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${S.of(context).order} #${order.orderNumber}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryTextColor,
            ),
          ),
        ),
        Row(
          children: [
            SvgPicture.asset(
              'assets/icons/calendar.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppTheme.primaryBlue,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              order.date,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoGrid(OrderDetailsResponseModel order, S l10n) {
    final discountText = order.discountPercent != null
        ? '${order.discountPercent!.toStringAsFixed(0)}%'
        : '0%';

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _InfoCard(
          title: l10n.user,
          value: order.user,
          iconAsset: 'assets/icons/user.svg',
        ),
        _InfoCard(
          title: l10n.time,
          value: order.time,
          iconAsset: 'assets/icons/time.svg',
        ),
        _InfoCard(
          title: l10n.location,
          value: order.store,
          iconAsset: 'assets/icons/store.svg',
        ),
        _InfoCard(
          title: l10n.amount,
          value: CurrencyHelper.format(order.amount),
          iconAsset: 'assets/icons/cash.svg',
        ),
        _InfoCard(
          title: l10n.discount,
          value: discountText,
          iconAsset: 'assets/icons/discount.svg',
        ),
        _InfoCard(
          title: l10n.paytype,
          value: order.payType == 0 ? l10n.cash : l10n.card,
          iconAsset: 'assets/icons/paytype.svg',
        ),
      ],
    );
  }

  Widget _buildItemsSection(
    OrderDetailsResponseModel order,
    S l10n,
  ) {
    final items = order.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.items,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        // Header row on transparent background
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  l10n.item,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  l10n.qty,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  l10n.amount,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              if (items.isEmpty)
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.borderColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.noDataAvailable,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: items
                      .map(
                        (item) => Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppTheme.borderColor,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.primaryTextColor,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    item.quantity.toStringAsFixed(0),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.primaryTextColor,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    CurrencyHelper.format(item.amount),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.primaryTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
        // const SizedBox(height: 8),
        // Row(
        //   children: [
        //     const Expanded(
        //       flex: 4,
        //       child: SizedBox(),
        //     ),
        //     Expanded(
        //       flex: 3,
        //       child: Text(
        //         l10n.total,
        //         textAlign: TextAlign.center,
        //         style: const TextStyle(
        //           fontSize: 15,
        //           fontWeight: FontWeight.w600,
        //           color: AppTheme.primaryTextColor,
        //         ),
        //       ),
        //     ),
        //     Expanded(
        //       flex: 3,
        //       child: Text(
        //         CurrencyHelper.format(order.total),
        //         textAlign: TextAlign.right,
        //         style: const TextStyle(
        //           fontSize: 15,
        //           fontWeight: FontWeight.w700,
        //           color: AppTheme.primaryTextColor,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String iconAsset;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconAsset,
                width: 22,
                height: 22,
                colorFilter: const ColorFilter.mode(
                  AppTheme.primaryBlue,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
