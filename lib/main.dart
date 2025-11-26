import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UAS To-Do List',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2575FC),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto', // Font bawaan yang bersih
      ),
      home: const TodoListScreen(),
    );
  }
}

// --- SYARAT UTAMA: SATU STATEFUL WIDGET ---
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  // --- 1. VARIABEL DATA (Private & List<String>) ---
  // Format Data: "Judul|||Deskripsi"
  final List<String> _tugasRizzaldy = [
    'Menyelesaikan Modul Flutter|||Bab 1-5 Wajib Kelar',
    'Mengerjakan Laporan KP|||Revisi bagian kesimpulan',
    'Beli Kopi|||Es Kopi Gula Aren',
  ];

  final List<String> _riwayatRizzaldy = [];
  
  // Kontroller Input
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  // State untuk Navigasi Bawah (0 = Home, 1 = History)
  int _selectedIndex = 0; 

  // --- 2. FUNGSI LOGIKA ---

  void _tambahTugas() {
    if (_judulController.text.isNotEmpty) {
      String fullData = "${_judulController.text}|||${_deskripsiController.text}";
      setState(() {
        _tugasRizzaldy.insert(0, fullData);
      });
      _judulController.clear();
      _deskripsiController.clear();
      Navigator.of(context).pop(); // Tutup Dialog
    }
  }

  // Geser Kanan (Selesai)
  void _aksiSelesai(int index) {
    String data = _tugasRizzaldy[index];
    setState(() {
      _tugasRizzaldy.removeAt(index);
      _riwayatRizzaldy.insert(0, data);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tugas Selesai! Masuk History ✅"), backgroundColor: Colors.green),
    );
  }

  // Geser Kiri (Hapus)
  void _aksiHapus(int index) {
    String data = _tugasRizzaldy[index];
    setState(() {
      _tugasRizzaldy.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Tugas Dihapus 🗑️"),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => setState(() => _tugasRizzaldy.insert(index, data)),
        ),
      ),
    );
  }

  // Hapus Permanen (Di History)
  void _hapusPermanen(int index) {
    setState(() {
      _riwayatRizzaldy.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Dihapus permanen."), duration: Duration(seconds: 1)),
    );
  }

  // --- 3. KOMPONEN UI (Method, bukan Class terpisah biar aman) ---

  // Tampilan Dialog Input
  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("✨ Tugas Baru", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: _judulController,
                decoration: InputDecoration(
                  hintText: "Judul Tugas",
                  filled: true, fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _deskripsiController,
                decoration: InputDecoration(
                  hintText: "Catatan (Opsional)",
                  filled: true, fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _tambahTugas,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2575FC),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("SIMPAN"),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Tampilan Modal Detail
  void _showDetailModal(String rawData) {
    List<String> parts = rawData.split('|||');
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(30),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(parts[0], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
              child: Text(parts.length > 1 && parts[1].isNotEmpty ? parts[1] : "Tidak ada catatan.", style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Builder untuk List Utama
  Widget _buildActiveList() {
    if (_tugasRizzaldy.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rocket_launch, size: 80, color: Colors.black12),
            SizedBox(height: 10),
            Text("Semua beres! Santai dulu.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tugasRizzaldy.length,
      itemBuilder: (ctx, index) {
        String raw = _tugasRizzaldy[index];
        return Dismissible(
          key: Key(raw + index.toString()),
          background: Container(
            color: Colors.green, 
            alignment: Alignment.centerLeft, 
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(Icons.check, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.red, 
            alignment: Alignment.centerRight, 
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (dir) => dir == DismissDirection.startToEnd ? _aksiSelesai(index) : _aksiHapus(index),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              onTap: () => _showDetailModal(raw),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.work_outline, color: Color(0xFF2575FC)),
              ),
              title: Text(raw.split('|||')[0], style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.info_outline, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  // Widget Builder untuk History
  Widget _buildHistoryList() {
    if (_riwayatRizzaldy.isEmpty) {
      return const Center(child: Text("Belum ada sejarah...", style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _riwayatRizzaldy.length,
      itemBuilder: (ctx, index) {
        String raw = _riwayatRizzaldy[index];
        return Card(
          color: Colors.grey[50],
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey[200]!)),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(
              raw.split('|||')[0],
              style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
              onPressed: () => _hapusPermanen(index),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      // Header Gradasi
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_selectedIndex == 0 ? 'Daily Focus' : 'Hall of Fame', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const Text('Rizz-aldy Workspace', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
          ),
        ),
      ),
      
      // Body Berubah Sesuai Tab yang Dipilih
      body: _selectedIndex == 0 ? _buildActiveList() : _buildHistoryList(),

      // Tombol Tambah (Hanya muncul di tab Home)
      floatingActionButton: _selectedIndex == 0 
        ? FloatingActionButton(
            onPressed: _showInputDialog,
            backgroundColor: const Color(0xFF2575FC),
            child: const Icon(Icons.add, color: Colors.white),
          )
        : null,
      
      // Bottom Navigation (Ganti Tab)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (val) => setState(() => _selectedIndex = val),
        selectedItemColor: const Color(0xFF2575FC),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Tugas"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
        ],
      ),
    );
  }
}