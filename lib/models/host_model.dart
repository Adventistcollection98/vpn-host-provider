class Host {
  final String domain;
  final String category;
  final String network;
  final String status;

  Host({
    required this.domain,
    required this.category,
    required this.network,
    required this.status,
  });

  /// Factory constructor to create a Host from JSON
  factory Host.fromJson(Map<String, dynamic> json) {
    return Host(
      domain: json['domain'] ?? 'Unknown',
      category: json['category'] ?? 'Uncategorized',
      network: json['network'] ?? 'Unknown',
      status: json['status'] ?? 'Unknown',
    );
  }

  /// Convert Host to JSON
  Map<String, dynamic> toJson() {
    return {
      'domain': domain,
      'category': category,
      'network': network,
      'status': status,
    };
  }

  /// Get display color for status
  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.greenAccent;
      case 'maintenance':
        return Colors.amberAccent;
      case 'inactive':
        return Colors.redAccent;
      default:
        return Colors.white60;
    }
  }

  /// Get background color for status badge
  Color getStatusBgColor() {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green.withOpacity(0.2);
      case 'maintenance':
        return Colors.amber.withOpacity(0.2);
      case 'inactive':
        return Colors.red.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }
}
