import 'dart:convert';
import 'package:raspberry_system_monitor_server/raspberry_system_monitor_server.dart';

Future main() async {
  await _update();

  final app = Application<RaspberrySystemMonitorServerChannel>()
    ..options.configurationFilePath = "config.yaml"
    ..options.port = 8888;

  final count = Platform.numberOfProcessors ~/ 2;
  await app.start(numberOfInstances: count > 0 ? count : 1);

  await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8889)
      .then((RawDatagramSocket udpSocket) {
    udpSocket.broadcastEnabled = true;
    final List<int> data = utf8.encode('rpi_broadcast_message');
    Timer.periodic(Duration(seconds: 10), (_) {
      udpSocket.send(data, InternetAddress('192.168.1.255'), 8889);
    });
  });
  startTimer();
  print("Application started on port: ${app.options.port}.");
  print("Use Ctrl-C (SIGINT) to stop running the application.");
}

Timer startTimer() {
  final Duration duration = Duration(minutes: 10);
  return Timer.periodic(duration, timerCallback);
}

void timerCallback(Timer t) {
  exit(0);
}

Future<void> _update() async {
  return Process.run('bash', ['-c', 'git pull'],
          includeParentEnvironment: true, runInShell: true)
      .then((result) {
    if (!result.stdout.toString().contains('Already')) {
      print(result.stdout.toString());
      exit(0);
    }
  });
}
