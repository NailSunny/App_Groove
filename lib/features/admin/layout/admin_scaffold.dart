import 'package:flutter/material.dart';

class AdminScaffold extends StatelessWidget {
  final Widget child;

  const AdminScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151515),

      body: Column(
        children: [
          /// HEADER
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 30),

            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),

              border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
            ),

            child: Row(
              children: [
                _buildHeaderItem(title: "Главная", onTap: () {}),

                const SizedBox(width: 30),

                /// АРЕНДЫ
                _buildHeaderItem(title: "Аренды", onTap: () {}),

                const SizedBox(width: 30),

                /// РАСПИСАНИЕ
                _buildHeaderItem(title: "Расписание", onTap: () {}),

                const SizedBox(width: 30),

                /// ОТЧЕТЫ
                PopupMenuButton<String>(
                  color: const Color(0xFF2A2A2A),

                  offset: const Offset(0, 45),

                  child: Row(
                    children: const [
                      Text(
                        "Отчеты",

                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),

                      SizedBox(width: 4),

                      Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    ],
                  ),

                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: "finance",
                          child: Text(
                            "Финансы",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),

                        const PopupMenuItem(
                          value: "trainers",
                          child: Text(
                            "Тренеры",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),

                        const PopupMenuItem(
                          value: "attendance",
                          child: Text(
                            "Посещаемость",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],

                  onSelected: (value) {},
                ),
              ],
            ),
          ),

          /// ОСНОВНОЙ КОНТЕНТ
          Expanded(
            child: Row(
              children: [
                /// SIDEBAR
                Container(
                  width: 260,
                  color: const Color(0xFF1B1B1B),

                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      /// ПРОФИЛЬ
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),

                        child: Row(
                          children: [
                            /// АВАТАР
                            Container(
                              width: 60,
                              height: 60,

                              decoration: BoxDecoration(
                                color: const Color(0xFFAD03E2),
                                borderRadius: BorderRadius.circular(100),
                              ),

                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),

                            const SizedBox(width: 15),

                            /// ИНФОРМАЦИЯ
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: const [
                                  Text(
                                    "Администратор",

                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),

                                  SizedBox(height: 4),

                                  Text(
                                    "Иванов И.О.",

                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      /// ПУНКТЫ МЕНЮ
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 10),

                          children: [
                            _buildSidebarItem(
                              icon: Icons.people,
                              title: "Клиенты",
                              selected: true,
                            ),

                            _buildSidebarItem(
                              icon: Icons.credit_card,
                              title: "Абонементы",
                            ),

                            _buildSidebarItem(
                              icon: Icons.sports,
                              title: "Тренеры",
                            ),

                            _buildSidebarItem(
                              icon: Icons.music_note,
                              title: "Направления",
                            ),

                            _buildSidebarItem(
                              icon: Icons.meeting_room,
                              title: "Залы",
                            ),

                            _buildSidebarItem(
                              icon: Icons.shopping_cart,
                              title: "Покупки",
                            ),

                            _buildSidebarItem(
                              icon: Icons.article,
                              title: "Новости",
                            ),

                            _buildSidebarItem(
                              icon: Icons.business,
                              title: "Данные об орг.",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                /// КОНТЕНТ
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),

      onTap: onTap,

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

        child: Text(
          title,

          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    bool selected = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),

      decoration: BoxDecoration(
        color:
            selected
                ? const Color(0xFFAD03E2).withOpacity(0.15)
                : Colors.transparent,

        borderRadius: BorderRadius.circular(14),
      ),

      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? const Color(0xFFAD03E2) : Colors.white70,
        ),

        title: Text(
          title,

          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,

            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),

        onTap: () {},
      ),
    );
  }
}
