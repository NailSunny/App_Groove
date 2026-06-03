import 'dart:async';

import 'package:flutter/material.dart';
import 'package:groove_app/widgets/groove_logo.dart';
import 'package:groove_app/api_DTOs/news_banner_dto.dart';
import 'package:groove_app/api_service/client_news_api.dart';
import 'package:groove_app/helper/mobile_auth_navigation.dart';
import 'package:groove_app/routes/mobile_routes.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/widgets/api_network_image.dart';
import 'package:groove_app/widgets/theme_mode_switch.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double _bottomNavHeight = 56;

  List<ClientNewsBannerDto> _banners = [];
  bool _bannersLoading = true;
  int _carouselIndex = 0;
  final PageController _bannerPageController = PageController();
  Timer? _bannerAutoPlayTimer;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  @override
  void dispose() {
    _bannerAutoPlayTimer?.cancel();
    _bannerPageController.dispose();
    super.dispose();
  }

  Future<void> _loadBanners() async {
    try {
      final items = await fetchClientNewsBanners();
      if (!mounted) return;
      setState(() {
        _banners = items;
        _bannersLoading = false;
        _carouselIndex = 0;
      });
      _restartBannerAutoPlay();
      if (_bannerPageController.hasClients) {
        _bannerPageController.jumpToPage(0);
      }
    } catch (_) {
      if (mounted) setState(() { _banners = []; _bannersLoading = false; });
    }
  }

  void _restartBannerAutoPlay() {
    _bannerAutoPlayTimer?.cancel();
    if (_banners.length <= 1) return;

    _bannerAutoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_bannerPageController.hasClients) return;
      final next = (_carouselIndex + 1) % _banners.length;
      _bannerPageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  Widget _buildBannerSection(double screenHeight, double screenWidth) {
    if (_bannersLoading) {
      return SizedBox(
        height: screenHeight * 0.35,
        child: const Center(child: CircularProgressIndicator(color: Color(0xFFAD03E2))),
      );
    }

    if (_banners.isEmpty) {
      return Image.asset(
        "images/Banner.png",
        height: screenHeight * 0.5,
        width: screenWidth * 0.7,
        fit: BoxFit.contain,
      );
    }

    final bannerHeight = screenHeight * 0.42;

    return Column(
      children: [
        SizedBox(
          height: bannerHeight,
          width: screenWidth,
          child: PageView.builder(
            controller: _bannerPageController,
            itemCount: _banners.length,
            onPageChanged: (index) => setState(() => _carouselIndex = index),
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: ApiNetworkImage(
                  imageUrl: banner.imageUrl,
                  width: screenWidth * 0.92,
                  height: bannerHeight,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(12),
                  cacheKey: 'home-banner-${banner.id}',
                  errorWidget: Image.asset(
                    'images/Banner.png',
                    width: screenWidth * 0.92,
                    height: bannerHeight,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        ),
        if (_banners.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_banners.length, (i) {
              return Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _carouselIndex
                      ? Color(0xFFFFCC32)
                      : context.groove.carouselDotInactive,
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenHeight = constraints.maxHeight;
                    final screenWidth = constraints.maxWidth;

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: screenHeight * 0.07),
                          GrooveLogo(
                            height: screenHeight * 0.1,
                            width: screenWidth * 0.6,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            'СТУДИЯ ТАНЦЕВ',
                            style: TextStyle(
                              fontFamily: 'RubikMonoOne',
                              fontSize: screenWidth * 0.04,
                              color: const Color(0xFFC300FF),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          _buildBannerSection(screenHeight, screenWidth),
                          SizedBox(height: screenHeight * 0.03),
                          _buildAdaptiveButton(
                            'Аренда',
                            MobileRoutes.arenda,
                            screenWidth,
                            screenHeight,
                            color: const Color(0xFFFFCC32),
                          ),
                          _buildAdaptiveButton(
                            'Тренеры',
                            MobileRoutes.trainerList,
                            screenWidth,
                            screenHeight,
                            color: const Color(0xFFAD03E2),
                          ),
                          _buildAdaptiveButton(
                            'Магазин',
                            MobileRoutes.shop,
                            screenWidth,
                            screenHeight,
                            color: const Color(0xFFFFCC32),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                        ],
                      ),
                    );
                  },
                ),
              ),
              _buildBottomNavBar(),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: _isMenuOpen ? 0 : -300,
            top: 0,
            bottom: _bottomBarTotalHeight(context),
            child: IgnorePointer(
              ignoring: !_isMenuOpen,
              child: _buildMenuPanel(),
            ),
          ),
        ],
      ),
    );
  }

  double _bottomBarTotalHeight(BuildContext context) {
    return _bottomNavHeight + MediaQuery.paddingOf(context).bottom;
  }

  Widget _buildBottomNavBar() {
    return SafeArea(
      top: false,
      child: Container(
        height: _bottomNavHeight,
        color: const Color(0xFF643C70),
        child: Row(
          children: [
            _buildButton(Icons.home, Colors.white, 0),
            _buildButton(Icons.access_time, Colors.white, 1),
            _buildButton(Icons.person, Colors.white, 2),
            _buildButton(Icons.menu, Colors.white, 3),
          ],
        ),
      ),
    );
  }

  int _hoveredIndex = -1;
  bool _isMenuOpen = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildButton(IconData icon, Color iconColor, int index) {
    final hovered = _hoveredIndex == index;

    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = -1),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onBottomNavTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _bottomNavHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: hovered ? Colors.yellow : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: hovered ? Colors.white : iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    if (index == 3) {
      setState(() => _isMenuOpen = !_isMenuOpen);
      return;
    }
    setState(() => _isMenuOpen = false);
    switch (index) {
      case 0:
        Navigator.pushNamed(context, MobileRoutes.home);
      case 1:
        Navigator.pushNamed(context, MobileRoutes.schedule);
      case 2:
        Navigator.pushNamed(context, MobileRoutes.profile);
    }
  }

  Widget _buildAdaptiveButton(
    String label,
    String route,
    double screenWidth,
    double screenHeight, {
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.015),
      child: Container(
        height: screenHeight * 0.05,
        width: screenWidth * 0.55,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              color: Color(0xFFFFFFFF).withOpacity(0.25),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, route),
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Theme.of(context).primaryColor,
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildMenuPanel() {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Color(0xFF9C68AC),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Меню',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 24,
                ),
              ),
              ThemeModeSwitch(),
              SizedBox(height: 12),
              Divider(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
              _buildMenuItem('Абонементы', routeName: MobileRoutes.abonements),
              _buildMenuItem('Покупки', routeName: MobileRoutes.purchases),
              _buildMenuItem('Журнал записей', routeName: MobileRoutes.journal),
              _buildMenuItem('Аренды', routeName: MobileRoutes.arendaList),
              _buildMenuItem('Контакты', routeName: MobileRoutes.contacts),
            ],
          ),
          Center(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFFFFCC32), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                navigateToMobileAuth(context);
              },
              icon: Icon(Icons.exit_to_app, color: Color(0xFFFFCC32)),
              label: Text(
                "Выход",
                style: TextStyle(color: Color(0xFFFFCC32)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String text, {String? routeName}) {
    return ListTile(
      title: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      onTap: () {
        setState(() => _isMenuOpen = false);
        if (routeName != null) {
          Navigator.pushNamed(context, routeName);
        }
      },
    );
  }
}
