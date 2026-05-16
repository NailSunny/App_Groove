import 'package:flutter/material.dart';

class GroupClassDetailsPage extends StatefulWidget {
  final VoidCallback onBack;
  final Map<String, dynamic> classData;

  const GroupClassDetailsPage({
    super.key,
    required this.classData,
    required this.onBack,
  });

  @override
  State<GroupClassDetailsPage> createState() => _GroupClassDetailsPageState();
}

class _GroupClassDetailsPageState extends State<GroupClassDetailsPage> {
  final TextEditingController _searchController = TextEditingController();

  late List<Map<String, dynamic>> clients;

  String search = "";

  @override
  void initState() {
    super.initState();

    clients = [
      {
        "id": 1,
        "client": "Иванов И.И.",
        "date": "20.04.2026",
        "subscription": "Безлимит",
        "visited": false,
      },

      {
        "id": 2,
        "client": "Петров А.В.",
        "date": "19.04.2026",
        "subscription": "Разовое",
        "visited": true,
      },

      {
        "id": 3,
        "client": "Сидоров Д.К.",
        "date": "18.04.2026",
        "subscription": "Стандарт x8",
        "visited": false,
      },

      {
        "id": 4,
        "client": "Кузнецова Е.С.",
        "date": "17.04.2026",
        "subscription": "VIP",
        "visited": false,
      },

      {
        "id": 5,
        "client": "Смирнов А.Н.",
        "date": "16.04.2026",
        "subscription": "Безлимит",
        "visited": false,
      },

      {
        "id": 6,
        "client": "Васильева М.П.",
        "date": "15.04.2026",
        "subscription": "Стандарт x12",
        "visited": true,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final filtered =
        clients.where((item) {
          final client = item["client"].toString().toLowerCase();

          return client.contains(search.toLowerCase());
        }).toList();

    return SizedBox.expand(
      child: Container(
        color: const Color(0xFF151515),


        child: Padding(
          padding: const EdgeInsets.all(30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// ВЕРХНЯЯ ПАНЕЛЬ
              Row(
                children: [
                  /// НАЗАД
                  IconButton(
                    onPressed: widget.onBack,

                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),

                  const SizedBox(width: 20),

                  /// ИНФОРМАЦИЯ О ЗАНЯТИИ
                  Expanded(
                    child: Text(
                      "${widget.classData["direction"]} • "
                      "${widget.classData["time"]} • "
                      "Зал ${widget.classData["hall"]}",

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),

                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  /// ПОИСК
                  SizedBox(
                    width: 350,

                    child: TextField(
                      controller: _searchController,

                      onChanged: (value) {
                        setState(() {
                          search = value;
                        });
                      },

                      style: const TextStyle(color: Colors.white),

                      decoration: InputDecoration(
                        hintText: "Поиск клиента",

                        hintStyle: const TextStyle(color: Colors.white54),

                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white54,
                        ),

                        filled: true,
                        fillColor: const Color(0xFF2A2A2A),

                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),

                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// ТАБЛИЦА
              Expanded(
                child: Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Scrollbar(
                    thumbVisibility: true,

                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,

                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,

                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            const Color(0xFF2A2A2A),
                          ),

                          horizontalMargin: 20,
                          columnSpacing: 40,

                          dataRowMinHeight: 65,
                          dataRowMaxHeight: 65,

                          columns: const [
                            DataColumn(
                              label: Text(
                                "№",

                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            DataColumn(
                              label: Text(
                                "ФИО",

                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            DataColumn(
                              label: Text(
                                "Дата записи",

                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            DataColumn(
                              label: Text(
                                "Абонемент",

                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            DataColumn(
                              label: Text(
                                "Посещение",

                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],

                          rows:
                              filtered.map((item) {
                                final visited = item["visited"] as bool;

                                return DataRow(
                                  cells: [
                                    /// №
                                    DataCell(
                                      Text(
                                        item["id"].toString(),

                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),

                                    /// ФИО
                                    DataCell(
                                      SizedBox(
                                        width: 180,

                                        child: Text(
                                          item["client"].toString(),

                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),

                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),

                                    /// ДАТА
                                    DataCell(
                                      Text(
                                        item["date"].toString(),

                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),

                                    /// АБОНЕМЕНТ
                                    DataCell(
                                      Text(
                                        item["subscription"].toString(),

                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),

                                    /// ПОСЕЩЕНИЕ
                                    DataCell(
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            item["visited"] = true;
                                          });
                                        },

                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),

                                          width: 38,
                                          height: 38,

                                          decoration: BoxDecoration(
                                            color:
                                                visited
                                                    ? Colors.transparent
                                                    : Colors.green,

                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),

                                            border:
                                                visited
                                                    ? Border.all(
                                                      color: Colors.green,

                                                      width: 2,
                                                    )
                                                    : null,
                                          ),

                                          child: Icon(
                                            Icons.check,

                                            color:
                                                visited
                                                    ? Colors.green
                                                    : Colors.white,

                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
