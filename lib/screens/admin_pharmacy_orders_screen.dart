import 'package:flutter/material.dart';

class AdminPharmacyOrdersScreen extends StatelessWidget {
  const AdminPharmacyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Page title ────────────────────────────────────────────────
            const Text(
              'Pharmacy Order Details',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 28),

            // ── Stat cards row ──────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _buildTopStatCard(
                    title: 'Pharmacy Orders',
                    count: '668',
                    icon: Icons.local_pharmacy_rounded,
                    iconBg: const Color(0xFF48BB78),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildTopStatCard(
                    title: 'Pharmacy Pending Orders',
                    count: '231',
                    icon: Icons.pending_actions_rounded,
                    iconBg: const Color(0xFF2B6CB0),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildTopStatCard(
                    title: 'Pharmacy Cancelled Orders',
                    count: '12',
                    icon: Icons.cancel_outlined,
                    iconBg: const Color(0xFFE53E3E),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Columns row ──────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column 1: Pharmacy Orders (Delivered)
                Expanded(
                  child: _buildStatusColumn(
                    title: 'Pharmacy Orders',
                    bgColor: const Color(0xFF1CB0F6),
                    itemCount: 2,
                    status: 'Delievered',
                    statusColor: const Color(0xFF48BB78),
                  ),
                ),
                const SizedBox(width: 24),
                // Column 2: Pharmacy Pending Orders
                Expanded(
                  child: _buildStatusColumn(
                    title: 'Pharmacy Pending Orders',
                    bgColor: const Color(0xFF0B2D6E),
                    itemCount: 2,
                    status: 'Pending',
                    statusColor: const Color(0xFF3182CE),
                  ),
                ),
                const SizedBox(width: 24),
                // Column 3: Pharmacy Orders (Cancelled)
                Expanded(
                  child: _buildStatusColumn(
                    title: 'Pharmacy Cancelled Order',
                    bgColor: const Color(0xFF1CB0F6),
                    itemCount: 2,
                    status: 'Cancelled',
                    statusColor: const Color(0xFFE53E3E),
                    showReason: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF718096),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusColumn({
    required String title,
    required Color bgColor,
    required int itemCount,
    required String status,
    required Color statusColor,
    bool showReason = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          // Vertical list of cards
          ...List.generate(itemCount, (index) => _buildOrderCard(
            status: status,
            statusColor: statusColor,
            showReason: showReason,
          )),
        ],
      ),
    );
  }

  Widget _buildOrderCard({
    required String status,
    required Color statusColor,
    bool showReason = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quantum Spar Lab',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Products',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF718096),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildProductIcon(Icons.medication_rounded),
              const SizedBox(width: 6),
              _buildProductIcon(Icons.medical_services_rounded),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Name', 'Sadia'),
          _buildDetailRow('Patient Name', 'Sadia'),
          _buildDetailRow('', 'Shahrah - e\nfaisal near KFC\nStreet 1'),
          _buildDetailRow('Age', '32'),
          _buildDetailRow('Date', '21 June 2025'),
          _buildDetailRow('Time', '12:PM'),
          _buildDetailRow('Phone Number', '03098949375'),
          _buildDetailRow('Amount', '6000'),
          const SizedBox(height: 16),
          if (showReason) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'See the reason',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFFE53E3E),
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4A5568),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductIcon(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Icon(icon, color: const Color(0xFF3182CE), size: 16),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF4A5568),
                fontWeight: FontWeight.w500,
              ),
            ),
          const Spacer(),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF2D3748),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
