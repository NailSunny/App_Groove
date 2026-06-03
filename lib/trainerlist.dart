import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/trainer_dto.dart';
import 'package:groove_app/api_service/api_trainers.dart';
import 'package:groove_app/routes/mobile_routes.dart';
import 'package:groove_app/trainer_detail_screen.dart';
import 'package:groove_app/widgets/api_network_image.dart';

class TrainerlistPage extends StatefulWidget {
  const TrainerlistPage({super.key});

  @override
  State<TrainerlistPage> createState() => _TrainerlistPageState();
}

class _TrainerlistPageState extends State<TrainerlistPage> {
  late Future<List<TrainerDto>> _trainersFuture;

  @override
  void initState() {
    super.initState();
    _trainersFuture = fetchTrainers();
  }

  void _openTrainer(TrainerDto trainer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrainerDetailScreen(trainerId: trainer.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.popAndPushNamed(context, MobileRoutes.home),
        ),
        title: Text('Список тренеров', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      ),
      body: FutureBuilder<List<TrainerDto>>(
        future: _trainersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Список тренеров пуст'));
          }

          final trainers = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: trainers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final trainer = trainers[index];
              return CoachCard(
                trainer: trainer,
                onTap: () => _openTrainer(trainer),
              );
            },
          );
        },
      ),
    );
  }
}

class CoachCard extends StatelessWidget {
  final TrainerDto trainer;
  final VoidCallback onTap;

  const CoachCard({super.key, required this.trainer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final directionsText = trainer.directionNames.isEmpty
        ? 'Направления не указаны'
        : trainer.directionNames.join(', ');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF8E5D9F),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: trainer.photo.isNotEmpty
                        ? ApiNetworkImage(
                            imageUrl: trainer.photo,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            cacheKey: 'trainer-list-${trainer.id}',
                          )
                        : Image.asset('images/default_avatar.png', fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${trainer.name} ${trainer.surname}'.trim(),
                        style: const TextStyle(
                          color: Color(0xFFFFCC32),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        directionsText,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.onSurface),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
