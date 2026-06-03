import 'package:flutter/material.dart';

class AttendanceToggle extends StatelessWidget {
  final String attendance;
  final VoidCallback? onMarkPresent;
  final bool enabled;

  const AttendanceToggle({
    super.key,
    required this.attendance,
    this.onMarkPresent,
    this.enabled = true,
  });

  bool get isPresent => attendance == 'Present';
  bool get isAbsent => attendance == 'Absent';

  @override
  Widget build(BuildContext context) {
    if (isAbsent) {
      return const Icon(Icons.close, color: Colors.redAccent, size: 28);
    }
    if (isPresent) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 28);
    }
    return GestureDetector(
      onTap: enabled ? onMarkPresent : null,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.check, color: Theme.of(context).colorScheme.onSurface, size: 20),
      ),
    );
  }
}
