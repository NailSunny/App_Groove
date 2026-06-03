import 'package:flutter/material.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/api_DTOs/news_banner_dto.dart';
import 'package:groove_app/api_service/admin_news_api.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/features/admin/widgets/admin_ui_helpers.dart';

class AdminNewsTab extends StatefulWidget {
  const AdminNewsTab({super.key});

  @override
  State<AdminNewsTab> createState() => _AdminNewsTabState();
}

class _AdminNewsTabState extends State<AdminNewsTab> {
  List<NewsBannerDto> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await fetchAdminNewsBanners();
      if (mounted)
        setState(() {
          _items = items;
          _loading = false;
        });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        showAdminError(context, e);
      }
    }
  }

  Future<void> _showForm({NewsBannerDto? item}) async {
    final orderCtrl = TextEditingController(
      text: (item?.displayOrder ?? (_items.length + 1)).toString(),
    );
    bool isActive = item?.isActive ?? true;
    String? pickedPath;

    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setDialog) => AlertDialog(
                  backgroundColor: Theme.of(context).cardColor,
                  title: Text(
                    item == null ? 'Новый баннер' : 'Редактировать баннер',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
                  content: SizedBox(
                    width: 420,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item != null && item.imageUrl.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Image.network(
                              item.imageUrl,
                              height: 120,
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (_, __, ___) => Icon(
                                    Icons.broken_image,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                                  ),
                            ),
                          ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final path = await pickBannerImagePath();
                            if (path != null)
                              setDialog(() => pickedPath = path);
                          },
                          icon: Icon(Icons.image, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                          label: Text(
                            pickedPath != null
                                ? 'Файл выбран'
                                : (item == null
                                    ? 'Выбрать изображение *'
                                    : 'Заменить изображение'),
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                          ),
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: orderCtrl,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          decoration: adminInputDecoration(context, 
                            'Порядок отображения',
                          ),
                        ),
                        CheckboxListTile(
                          value: isActive,
                          onChanged:
                              (v) => setDialog(() => isActive = v ?? true),
                          title: Text(
                            'Активен',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                          ),
                          activeColor: MainPurple,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Отмена'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (item == null && pickedPath == null) return;
                        if (int.tryParse(orderCtrl.text.trim()) == null) return;
                        Navigator.pop(ctx, true);
                      },
                      child: const Text('Сохранить'),
                    ),
                  ],
                ),
          ),
    );

    if (ok != true || !mounted) return;

    final displayOrder = int.parse(orderCtrl.text.trim());

    try {
      if (item == null) {
        await createAdminNewsBanner(
          filePath: pickedPath!,
          displayOrder: displayOrder,
          isActive: isActive,
        );
        showAdminSuccess(context, 'Баннер добавлен');
      } else {
        await updateAdminNewsBanner(
          id: item.id,
          filePath: pickedPath,
          displayOrder: displayOrder,
          isActive: isActive,
        );
        showAdminSuccess(context, 'Баннер обновлён');
      }
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  Future<void> _confirmDelete(NewsBannerDto item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text(
              'Удалить баннер?',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            content: Text(
              'Изображение будет удалено с сервера.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Удалить'),
              ),
            ],
          ),
    );
    if (ok != true || !mounted) return;

    try {
      await deleteAdminNewsBanner(item.id);
      showAdminSuccess(context, 'Баннер удалён');
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Новости',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showForm(),
                icon: const Icon(Icons.add),
                label: const Text('Добавить баннер'),
                style: ElevatedButton.styleFrom(backgroundColor: MainPurple),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child:
                _loading
                    ? Center(
                      child: CircularProgressIndicator(color: MainPurple),
                    )
                    : _items.isEmpty
                    ? Center(
                      child: Text(
                        'Баннеров пока нет',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 16),
                      ),
                    )
                    : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.groove.headerBackground,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.imageUrl,
                                  width: 160,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => Container(
                                        width: 160,
                                        height: 90,
                                        color: Theme.of(context).cardColor,
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                                        ),
                                      ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Порядок: ${item.displayOrder}',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.isActive ? 'Активен' : 'Неактивен',
                                      style: TextStyle(
                                        color:
                                            item.isActive
                                                ? Colors.greenAccent
                                                : Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                                onPressed: () => _showForm(item: item),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => _confirmDelete(item),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
