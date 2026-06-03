import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/hall_rental_dto.dart';
import 'package:groove_app/api_service/hall_rental_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class MyarendalistPage extends StatefulWidget {
  const MyarendalistPage({super.key});

  @override
  State<MyarendalistPage> createState() => _MyarendalistPageState();
}

class _MyarendalistPageState extends State<MyarendalistPage> {
  List<MyHallRentalDto> _rentals = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru', null);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await fetchMyHallRentals();
      data.sort((a, b) => b.dateArenda.compareTo(a.dateArenda));
      if (!mounted) return;
      setState(() {
        _rentals = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _cancel(MyHallRentalDto rental) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Отмена аренды', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(
          'Отменить аренду ${DateFormat('dd.MM.yyyy HH:mm', 'ru').format(rental.startTime)}?\n'
          'На баланс вернётся ${rental.sum} ₽.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Нет'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Отменить', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await cancelMyHallRental(rental.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Аренда отменена')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Мои аренды', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: BackButton(color: Theme.of(context).colorScheme.onSurface),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.onSurface),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFAD03E2)))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _load,
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
                  ),
                )
              : _rentals.isEmpty
                  ? Center(
                      child: Text(
                        'У вас пока нет аренд',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: const Color(0xFFAD03E2),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _rentals.length,
                        itemBuilder: (context, index) =>
                            _buildRentCard(_rentals[index]),
                      ),
                    ),
    );
  }

  Widget _buildRentCard(MyHallRentalDto rental) {
    final dateFormat = DateFormat('dd MMMM yyyy HH:mm', 'ru');
    final isCancelled = rental.isCancelled;
    final isCompleted = rental.isCompleted;
    final statusColor = isCancelled || isCompleted
        ? Colors.white54
        : Color(0xFFFFCC32);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCancelled || isCompleted ? Colors.white24 : Colors.grey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                rental.displayStatusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${rental.sum} ₽',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Оформлено: ${DateFormat('dd MMMM yyyy', 'ru').format(rental.dateArenda)}',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Начало: ${dateFormat.format(rental.startTime)}',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          SizedBox(height: 4),
          Text(
            'Окончание: ${DateFormat('HH:mm', 'ru').format(rental.endTime)}',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
          ),
          SizedBox(height: 8),
          Text(
            'Длительность: ${rental.durationHours} ч',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          SizedBox(height: 4),
          Text(
            'Зал: ${rental.hallNumber ?? '—'}',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          if (rental.canCancel) ...[
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _cancel(rental),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
              ),
              child: Text(
                'ОТМЕНИТЬ',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
