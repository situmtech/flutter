part of '../wayfinding.dart';

Widget _buildRetryScreen(Function onErrorRetryLoad) {
  return Container(
    color: const Color(0xff313131),
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 32.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.wifi_off,
          size: 100,
          color: Colors.white,
        ),
        const SizedBox(height: 24),
        const Text(
          "You're offline",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          "If the data has already been downloaded, you can still access the map.",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          "If not, please enable your Internet connection and try again.",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh, color: Colors.black),
          label: const Text(
            'RETRY',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () {
            onErrorRetryLoad.call();
          },
        ),
      ],
    ),
  );
}
