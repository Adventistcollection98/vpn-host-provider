import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/host_model.dart';
import '../services/github_service.dart';
import '../widgets/host_card.dart';
import '../widgets/search_bar.dart';

class HostProviderScreen extends StatefulWidget {
  const HostProviderScreen({super.key});

  @override
  State<HostProviderScreen> createState() => _HostProviderScreenState();
}

class _HostProviderScreenState extends State<HostProviderScreen> {
  List<Host> _allHosts = [];
  List<Host> _filteredHosts = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  // Filter options
  Map<String, int> _categoryCount = {};
  Map<String, int> _networkCount = {};
  String? _selectedCategory;
  String? _selectedNetwork;

  @override
  void initState() {
    super.initState();
    _fetchHostsFromGithub();
  }

  Future<void> _fetchHostsFromGithub() async {
    try {
      final hosts = await GitHubService.fetchHosts();
      setState(() {
        _allHosts = hosts;
        _filteredHosts = hosts;
        _isLoading = false;
        _errorMessage = null;
        _buildCategoryAndNetworkCounts();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _buildCategoryAndNetworkCounts() {
    _categoryCount.clear();
    _networkCount.clear();

    for (final host in _allHosts) {
      _categoryCount[host.category] = (_categoryCount[host.category] ?? 0) + 1;
      _networkCount[host.network] = (_networkCount[host.network] ?? 0) + 1;
    }
  }

  void _filterHosts() {
    setState(() {
      _filteredHosts = _allHosts.where((host) {
        // Search query filter
        final matchesSearch = _searchQuery.isEmpty ||
            host.domain.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            host.network.toLowerCase().contains(_searchQuery.toLowerCase());

        // Category filter
        final matchesCategory =
            _selectedCategory == null || host.category == _selectedCategory;

        // Network filter
        final matchesNetwork =
            _selectedNetwork == null || host.network == _selectedNetwork;

        return matchesSearch && matchesCategory && matchesNetwork;
      }).toList();
    });
  }

  void _copyToClipboard(Host host) {
    Clipboard.setData(ClipboardData(text: host.domain));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: ${host.domain}'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.greenAccent.withOpacity(0.8),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = null;
      _selectedNetwork = null;
      _filteredHosts = _allHosts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text(
          'Global VPN Host Provider',
          style: TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF161626),
        elevation: 0,
        actions: [
          if (_selectedCategory != null || _selectedNetwork != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear, color: Colors.cyanAccent),
                  label: const Text(
                    'Clear Filters',
                    style: TextStyle(color: Colors.cyanAccent),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            )
          : _errorMessage != null
              ? _buildErrorWidget()
              : Column(
                  children: [
                    // Search Bar
                    CustomSearchBar(
                      onChanged: (query) {
                        _searchQuery = query;
                        _filterHosts();
                      },
                      onClear: () {
                        _searchQuery = '';
                        _filterHosts();
                      },
                    ),

                    // Filter Chips
                    if (_categoryCount.isNotEmpty || _networkCount.isNotEmpty)
                      _buildFilterChips(),

                    // Result Count
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${_filteredHosts.length} of ${_allHosts.length} hosts',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Hosts List
                    Expanded(
                      child: _filteredHosts.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              itemCount: _filteredHosts.length,
                              itemBuilder: (context, index) {
                                final host = _filteredHosts[index];
                                return HostCard(
                                  host: host,
                                  onCopy: () => _copyToClipboard(host),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            // Category Filter
            if (_categoryCount.isNotEmpty)
              SizedBox(
                height: 40,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: _categoryCount.entries.map((entry) {
                    final isSelected = _selectedCategory == entry.key;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text('${entry.key} (${entry.value})'),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? entry.key : null;
                            _filterHosts();
                          });
                        },
                        backgroundColor: const Color(0xFF1E1E30),
                        selectedColor: Colors.cyanAccent.withOpacity(0.3),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.cyanAccent : Colors.white60,
                          fontSize: 11,
                        ),
                        side: BorderSide(
                          color: isSelected ? Colors.cyanAccent : Colors.white10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            // Network Filter
            if (_networkCount.isNotEmpty)
              SizedBox(
                height: 40,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: _networkCount.entries.map((entry) {
                    final isSelected = _selectedNetwork == entry.key;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text('${entry.key} (${entry.value})'),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedNetwork = selected ? entry.key : null;
                            _filterHosts();
                          });
                        },
                        backgroundColor: const Color(0xFF1E1E30),
                        selectedColor: Colors.greenAccent.withOpacity(0.3),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.greenAccent : Colors.white60,
                          fontSize: 11,
                        ),
                        side: BorderSide(
                          color: isSelected ? Colors.greenAccent : Colors.white10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          const Text(
            'No hosts found',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters or search query',
            style: TextStyle(
              color: Colors.white30,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to Load Hosts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              _errorMessage ?? 'An unknown error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchHostsFromGithub,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
