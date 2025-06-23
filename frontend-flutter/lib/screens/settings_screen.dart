import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _autoDownload = false;
  bool _notifications = true;
  bool _saveHistory = true;
  String _downloadQuality = '1080p';
  String _downloadFormat = 'MP4';
  String _downloadLocation = '/Descargas';
  String _language = 'Español';

  final List<String> _qualities = ['Auto', '4K', '1080p', '720p', '480p', '360p'];
  final List<String> _formats = ['MP4', 'MKV', 'WebM', 'MP3 (Audio)'];
  final List<String> _languages = ['Español', 'English', 'Português', 'Français'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Configuración'),
            floating: true,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.surface,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              children: [
                _buildSection(
                  'Apariencia',
                  [
                    SwitchListTile(
                      title: const Text('Modo Oscuro'),
                      subtitle: const Text('Cambiar entre tema claro y oscuro'),
                      secondary: const Icon(Icons.dark_mode),
                      value: _darkMode,
                      onChanged: (value) {
                        setState(() => _darkMode = value);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Idioma'),
                      subtitle: Text(_language),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showLanguageDialog(),
                    ),
                  ],
                ),
                _buildSection(
                  'Descargas',
                  [
                    ListTile(
                      leading: const Icon(Icons.high_quality),
                      title: const Text('Calidad por Defecto'),
                      subtitle: Text(_downloadQuality),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showQualityDialog(),
                    ),
                    ListTile(
                      leading: const Icon(Icons.video_file),
                      title: const Text('Formato por Defecto'),
                      subtitle: Text(_downloadFormat),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showFormatDialog(),
                    ),
                    ListTile(
                      leading: const Icon(Icons.folder),
                      title: const Text('Ubicación de Descargas'),
                      subtitle: Text(_downloadLocation),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // TODO: Implementar selector de carpeta
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Descarga Automática'),
                      subtitle: const Text('Iniciar descarga al pegar un enlace'),
                      secondary: const Icon(Icons.download),
                      value: _autoDownload,
                      onChanged: (value) {
                        setState(() => _autoDownload = value);
                      },
                    ),
                  ],
                ),
                _buildSection(
                  'Notificaciones',
                  [
                    SwitchListTile(
                      title: const Text('Notificaciones'),
                      subtitle: const Text('Recibir alertas de descargas'),
                      secondary: const Icon(Icons.notifications),
                      value: _notifications,
                      onChanged: (value) {
                        setState(() => _notifications = value);
                      },
                    ),
                  ],
                ),
                _buildSection(
                  'Privacidad',
                  [
                    SwitchListTile(
                      title: const Text('Guardar Historial'),
                      subtitle: const Text('Mantener registro de descargas'),
                      secondary: const Icon(Icons.history),
                      value: _saveHistory,
                      onChanged: (value) {
                        setState(() => _saveHistory = value);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Limpiar Datos'),
                      subtitle: const Text('Eliminar historial y caché'),
                      onTap: () => _showClearDataDialog(),
                    ),
                  ],
                ),
                _buildSection(
                  'Acerca de',
                  [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Versión'),
                      subtitle: const Text('1.0.0'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.update),
                      title: const Text('Buscar Actualizaciones'),
                      onTap: () {
                        // TODO: Implementar búsqueda de actualizaciones
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: const Text('Ayuda'),
                      onTap: () {
                        // TODO: Implementar sección de ayuda
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showQualityDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Calidad por Defecto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _qualities.map((quality) {
              return RadioListTile(
                title: Text(quality),
                value: quality,
                groupValue: _downloadQuality,
                onChanged: (value) {
                  setState(() => _downloadQuality = value.toString());
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showFormatDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Formato por Defecto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _formats.map((format) {
              return RadioListTile(
                title: Text(format),
                value: format,
                groupValue: _downloadFormat,
                onChanged: (value) {
                  setState(() => _downloadFormat = value.toString());
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Idioma'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _languages.map((language) {
              return RadioListTile(
                title: Text(language),
                value: language,
                groupValue: _language,
                onChanged: (value) {
                  setState(() => _language = value.toString());
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Limpiar Datos'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar todo el historial y la caché? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                // TODO: Implementar limpieza de datos
                Navigator.pop(context);
              },
              child: const Text('Limpiar'),
            ),
          ],
        );
      },
    );
  }
}
