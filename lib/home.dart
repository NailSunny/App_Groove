import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final screenHeight = constraints.maxHeight;
              final screenWidth = constraints.maxWidth;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: screenHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.07),
                        Image.asset(
                          "images/Logo_Groove.png",
                          height: screenHeight * 0.1,
                          width: screenWidth * 0.6,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          "СТУДИЯ ТАНЦЕВ",
                          style: TextStyle(
                            fontFamily: 'RubikMonoOne',
                            fontSize: screenWidth * 0.04,
                            color: Color(0xFFC300FF),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Image.asset(
                          "images/Banner.png",
                          height: screenHeight * 0.5,
                          width: screenWidth * 0.7,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        _buildAdaptiveButton(
                          "Аренда",
                          '/arenda',
                          screenWidth,
                          screenHeight,
                          color: Color(0xFFFFCC32),
                        ),
                        _buildAdaptiveButton(
                          "Тренеры",
                          '/trainerlist',
                          screenWidth,
                          screenHeight,
                          color: Color(0xFFAD03E2),
                        ),
                        _buildAdaptiveButton(
                          "Магазин",
                          '/shop',
                          screenWidth,
                          screenHeight,
                          color: Color(0xFFFFCC32),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          color: const Color(0xFF643C70),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildButton(Icons.home, Colors.white, 0),
                              _buildButton(Icons.access_time, Colors.white, 1),
                              _buildButton(Icons.person, Colors.white, 2),
                              _buildButton(Icons.menu, Colors.white, 3),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (_isMenuOpen)
            Positioned(right: 0, top: 0, bottom: 53, child: _buildMenu()),
        ],
      ),
    );
  }

  bool _isHovered = false;
  int _hoveredIndex = -1;
  bool _isMenuOpen = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildButton(IconData icon, Color iconColor, int index) {
    return MouseRegion(
      onEnter:
          (_) => setState(() {
            _isHovered = true;
            _hoveredIndex = index;
          }),
      onExit:
          (_) => setState(() {
            _isHovered = false;
            _hoveredIndex = -1;
          }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _hoveredIndex == index ? Colors.yellow : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(icon, size: 32),
          color: _hoveredIndex == index ? Colors.white : iconColor,
          onPressed: () {
            if (index == 3) {
              // Для последней кнопки (меню)
              setState(() {
                _isMenuOpen = !_isMenuOpen;
              });
            } else if (index == 2) {
              Navigator.pushNamed(context, '/profile');
            } else if (index == 1) {
              Navigator.pushNamed(context, '/schedule');
            } else if (index == 0) {
              Navigator.pushNamed(context, '/home');
            } else {
              debugPrint('Нажата кнопка $index');
            }
          },
        ),
      ),
    );
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

  Widget _buildMenu() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      right: _isMenuOpen ? 0 : -300, // Ширина меню 300
      top: 0,
      bottom: 53, // Высота панели кнопок
      child: Container(
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
                const Text(
                  'Меню',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                const Divider(color: Colors.white54),
                _buildMenuItem('Абонементы', routeName: '/abonements'),
                _buildMenuItem('Покупки', routeName: '/purchase'),
                _buildMenuItem('Журнал записей', routeName: '/myjournal'),
                _buildMenuItem('Аренды', routeName: '/myarendalist'),
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
                  Navigator.pushNamed(context, '/');
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
      ),
    );
  }

  Widget _buildMenuItem(String text, {String? routeName}) {
    return ListTile(
      title: Text(text, style: const TextStyle(color: Colors.white)),
      onTap: () {
        setState(() => _isMenuOpen = false);
        if (routeName != null) {
          Navigator.pushNamed(context, routeName);
        }
      },
    );
  }
}
