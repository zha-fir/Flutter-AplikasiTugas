import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Note: Implementasi toggle theme butuh state management di level atas (Main)
    // Untuk sekarang hanya UI-nya saja.

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan ⚙️')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text("Tema Gelap"),
            subtitle: const Text("Ikuti pengaturan sistem"),
            trailing: Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (val) {
                // TODO: Implementasi perubahan tema dinamis
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Fitur ganti tema belum aktif di main.dart"),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("Tentang Aplikasi"),
            subtitle: const Text("Versi 1.0.0"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Aplikasi Tugasku",
                applicationVersion: "1.0.0",
                applicationLegalese: "Dibuat dengan ❤️ oleh Zhafir",
              );
            },
          ),
        ],
      ),
    );
  }
}
