import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/hall_rental_dto.dart';
import 'package:groove_app/api_service/hall_rental_service.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/designs/groove_page_styles.dart';
import 'package:intl/intl.dart';

class RentalSlotSelectionScreen extends StatefulWidget {
  final DateTime date;

  const RentalSlotSelectionScreen({super.key, required this.date});

  @override
  State<RentalSlotSelectionScreen> createState() =>
      _RentalSlotSelectionScreenState();
}

class _RentalSlotSelectionScreenState extends State<RentalSlotSelectionScreen> {
  List<String> _availableSlots = [];
  final Set<String> _selected = {};
  bool _loading = true;
  bool _paying = false;
  String? _error;

  int get _price => _selected.length * 600;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final slots = await fetchAvailableRentalSlots(widget.date);
      if (!mounted) return;
      setState(() {
        _availableSlots = slots.map((s) => s.startTime).toList();
        _selected.clear();
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

  void _toggleSlot(String slot) {
    setState(() {
      if (_selected.contains(slot)) {
        _selected.remove(slot);
      } else {
        _selected.add(slot);
      }
    });
  }

  Future<void> _pay() async {
    if (_selected.isEmpty) return;

    final times = _selected.toList()..sort();

    setState(() => _paying = true);
    try {
      final result = await createHallRental(
        CreateHallRentalDto(
          date: widget.date,
          startTimes: times,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.rentalCount > 1
                ? 'Оформлено аренд: ${result.rentalCount}, ${result.totalPrice} ₽'
                : 'Аренда успешно оформлена (${result.totalPrice} ₽)',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final dateLabel = DateFormat('d MMMM yyyy', 'ru').format(widget.date);
    final sortedSelected = _selected.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text('Аренда — $dateLabel', style: GroovePageStyles.title(context, size: 18)),
        iconTheme: IconThemeData(color: onSurface),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: MainPurple))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                  Text(
                    'Выберите один или несколько слотов (600 ₽ за каждый час)',
                    style: GroovePageStyles.muted(context, size: 14),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _availableSlots.isEmpty
                        ? Center(
                            child: Text(
                              'Нет свободных слотов на этот день',
                              style: GroovePageStyles.muted(context),
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableSlots.map((slot) {
                              final selected = _selected.contains(slot);
                              return OutlinedButton(
                                onPressed: () => _toggleSlot(slot),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: selected
                                      ? ProcessYellow
                                      : Colors.transparent,
                                  foregroundColor:
                                      selected ? Colors.black : onSurface,
                                  side: const BorderSide(color: ProcessYellow),
                                ),
                                child: Text(
                                  slot,
                                  style: const TextStyle(
                                    fontFamily: GroovePageStyles.fontFamily,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  if (_selected.isNotEmpty) ...[
                    Text(
                      'Выбрано: ${sortedSelected.join(', ')}',
                      style: GroovePageStyles.muted(context, size: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Итого: $_price ₽ (${_selected.length} ч)',
                      style: GroovePageStyles.body(context, size: 18).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _paying ? null : _pay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ProcessYellow,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _paying
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Оплатить',
                              style: TextStyle(
                                fontFamily: GroovePageStyles.fontFamily,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
