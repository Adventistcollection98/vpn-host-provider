import 'package:flutter/material.dart';
import '../models/host_model.dart';

class HostCard extends StatelessWidget {
  final Host host;
  final VoidCallback onCopy;

  const HostCard({
    super.key,
    required this.host,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E30),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          host.domain,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              host.category,
              style: const TextStyle(
                color: Colors.cyanAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              host.network,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: host.getStatusBgColor(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            host.status,
            style: TextStyle(
              color: host.getStatusColor(),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onLongPress: onCopy,
      ),
    );
  }
}
