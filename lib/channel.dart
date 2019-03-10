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
    return Response.ok(result.stdout);
  }
}
