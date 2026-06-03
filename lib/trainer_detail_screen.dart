import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/trainer_dto.dart';
import 'package:groove_app/api_service/api_trainers.dart';
import 'package:groove_app/widgets/api_network_image.dart';

class TrainerDetailScreen extends StatefulWidget {
  final int trainerId;

  const TrainerDetailScreen({super.key, required this.trainerId});

  @override
  State<TrainerDetailScreen> createState() => _TrainerDetailScreenState();
}

class _TrainerDetailScreenState extends State<TrainerDetailScreen> {
  TrainerDto? _trainer;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final trainer = await fetchTrainerById(widget.trainerId);
      if (mounted) setState(() { _trainer = trainer; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Color(0xFF643C70),
        title: Text('Тренер', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFAD03E2)))
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))))
              : _buildContent(_trainer!),
    );
  }

  Widget _buildContent(TrainerDto trainer) {
    final directions = trainer.directionNames;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipOval(
            child: trainer.photo.isNotEmpty
                ? ApiNetworkImage(
                    imageUrl: trainer.photo,
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                    cacheKey: 'trainer-detail-${trainer.id}',
                  )
                : Image.asset('images/default_avatar.png', width: 140, height: 140, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Text(
            '${trainer.surname} ${trainer.name}'.trim(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFCC32),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (directions.isNotEmpty) ...[
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Направления', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14)),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: directions
                  .map((d) => Chip(
                        label: Text(d, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                        backgroundColor: Color(0xFF8E5D9F),
                      ))
                  .toList(),
            ),
          ],
          if (trainer.information.trim().isNotEmpty) ...[
            SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('О тренере', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14)),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                trainer.information.trim(),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15, height: 1.4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
