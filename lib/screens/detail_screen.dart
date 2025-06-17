import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaksi_model.dart';

class DetailScreen extends StatelessWidget {
  final Transaction transaction;

  const DetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Judul:', transaction.judul),
                _buildDetailRow('Jenis:', transaction.jenis),
                _buildDetailRow('Tanggal:', transaction.tanggal),
                _buildDetailRow('Jumlah:', currencyFormatter.format(transaction.jumlah)),
                _buildDetailRow('Deskripsi:', transaction.deskripsi.isNotEmpty ? transaction.deskripsi : '-'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          if (label != 'Deskripsi:') const Divider(thickness: 0.5),
        ],
      ),
    );
  }
}