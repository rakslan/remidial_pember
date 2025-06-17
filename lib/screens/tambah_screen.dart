import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _deskripsiController = TextEditingController();
  String? _selectedType = 'Pengeluaran';
  final List<String> _transactionTypes = ['Pengeluaran', 'Pemasukan'];
  bool _isLoading = false;

  // GANTI DENGAN URL DATABASE ANDA
  final String _databaseUrl =
      'https://transaksi-caea6-default-rtdb.firebaseio.com/transaksi.json';

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final newTransaction = {
        'judul': _judulController.text,
        'jenis': _selectedType,
        'jumlah': int.parse(_jumlahController.text),
        'deskripsi': _deskripsiController.text,
        // Format tanggal sesuai standar yang kita sepakati
        'tanggal': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      };

      try {
        final response = await http.post(
          Uri.parse(_databaseUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(newTransaction),
        );

        if (mounted) {
          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaksi berhasil disimpan!')),
            );
            Navigator.pop(context, true); // Kirim 'true' untuk refresh
          } else {
            throw Exception('Gagal menyimpan. Status: ${response.statusCode}');
          }
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi error: $error')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Data")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Jenis'),
                items: _transactionTypes.map((String value) =>
                    DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                onChanged: (newValue) => setState(() => _selectedType = newValue),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jumlahController,
                decoration: const InputDecoration(labelText: 'Jumlah'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Jumlah tidak boleh kosong';
                  if (int.tryParse(value) == null) return 'Masukkan angka yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveTransaction,
                      child: const Text('Simpan'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}