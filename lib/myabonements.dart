import 'package:flutter/material.dart';

import 'package:groove_app/api_DTOs/myabonement_dto.dart';

import 'package:groove_app/api_service/myabonement_service.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'package:intl/intl.dart';

import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/designs/groove_page_styles.dart';

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
    initializeDateFormatting('ru', null);
    _abonementsFuture = _loadAbonements();
  }

  Future<List<UserAbonementDto>> _loadAbonements() async {
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

    final list = await fetchUserAbonements(userId);
    list.sort((a, b) => b.dateActivation.compareTo(a.dateActivation));
    return list;
  }

  Future<void> loadData() async {
    setState(() {
      _abonementsFuture = _loadAbonements();
    });
  }



  Future<void> _confirmFreeze(UserAbonementDto ab) async {

    final ok = await showDialog<bool>(

      context: context,

      builder: (ctx) => AlertDialog(

        backgroundColor: Theme.of(context).cardColor,

        title: Text('Заморозить абонемент?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),

        content: Text(

          'На время заморозки абонемент нельзя использовать для записи. Срок действия будет продлён.',

          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),

        ),

        actions: [

          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),

          TextButton(

            onPressed: () => Navigator.pop(ctx, true),

            child: const Text('Заморозить', style: TextStyle(color: Colors.orangeAccent)),

          ),

        ],

      ),

    );

    if (ok != true || !mounted) return;



    try {

      final msg = await freezeMembership(ab.idActive);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

      loadData();

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),

      );

    }

  }



  Future<void> _confirmUnfreeze(UserAbonementDto ab) async {

    final ok = await showDialog<bool>(

      context: context,

      builder: (ctx) => AlertDialog(

        backgroundColor: Theme.of(context).cardColor,

        title: Text('Разморозить абонемент?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),

        content: Text(

          'Абонемент снова станет доступен для записи на занятия.',

          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),

        ),

        actions: [

          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),

          TextButton(

            onPressed: () => Navigator.pop(ctx, true),

            child: const Text('Разморозить', style: TextStyle(color: Color(0xFFAD03E2))),

          ),

        ],

      ),

    );

    if (ok != true || !mounted) return;



    try {

      final msg = await unfreezeMembership(ab.idActive);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

      loadData();

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),

      );

    }

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(

        title: Text('АБОНЕМЕНТЫ', style: GroovePageStyles.title(context)),

        centerTitle: true,

        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        elevation: 0,

        leading: IconButton(

          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),

          onPressed: () => Navigator.pop(context),

        ),

      ),

      body: FutureBuilder<List<UserAbonementDto>>(

        future: _abonementsFuture,

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {

            return Center(

              child: const CircularProgressIndicator(color: MainPurple),

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

              child: Text(

                'Нет активных абонементов',

                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),

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

                child: _buildSubscriptionCard(ab: ab),

              );

            },

          );

        },

      ),

    );

  }



  Widget _buildSubscriptionCard({required UserAbonementDto ab}) {

    final orderLabel = ab.idPurchase > 0 ? ab.idPurchase.toString() : '—';

    return Card(

      color: GroovePageStyles.cardBackground(context),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(

              'ЗАКАЗ',

              style: GroovePageStyles.muted(context, size: 12),

            ),

            Text(

              orderLabel,

              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),

            ),

            SizedBox(height: 12),

            Text(

              ab.abonementName,

              style: GroovePageStyles.body(context, size: 18).copyWith(
                fontWeight: FontWeight.bold,
              ),

            ),

            const SizedBox(height: 8),

            _buildStatusChip(ab.status),

            const SizedBox(height: 16),

            _buildInfoRow('ОСТАТОК', '${ab.ostatok}/${ab.totalClasses}'),

            _buildInfoRow(

              'ОФОРМЛЕН',

              DateFormat('d MMMM yyyy', 'ru').format(ab.dateActivation),

            ),

            _buildInfoRow(

              'ДЕЙСТВИТЕЛЕН ДО',

              DateFormat('d MMMM yyyy', 'ru').format(ab.dateEnd),

            ),

            if (ab.canFreeze) ...[

              const SizedBox(height: 12),

              SizedBox(

                width: double.infinity,

                child: OutlinedButton(

                  onPressed: () => _confirmFreeze(ab),

                  style: OutlinedButton.styleFrom(

                    foregroundColor: Colors.orangeAccent,

                    side: const BorderSide(color: Colors.orangeAccent),

                  ),

                  child: const Text('ЗАМОРОЗИТЬ'),

                ),

              ),

            ],

            if (ab.canUnfreeze) ...[

              const SizedBox(height: 12),

              SizedBox(

                width: double.infinity,

                child: ElevatedButton(

                  onPressed: () => _confirmUnfreeze(ab),

                  style: ElevatedButton.styleFrom(

                    backgroundColor: Color(0xFFAD03E2),

                  ),

                  child: Text('РАЗМОРОЗИТЬ', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),

                ),

              ),

            ],

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

      case 'заморожен':

        chipColor = Colors.lightBlue;

        break;

      case 'закрыт':

      case 'отменён':

        chipColor = UnactiveRed;

        break;

      case 'истёк':

      case 'просрочен':

        chipColor = ProcessYellow;

        break;

      default:

        chipColor = Colors.grey;

    }



    return Chip(

      label: Text(

        status.toUpperCase(),

        style: GroovePageStyles.body(context, size: 12),

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

            style: GroovePageStyles.muted(context, size: 14),

          ),

          Text(

            value,

            style: TextStyle(

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

