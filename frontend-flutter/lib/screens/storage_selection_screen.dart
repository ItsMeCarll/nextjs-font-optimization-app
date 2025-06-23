import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/storage_path_service.dart';
import '../core/services/app_service.dart';

class StorageSelectionScreen extends StatefulWidget {
  const StorageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<StorageSelectionScreen> createState() => _StorageSelectionScreenState();
}

class _StorageSelectionScreenState extends State<StorageSelectionScreen> {
  List<StorageInfo> _storagePaths = [];
  bool _isLoading = true;
  String? _selectedPath;

  @override
  void initState() {
    super.initState();
    _loadStoragePaths();
  }

  Future<void> _loadStoragePaths() async {
    final storageService = Provider.of<AppService>(context, listen: false)
        .storagePathService;
    
    setState(() => _isLoading = true);
    
    try {
      final paths = await storageService.getAvailableStoragePaths();
      setState(() {
        _storagePaths = paths;
        _selectedPath = Provider.of<AppService>(context, listen: false)
            .settings
            .downloadLocation;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación de Almacenamiento'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Selecciona dónde guardar tus descargas:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._storagePaths.map((storage) => _buildStorageCard(storage)),
                      const SizedBox(height: 24),
                      const Text(
                        'Las descargas se organizarán automáticamente en:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFolderStructureCard(),
                    ],
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildStorageCard(StorageInfo storage) {
    final isSelected = _selectedPath == storage.path;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedPath = storage.path),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    storage.isSDCard
                        ? Icons.sd_card
                        : Icons.phone_android,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storage.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          storage.path,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (storage.totalSpace - storage.freeSpace) /
                    storage.totalSpace,
                backgroundColor: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                'Espacio libre: ${_formatBytes(storage.freeSpace)} / ${_formatBytes(storage.totalSpace)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFolderStructureCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFolderItem(
              icon: Icons.folder,
              name: 'App Video',
              description: 'Videos descargados',
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildFolderItem(
              icon: Icons.folder,
              name: 'App Music',
              description: 'Música y audio',
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderItem({
    required IconData icon,
    required String name,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: _selectedPath == null
                  ? null
                  : () async {
                      final appService =
                          Provider.of<AppService>(context, listen: false);
                      await appService.settings
                          .setDownloadLocation(_selectedPath!);
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
              child: const Text('Guardar Ubicación'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }
}
