import 'package:flutter/material.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/api_DTOs/organization_dto.dart';
import 'package:groove_app/api_service/admin_api.dart';
import 'package:groove_app/api_service/admin_organization_api.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/features/admin/widgets/admin_ui_helpers.dart';

class AdminOrganizationTab extends StatefulWidget {
  const AdminOrganizationTab({super.key});

  @override
  State<AdminOrganizationTab> createState() => _AdminOrganizationTabState();
}

class _AdminOrganizationTabState extends State<AdminOrganizationTab> {
  OrganizationDto? _data;
  bool _loading = true;
  bool _saving = false;

  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _vkCtrl = TextEditingController();
  String? _logoPath;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _vkCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await fetchAdminOrganization();
      if (!mounted) return;
      _addressCtrl.text = data.address ?? '';
      _phoneCtrl.text = data.phone ?? '';
      _vkCtrl.text = data.vkUrl ?? '';
      setState(() { _data = data; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        showAdminError(context, e);
      }
    }
  }

  Future<void> _saveOrganization() async {
    setState(() => _saving = true);
    try {
      final data = await updateAdminOrganization(
        address: _addressCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        vkUrl: _vkCtrl.text.trim(),
        logoPath: _logoPath,
      );
      if (!mounted) return;
      setState(() {
        _data = data;
        _logoPath = null;
        _saving = false;
      });
      showAdminSuccess(context, 'Данные сохранены');
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showAdminError(context, e);
      }
    }
  }

  Future<void> _uploadHallPhoto(OrganizationHallDto hall) async {
    final path = await pickOrganizationImagePath();
    if (path == null || !mounted) return;

    try {
      await uploadAdminHallPhoto(hallId: hall.idHall, filePath: path);
      showAdminSuccess(context, 'Фото зала обновлено');
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  Future<void> _saveHallParameters(OrganizationHallDto hall, String parameters) async {
    try {
      await updateHall(hall.idHall, {'parameters': parameters.trim()});
      showAdminSuccess(context, 'Параметры зала сохранены');
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  Future<void> _deleteHallPhoto(OrganizationHallDto hall) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Удалить фото зала?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      await deleteAdminHallPhoto(hall.idHall);
      showAdminSuccess(context, 'Фото удалено');
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: MainPurple));
    }

    final halls = _data?.halls ?? [];

    return Padding(
      padding: EdgeInsets.all(30),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Данные об организации',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.groove.headerBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_data?.logoUrl != null && _data!.logoUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Image.network(
                        _data!.logoUrl!,
                        height: 80,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => SizedBox.shrink(),
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final path = await pickOrganizationImagePath();
                      if (path != null) setState(() => _logoPath = path);
                    },
                    icon: Icon(Icons.image, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                    label: Text(
                      _logoPath != null ? 'Новый логотип выбран' : 'Загрузить логотип',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _addressCtrl,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: adminInputDecoration(context, 'Адрес'),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _phoneCtrl,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: adminInputDecoration(context, 'Телефон'),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _vkCtrl,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: adminInputDecoration(context, 'Ссылка VK'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saving ? null : _saveOrganization,
                    style: ElevatedButton.styleFrom(backgroundColor: MainPurple),
                    child: _saving
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onSurface),
                          )
                        : Text('Сохранить'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Фото залов',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...halls.map((hall) => _HallEditorCard(
              hall: hall,
              onUploadPhoto: () => _uploadHallPhoto(hall),
              onDeletePhoto: () => _deleteHallPhoto(hall),
              onSaveParameters: (params) => _saveHallParameters(hall, params),
            )),
          ],
        ),
      ),
    );
  }
}

class _HallEditorCard extends StatefulWidget {
  final OrganizationHallDto hall;
  final VoidCallback onUploadPhoto;
  final VoidCallback onDeletePhoto;
  final Future<void> Function(String parameters) onSaveParameters;

  const _HallEditorCard({
    required this.hall,
    required this.onUploadPhoto,
    required this.onDeletePhoto,
    required this.onSaveParameters,
  });

  @override
  State<_HallEditorCard> createState() => _HallEditorCardState();
}

class _HallEditorCardState extends State<_HallEditorCard> {
  late final TextEditingController _parametersCtrl;

  @override
  void initState() {
    super.initState();
    _parametersCtrl = TextEditingController(text: widget.hall.parameters ?? '');
  }

  @override
  void didUpdateWidget(covariant _HallEditorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hall.parameters != widget.hall.parameters) {
      _parametersCtrl.text = widget.hall.parameters ?? '';
    }
  }

  @override
  void dispose() {
    _parametersCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hall = widget.hall;
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.groove.headerBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hall.photoUrl != null && hall.photoUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    hall.photoUrl!,
                    width: 120,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => SizedBox(width: 120, height: 80),
                  ),
                )
              else
                Container(
                  width: 120,
                  height: 80,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Нет фото', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 12)),
                ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hall.numberHall ?? 'Зал ${hall.idHall}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: widget.onUploadPhoto,
                          child: const Text('Загрузить/заменить фото'),
                        ),
                        if (hall.photoUrl != null && hall.photoUrl!.isNotEmpty)
                          TextButton(
                            onPressed: widget.onDeletePhoto,
                            child: const Text('Удалить фото', style: TextStyle(color: Colors.redAccent)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          TextField(
            controller: _parametersCtrl,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: adminInputDecoration(context, 'Параметры (размеры), напр. 8,5м × 7м'),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => widget.onSaveParameters(_parametersCtrl.text),
              child: const Text('Сохранить параметры'),
            ),
          ),
        ],
      ),
    );
  }
}
