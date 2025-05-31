import 'package:flutter/material.dart';

Scaffold buildProfile(
    BuildContext ctx,
    String email,
    String name,
    String mqttMessage,
    VoidCallback scanQrAndSend,
    VoidCallback logout,
    ) =>
    Scaffold(
      appBar: AppBar(
        title: const Text('Профіль'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.indigo.shade500,
              Colors.purple.shade900,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 70,
                backgroundImage: NetworkImage(
                  'https://www.example.com/profile.jpg',
                ),
              ),
              const SizedBox(height: 24),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                mqttMessage,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: scanQrAndSend,
                icon: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 28,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                label: const Text(
                  'Сканувати QR-код',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: logout,
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 28,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                label: const Text(
                  'Вийти',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );

Scaffold loadingScreen() => const Scaffold(
  body: Center(child: CircularProgressIndicator()),
);

Scaffold errorScreen(String msg) => Scaffold(
  body: Center(child: Text('Сталася помилка: $msg')),
);

void showSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg)),
  );
}
