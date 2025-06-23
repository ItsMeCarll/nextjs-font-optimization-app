import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedPlatform = 'Todos';
  String _selectedCategory = 'Todo';
  bool _isSearching = false;
  final List<Map<String, dynamic>> _searchResults = [];

  final List<String> _platforms = [
    'Todos',
    'YouTube',
    'Facebook',
    'Instagram',
    'TikTok',
  ];

  final List<String> _categories = [
    'Todo',
    'Música',
    'Gaming',
    'Educación',
    'Entretenimiento',
  ];

  @override
  void initState() {
    super.initState();
    // Simular resultados de búsqueda
    _searchResults.addAll([
      {
        'title': 'Tutorial de Flutter',
        'channel': 'Dev Channel',
        'views': '1.2M vistas',
        'duration': '15:30',
        'thumbnail': 'https://example.com/thumb1.jpg',
      },
      {
        'title': 'Lo mejor de 2024',
        'channel': 'Music Channel',
        'views': '850K vistas',
        'duration': '8:45',
        'thumbnail': 'https://example.com/thumb2.jpg',
      },
    ]);
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;
    setState(() {
      _isSearching = true;
    });

    // Simular búsqueda
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Buscar'),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Barra de búsqueda
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar videos...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                        ),
                        onSubmitted: _performSearch,
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Filtros
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'Plataforma: $_selectedPlatform',
                          icon: Icons.apps,
                          onTap: () => _showPlatformPicker(),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Categoría: $_selectedCategory',
                          icon: Icons.category,
                          onTap: () => _showCategoryPicker(),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Filtros',
                          icon: Icons.tune,
                          onTap: () => _showFiltersDialog(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Resultados de búsqueda
          if (_isSearching)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_searchResults.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Busca videos de tus plataformas favoritas',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final result = _searchResults[index];
                  return _buildSearchResultCard(result);
                },
                childCount: _searchResults.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }

  Widget _buildSearchResultCard(Map<String, dynamic> result) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Implementar acción al seleccionar video
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    result['duration'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result['channel'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result['views'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlatformPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: _platforms.length,
          itemBuilder: (context, index) {
            final platform = _platforms[index];
            return ListTile(
              title: Text(platform),
              trailing: _selectedPlatform == platform
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  _selectedPlatform = platform;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return ListTile(
              title: Text(category),
              trailing: _selectedCategory == category
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtros Avanzados'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.hd),
                title: const Text('Calidad'),
                subtitle: const Text('Todas'),
                onTap: () {
                  // TODO: Implementar selección de calidad
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('Duración'),
                subtitle: const Text('Cualquiera'),
                onTap: () {
                  // TODO: Implementar selección de duración
                },
              ),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Fecha'),
                subtitle: const Text('Cualquier fecha'),
                onTap: () {
                  // TODO: Implementar selección de fecha
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            FilledButton(
              onPressed: () {
                // TODO: Aplicar filtros
                Navigator.pop(context);
              },
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }
}
