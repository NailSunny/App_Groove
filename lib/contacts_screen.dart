import 'package:flutter/material.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/api_DTOs/organization_dto.dart';
import 'package:groove_app/api_service/client_organization_api.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/designs/groove_page_styles.dart';
import 'package:groove_app/widgets/api_network_image.dart';
import 'package:groove_app/widgets/groove_logo.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  ClientOrganizationDto? _data;
  bool _loading = true;
  String? _error;

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
      final data = await fetchClientOrganization();
      if (mounted) setState(() { _data = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'\s'), ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openVk(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Color(0xFF643C70),
        title: Text('Контакты', style: TextStyle(fontFamily: 'RubikMonoOne')),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFAD03E2)))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _load, child: const Text('Повторить')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: GrooveLogo(height: 100),
                      ),
                      if (_data?.address != null && _data!.address!.isNotEmpty) ...[
                        SizedBox(height: 20),
                        _infoTile(Icons.location_on, 'Адрес', _data!.address!),
                      ],
                      if (_data?.phone != null && _data!.phone!.isNotEmpty) ...[
                        SizedBox(height: 12),
                        ListTile(
                          leading: Icon(Icons.phone, color: Color(0xFFFFCC32)),
                          title: Text('Телефон', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 12)),
                          subtitle: Text(_data!.phone!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16)),
                          onTap: () => _callPhone(_data!.phone!),
                        ),
                      ],
                      if (_data?.vkUrl != null && _data!.vkUrl!.isNotEmpty) ...[
                        SizedBox(height: 8),
                        ListTile(
                          leading: Icon(Icons.link, color: Color(0xFFAD03E2)),
                          title: Text('ВКонтакте', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 12)),
                          subtitle: Text(
                            _data!.vkUrl!,
                            style: const TextStyle(color: Color(0xFFC300FF), fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _openVk(_data!.vkUrl!),
                        ),
                      ],
                      if (_data != null && _data!.halls.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        Text(
                          'Залы',
                          style: GroovePageStyles.body(
                            context,
                            size: 18,
                            color: MainPurple,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._data!.halls.map(_hallCard),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFFFFCC32)),
      title: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 12)),
      subtitle: Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16)),
    );
  }

  String _hallTitle(OrganizationHallDto hall) {
    final name = hall.numberHall?.trim().isNotEmpty == true
        ? hall.numberHall!.trim()
        : 'Зал ${hall.idHall}';
    final params = hall.parameters?.trim() ?? '';
    if (params.isEmpty) return name;
    return '$name · $params';
  }

  Widget _hallCard(OrganizationHallDto hall) {
    final hasPhoto = hall.photoUrl != null && hall.photoUrl!.trim().isNotEmpty;
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasPhoto)
            ApiNetworkImage(
              imageUrl: hall.photoUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.contain,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              cacheKey: 'hall-photo-${hall.idHall}-${hall.photoUrl}',
              errorWidget: Container(
                height: 80,
                alignment: Alignment.center,
                child: Icon(Icons.broken_image, color: context.groove.carouselDotInactive),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _hallTitle(hall),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
