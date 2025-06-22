import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  final List<Map<String, String>> _downloads = [];

  void _downloadVideo() {
    if (_urlController.text.isEmpty) return;
    
    setState(() {
      _downloads.insert(0, {
        'title': 'Video ${_downloads.length + 1}',
        'url': _urlController.text,
        'status': 'Downloading...'
      });
    });
    
    _urlController.clear();
    // TODO: Implement actual download logic
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: 'Pega el enlace del video aquí',
              prefixIcon: const Icon(Icons.link),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _downloadVideo,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Descargar', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Descargas Recientes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _downloads.isEmpty
                ? const Center(
                    child: Text('No hay descargas recientes'),
                  )
                : ListView.builder(
                    itemCount: _downloads.length,
                    itemBuilder: (context, index) {
                      final download = _downloads[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.video_library),
                          title: Text(download['title']!),
                          subtitle: Text('Estado: ${download['status']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _downloads.removeAt(index);
                              });
                            },
                          ),
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
