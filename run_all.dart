// WATERPULSE/run_all.dart
import 'dart:io';

Future<void> main() async {
  print("🔥 Starting WaterPulse Backend...");

  await Process.start(
    "powershell",
    ["-Command", "cd backend; .\\uvicorn_run.ps1"],
    mode: ProcessStartMode.detached,
  );

  print("✅ Backend started.");

  // Backend ayağa kalksın diye biraz bekletiyoruz
  await Future.delayed(const Duration(seconds: 3));

  print("🚀 Starting WaterPulse Frontend...");

  await Process.start(
    "powershell",
    ["-Command", "cd frontend; flutter run"],
    mode: ProcessStartMode.detached,
  );

  print("✅ Frontend launched.");
  print("\nWaterPulse is now running! 💧");
}
