import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/transaksi_model.dart';
import 'tambah_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // GANTI DENGAN URL DATABASE ANDA
  final String _databaseUrl =
      'https://transaksi-caea6-default-rtdb.firebaseio.com/transaksi.json';

  late Future<List<Transaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _fetchTransactions();
  }

  Future<List<Transaction>> _fetchTransactions() async {
    try {
      final response = await http.get(Uri.parse(_databaseUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);
        if (data == null) return [];
        final List<Transaction> loadedTransactions = [];
        data.forEach((key, value) {
          loadedTransactions.add(Transaction.fromMap(key, value as Map));
        });
        loadedTransactions.sort((a, b) => b.id.compareTo(a.id));
        return loadedTransactions;
      } else {
        throw Exception('Gagal memuat data dari server.');
      }
    } catch (error) {
      throw Exception('Terjadi kesalahan: $error');
    }
  }

  void _refreshData() {
    setState(() {
      _transactionsFuture = _fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Keuangan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: FutureBuilder<List<Transaction>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tekan '+' untuk menambah data."));
          }

          final transactions = snapshot.data!;
          double totalSaldo = 0;
          for (var trans in transactions) {
            if (trans.jenis == 'Pemasukan') {
              totalSaldo += trans.jumlah;
            } else {
              totalSaldo -= trans.jumlah;
            }
          }
          final formatCurrency = NumberFormat.currency(
              locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Text("Total Saldo", style: TextStyle(fontSize: 18, color: Colors.grey)),
                        const SizedBox(height: 10),
                        Text(
                          formatCurrency.format(totalSaldo),
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final isPemasukan = transaction.jenis == 'Pemasukan';
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      child: ListTile(
                        leading: Icon(
                          isPemasukan ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isPemasukan ? Colors.green : Colors.red,
                        ),
                        title: Text(transaction.judul),
                        subtitle: Text(transaction.tanggal),
                        trailing: Text(
                          formatCurrency.format(transaction.jumlah),
                          style: TextStyle(
                            color: isPemasukan ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(transaction: transaction),
                            ),
                          );
                        },
      
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bool? result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const AddScreen()),
          );
          if (result == true) {
            _refreshData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}