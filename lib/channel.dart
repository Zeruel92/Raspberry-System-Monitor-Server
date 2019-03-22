import 'raspberry_system_monitor_server.dart';

class RaspberrySystemMonitorServerChannel extends ApplicationChannel {
  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @override
  Controller get entryPoint {
    final router = Router();
    router.route("/uptime").linkFunction(_uptime);
    router.route("/poweroff").linkFunction(_powerOff);
    router.route("/reboot").linkFunction(_reboot);
    router.route("/torrentstatus").linkFunction(_statusTorrent);
    return router;
  }

  Response _uptime(Request req) {
    ProcessResult result;
    result = Process.runSync('bash', ['-c', 'uptime'],
        includeParentEnvironment: true, runInShell: true);
    String uptime = result.stdout.toString();
    final RegExp exp = RegExp('up (.*?)[0-9] user');
    final Match ab = exp.firstMatch(uptime);
    uptime = uptime.substring(ab.start + 3, ab.end - 9);
    result = Process.runSync('bash', ['-c', 'cut -d \' \' -f1 /proc/loadavg'],
        includeParentEnvironment: true, runInShell: true);
    final double loadAvg = double.parse(result.stdout.toString());
    result = Process.runSync('bash', ['-c', 'cut -d \' \' -f2 /proc/loadavg'],
        includeParentEnvironment: true, runInShell: true);
    final double loadAvg5 = double.parse(result.stdout.toString());
    result = Process.runSync('bash', ['-c', 'cut -d \' \' -f3 /proc/loadavg'],
        includeParentEnvironment: true, runInShell: true);
    final double loadAvg15 = double.parse(result.stdout.toString());
    final Map<String, dynamic> headers = {};
    headers["content-type"] = "application/json";
    final Map<String, dynamic> body = {};
    body['loadAvg'] = loadAvg;
    body['time'] = uptime;
    body['loadAvg5'] = loadAvg5;
    body['loadAvg15'] = loadAvg15;
    print(body);
    return Response.ok(body, headers: headers);
  }

  Response _powerOff(Request req) {
    ProcessResult result;
    result = Process.runSync('bash', ['-c', '/home/pi/wrapper.sh shutdown'],
        includeParentEnvironment: true, runInShell: true);
    return Response.ok('Shutdown in 1 minute');
  }

  Response _reboot(Request req) {
    ProcessResult result;
    result = Process.runSync('bash', ['-c', '/home/pi/wrapper.sh reboot'],
        includeParentEnvironment: true, runInShell: true);
    return Response.ok('Reboot in 1 minute');
  }

  Response _statusTorrent(Request req) {
    final ProcessResult result = Process.runSync(
        'bash', ['-c', 'transmission-remote -l'],
        includeParentEnvironment: true, runInShell: true);
    final Map body = {};
    body['torrentStatus'] = result.stdout.toString();
    if (result.stdout.toString().contains('ETA')) {
      body['running'] = true;
    } else {
      body['running'] = false;
    }
    final Map<String, dynamic> headers = {};
    headers["content-type"] = "application/json";
    return Response.ok(body, headers: headers);
  }
}
