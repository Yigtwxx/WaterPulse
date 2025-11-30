// WATERPULSE/run_all.dart
import 'dart:io';

Future<void> main() async {
  print("🔥 Starting WaterPulse Backend...");

  final backend = await _startBackend();
  Process? frontend;
  Process? flutterProcess;

  try {
    await _waitForBackendReady();
    print("✅ Backend started (logs: backend/.dev_backend.log).");
  } catch (e) {
    stderr.writeln("❌ Backend did not start: $e");
    await backend.stop();
    exitCode = 1;
    return;
  }

  // Ctrl+C -> hepsini kapat
  ProcessSignal.sigint.watch().listen((_) async {
    print("\n🛑 Stopping...");
    await _stopProcess(frontend);
    await backend.stop();
    exit(0);
  });

  print("🚀 Starting WaterPulse Frontend (Flutter UI)...");

  try {
    flutterProcess = await _startFrontend();
    frontend = flutterProcess;
  } catch (e) {
    stderr.writeln("❌ Frontend could not start: $e");
    await backend.stop();
    exitCode = 1;
    return;
  }

  final flutterExitCode = await flutterProcess.exitCode;
  print("\nFlutter process exited with code $flutterExitCode");
  print("WaterPulse run_all.dart finished 💧");

  await backend.stop();
}

Future<_ManagedProcess> _startBackend() async {
  final root = Directory.current.path;
  final pythonExec = _resolvePythonExecutable(root);

  final process = await Process.start(
    pythonExec,
    [
      "-m",
      "uvicorn",
      "app.main:app",
      "--host",
      "127.0.0.1",
      "--port",
      "8000",
      "--log-level",
      "warning",
    ],
    workingDirectory: "backend",
  );

  // Backend loglarını terminale basmayıp dosyaya yaz
  final logFile = File("backend/.dev_backend.log");
  final sink = logFile.openWrite(mode: FileMode.writeOnlyAppend);
  process.stdout.listen(sink.add);
  process.stderr.listen(sink.add);

  return _ManagedProcess(process, sink);
}

Future<void> _waitForBackendReady({
  Duration timeout = const Duration(seconds: 15),
}) async {
  final client = HttpClient();
  final deadline = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(deadline)) {
    try {
      final request =
          await client.getUrl(Uri.parse("http://127.0.0.1:8000/"));
      final response = await request.close();
      await response.drain();

      if (response.statusCode < 500) {
        client.close();
        return;
      }
    } catch (_) {
      // retry
    }

    await Future.delayed(const Duration(seconds: 1));
  }

  client.close();
  throw Exception("backend did not respond on http://127.0.0.1:8000/");
}

String _resolvePythonExecutable(String root) {
  final windowsPath = "$root\\.venv\\Scripts\\python.exe";
  final posixPath = "$root/.venv/bin/python";

  if (File(windowsPath).existsSync()) return windowsPath;
  if (File(posixPath).existsSync()) return posixPath;

  return "python";
}

Future<Process> _startFrontend() async {
  final flutterExec = _resolveFlutterExecutable();
  final process = await Process.start(
    flutterExec,
    ["run", "-d", "windows"],
    workingDirectory: "frontend",
  );
  _pipeProcess(process);
  return process;
}

String _resolveFlutterExecutable() {
  final env = Platform.environment;
  final candidates = <String>[
    if (env["FLUTTER_BIN"] != null) env["FLUTTER_BIN"]!,
    if (env["FLUTTER_HOME"] != null)
      "${env["FLUTTER_HOME"]!}\\bin\\flutter.bat",
    if (env["FLUTTER_ROOT"] != null)
      "${env["FLUTTER_ROOT"]!}\\bin\\flutter.bat",
    "C:\\\\src\\\\flutter\\\\bin\\\\flutter.bat",
    "flutter", // fallback to PATH
  ];

  for (final path in candidates) {
    if (path.isEmpty) continue;
    // If it's an absolute path, check it exists
    if (path.contains("\\") || path.contains("/")) {
      if (File(path).existsSync()) return path;
    } else {
      // rely on PATH resolution
      return path;
    }
  }
  return "flutter";
}

void _pipeProcess(Process process) {
  process.stdout.listen(stdout.add);
  process.stderr.listen(stderr.add);
}

Future<void> _stopProcess(Process? process) async {
  if (process == null) return;
  process.kill(ProcessSignal.sigint);
  await process.exitCode.timeout(
    const Duration(seconds: 2),
    onTimeout: () async {
      process.kill();
      return await process.exitCode;
    },
  );
}

class _ManagedProcess {
  final Process process;
  final IOSink? sink;
  bool _stopping = false;

  _ManagedProcess(this.process, this.sink);

  Future<void> stop() async {
    if (_stopping) return;
    _stopping = true;

    // Graceful, then force if needed
    process.kill(ProcessSignal.sigint);
    await process.exitCode.timeout(
      const Duration(seconds: 2),
      onTimeout: () async {
        process.kill();
        return await process.exitCode;
      },
    );

    await sink?.close();
  }
}
