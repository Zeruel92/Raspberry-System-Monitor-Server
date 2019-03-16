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
    return router;
  }

  Response _uptime(Request req) {
    ProcessResult result;
    result = Process.runSync('bash', ['-c', 'uptime'],
        includeParentEnvironment: true, runInShell: true);
    String uptime = result.stdout.toString();
    RegExp exp = RegExp('up (.*?)[0-9],');
    Match ab = exp.firstMatch(uptime);
    uptime = uptime.substring(ab.start + 3, ab.end - 1);
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
}
