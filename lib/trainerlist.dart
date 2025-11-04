import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/trainer_dto.dart';
import 'package:groove_app/api_service/api_trainers.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.popAndPushNamed(context, '/home'),
        ),
        title: const Text(
          "Список тренеров",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<TrainerDto>>(
        future: _trainersFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return Center(child: Text("Список тренеров пуст"));
            }
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Ошибка: ${snapshot.error}"));
          }

          final trainers = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: trainers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final trainer = trainers[index];
              return CoachCard(
                name: trainer.name,
                surname: trainer.surname,
                style: trainer.information,
                imageUrl: trainer.photo,
              );
            },
          );
        },
      ),
    );
  }
}

class CoachCard extends StatelessWidget {
  final String name;
  final String surname;
  final String style;
  final String imageUrl;

  const CoachCard({
    super.key,
    required this.name,
    required this.surname,
    required this.style,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF8E5D9F),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image:
                        imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : const AssetImage("images/default_avatar.png")
                                as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name $surname',
                      style: const TextStyle(
                        color: Color(0xFFFFCC32),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      style,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
