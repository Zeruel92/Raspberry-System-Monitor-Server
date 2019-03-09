import 'package:raspberry_system_monitor_server/raspberry_system_monitor_server.dart';
import 'dart:convert';

Future main() async {
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
      //print('Broadcasted');
    });
  });

  print("Application started on port: ${app.options.port}.");
  print("Use Ctrl-C (SIGINT) to stop running the application.");
}
