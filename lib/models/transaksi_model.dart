class Transaction {
  final String id;
  final String judul;
  final String jenis;
  final int jumlah;
  final String tanggal;
  final String deskripsi;

  Transaction({
    required this.id,
    required this.judul,
    required this.jenis,
    required this.jumlah,
    required this.tanggal,
    required this.deskripsi,
  });

  factory Transaction.fromMap(String key, Map<dynamic, dynamic> map) {
    return Transaction(
      id: key,
      judul: map['judul'] as String? ?? 'Tanpa Judul',
      jenis: map['jenis'] as String? ?? 'Pengeluaran',
      jumlah: (map['jumlah'] as num? ?? 0).toInt(),
      tanggal: map['tanggal'] as String? ?? '',
      deskripsi: map['deskripsi'] as String? ?? '',
    );
  }
}