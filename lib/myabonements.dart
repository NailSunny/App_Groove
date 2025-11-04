import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/myabonement_dto.dart';
import 'package:groove_app/api_service/myabonement_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AbonementsPage extends StatefulWidget {
  const AbonementsPage({super.key});

  @override
  State<AbonementsPage> createState() => _AbonementsPageState();
}

class _AbonementsPageState extends State<AbonementsPage> {
  late Future<List<UserAbonementDto>> _abonementsFuture;

  @override
  void initState() {
    super.initState();

    loadData(); // вызываем async-метод// ← Подставить актуальный userId
    initializeDateFormatting('ru', null);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      // Не авторизован
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: пользователь не найден')));
      return;
    }

    setState(() {
      _abonementsFuture = fetchUserAbonements(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackBlack,
      appBar: AppBar(
        title: const Text(
          'АБОНЕМЕНТЫ',
          style: TextStyle(
            color: TextWhite,
            fontSize: 24,
            fontFamily: 'RubikMonoOne',
          ),
        ),
        centerTitle: true,
        backgroundColor: BackBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<UserAbonementDto>>(
        future: _abonementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Ошибка: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Нет активных абонементов',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final abonements = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: abonements.length,
            itemBuilder: (context, index) {
              final ab = abonements[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildSubscriptionCard(
                  orderNumber: ab.idPurchase.toString(),
                  title: ab.abonementName,
                  status: ab.status,
                  remaining:
                      '${ab.ostatok}/${ab.totalClasses}', // ← или вычисляй общее число из названия
                  issueDate: DateFormat(
                    'd MMMM',
                    'ru',
                  ).format(ab.dateActivation),
                  validUntil: DateFormat('d MMMM', 'ru').format(ab.dateEnd),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required String orderNumber,
    required String title,
    required String status,
    required String remaining,
    required String issueDate,
    required String validUntil,
  }) {
    return Card(
      color: BackBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ЗАКАЗ',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontFamily: 'RubikMonoOne',
              ),
            ),
            Text(
              orderNumber,
              style: const TextStyle(color: TextWhite, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: TextWhite,
                fontSize: 18,
                fontFamily: 'RubikMonoOne',
              ),
            ),
            const SizedBox(height: 8),
            _buildStatusChip(status),
            const SizedBox(height: 16),
            _buildInfoRow('ОСТАТОК', remaining),
            _buildInfoRow('ОФОРМЛЕН', issueDate),
            _buildInfoRow('ДЕЙСТВИТЕЛЕН ДО', validUntil),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'активен':
        chipColor = ActiveGreen;
        break;
      case 'закрыт':
        chipColor = UnactiveRed;
        break;
      case 'просрочен':
        chipColor = ProcessYellow;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'RubikMonoOne',
        ),
      ),
      backgroundColor: chipColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label ',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: TextWhite,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
