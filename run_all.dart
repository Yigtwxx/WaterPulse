// WATERPULSE/run_all.dart
import 'dart:io';

Future<void> main() async {
  print("🔥 Starting WaterPulse Backend...");

  // Backend'i arkada başlatıyoruz (FastAPI + Uvicorn)
  await Process.start(
    "powershell",
    ["-Command", "cd backend; .\\uvicorn_run.ps1"],
    mode: ProcessStartMode.detached,
  );

  print("✅ Backend started.");

  // Backend ayağa kalksın diye biraz beklet
  await Future.delayed(const Duration(seconds: 3));

  print("🚀 Starting WaterPulse Frontend (Flutter UI)...");

  // Flutter'ı NORMAL şekilde çalıştırıyoruz, UI ve loglar bu terminalde gözükecek
  final flutterProcess = await Process.start(
    "powershell",
    ["-Command", "cd frontend; flutter run -d windows"],
  );

  // Flutter loglarını bu terminale aynen yansıt (decode etmeye gerek yok)
  stdout.addStream(flutterProcess.stdout);
  stderr.addStream(flutterProcess.stderr);

  // Flutter süreci bitene kadar bekle (uygulama kapanınca çıkar)
  final exitCode = await flutterProcess.exitCode;
  print("\nFlutter process exited with code $exitCode");
  print("WaterPulse run_all.dart finished 💧");
}
