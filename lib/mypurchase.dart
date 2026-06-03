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
    initializeDateFormatting('ru', null);
    _purchasesFuture = _loadPurchases();
  }

  Future<List<PurchaseDto>> _loadPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка: пользователь не найден')),
        );
      }
      return [];
    }

    final list = await fetchPurchases(userId);
    list.sort((a, b) => b.datePurchase.compareTo(a.datePurchase));
    return list;
  }

  Future<void> loadData() async {
    setState(() {
      _purchasesFuture = _loadPurchases();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'ПОКУПКИ',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 24,
            fontFamily: 'RubikMonoOne',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<PurchaseDto>>(
        future: _purchasesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Ошибка: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Нет покупок', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
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
                  purchase: p,
                  orderNumber: p.idPurchase.toString(),
                  issueDate: DateFormat('d MMMM yyyy', 'ru').format(p.datePurchase),
                  items: items,
                  discount: p.discount != null ? '${p.discount}%' : '-',
                  amount: '${p.totalBeforeDiscount}',
                  total: '${p.totalAfterDiscount}',
                  onCancel: p.canCancel ? () => _confirmCancelPurchase(p) : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmCancelPurchase(PurchaseDto purchase) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Отменить покупку?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(
          'Абонементы будут удалены, сумма вернётся на баланс. Действие нельзя отменить.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Нет')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Отменить', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      final msg = await cancelPurchase(purchase.idPurchase);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      await loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget _buildPurchaseItem({
    required PurchaseDto purchase,
    required String orderNumber,
    required String issueDate,
    required List<String> items,
    required String discount,
    required String amount,
    required String total,
    VoidCallback? onCancel,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    item,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
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
          if (purchase.status.toLowerCase() == 'cancelled') ...[
            const SizedBox(height: 12),
            const Text('Отменена', style: TextStyle(color: Colors.redAccent)),
          ],
          if (onCancel != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                ),
                child: Text('Отменить покупку', style: TextStyle(color: Colors.redAccent)),
              ),
            ),
          ] else if (purchase.status.toLowerCase() == 'active' &&
              purchase.items.any((i) => i.abonementName.toLowerCase().contains('пробн'))) ...[
            SizedBox(height: 12),
            Text(
              'Пробный абонемент нельзя отменить',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 13),
            ),
          ],
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
                TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
