import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/mypurchase_dto.dart';
import 'package:groove_app/api_service/mypurchase_service.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  late Future<List<PurchaseDto>> _purchasesFuture;

  @override
  void initState() {
    super.initState();
    loadData();
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
      _purchasesFuture = fetchPurchases(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackBlack,
      appBar: AppBar(
        title: const Text(
          'ПОКУПКИ',
          style: TextStyle(
            color: TextWhite,
            fontSize: 24,
            fontFamily: 'RubikMonoOne',
            fontWeight: FontWeight.bold,
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
      body: FutureBuilder<List<PurchaseDto>>(
        future: _purchasesFuture,
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
              child: Text('Нет покупок', style: TextStyle(color: Colors.white)),
            );
          }

          final purchases = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              final p = purchases[index];
              final items =
                  p.items
                      .map(
                        (i) =>
                            '${i.abonementName}: ${i.quantity} × ${i.unitPrice}₽',
                      )
                      .toList();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPurchaseItem(
                  orderNumber: p.idPurchase.toString(),
                  issueDate: DateFormat('d MMMM', 'ru').format(p.datePurchase),
                  items: items,
                  discount: p.discount != null ? '${p.discount}%' : '-',
                  amount: '${p.totalBeforeDiscount}',
                  total: '${p.totalAfterDiscount}',
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPurchaseItem({
    required String orderNumber,
    required String issueDate,
    required List<String> items,
    required String discount,
    required String amount,
    required String total,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('ЗАКАЗ', orderNumber),
          _buildInfoRow('ОФОРМЛЕН', issueDate),
          const SizedBox(height: 12),
          const Text(
            'СОСТАВ',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontFamily: 'RubikMonoOne',
            ),
          ),
          ...items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    item,
                    style: const TextStyle(color: TextWhite, fontSize: 14),
                  ),
                ),
              )
              .toList(),
          const SizedBox(height: 12),
          _buildInfoRow('СКИДКА', discount),
          _buildInfoRow('СУММА', '$amount ₽'),
          const Divider(color: Colors.grey, height: 24),
          _buildInfoRow(
            'ИТОГО',
            '$total ₽',
            valueStyle: const TextStyle(
              color: ProcessYellow,
              fontSize: 16,
              fontFamily: 'RubikMonoOne',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontFamily: 'RubikMonoOne',
            ),
          ),
          Text(
            value,
            style:
                valueStyle ??
                const TextStyle(
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
