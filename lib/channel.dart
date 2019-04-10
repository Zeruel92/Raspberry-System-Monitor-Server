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
    router.route("/torrentstatus/:toggle").linkFunction(_statusTorrent);
    router.route("/teledart/:toggle").linkFunction(_teledart);
    router.route("/smb/:toggle").linkFunction(_smb);
    router.route("/ssh/:toggle").linkFunction(_ssh);
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
    result = Process.runSync(
        'bash', ['-c', '/opt/vc/bin/vcgencmd measure_temp'],
        includeParentEnvironment: true, runInShell: true);
    final double temp = double.parse(result.stdout.toString().substring(
        result.stdout.toString().indexOf('=') + 1,
        result.stdout.toString().length - 3));
    final Map<String, dynamic> headers = {};
    headers["content-type"] = "application/json";
    final Map<String, dynamic> body = {};
    body['loadAvg'] = loadAvg;
    body['time'] = uptime;
    body['loadAvg5'] = loadAvg5;
    body['loadAvg15'] = loadAvg15;
    body['temp'] = temp;
    return Response.ok(body, headers: headers);
  }

  Response _powerOff(Request req) {
    Process.runSync('bash', ['-c', '/home/pi/wrapper.sh shutdown'],
        includeParentEnvironment: true, runInShell: true);
    return Response.ok('Shutdown in 1 minute');
  }

  Response _reboot(Request req) {
    Process.runSync('bash', ['-c', '/home/pi/wrapper.sh reboot'],
        includeParentEnvironment: true, runInShell: true);
    return Response.ok('Reboot in 1 minute');
  }

  Response _statusTorrent(Request req) {
    if (req.method == 'GET') {
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
    } else {
      final toggle = req.path.variables["toggle"];
      String command;
      if (toggle.contains('true')) {
        command = 'start';
      } else {
        command = 'stop';
      }
      Process.runSync(
          'bash', ['-c', 'sudo systemctl $command transmission-daemon'],
          includeParentEnvironment: true, runInShell: true);
      return Response.ok('');
    }
  }

  Response _teledart(Request req) {
    if (req.method == 'GET') {
      final Map<String, dynamic> body = {};
      final Map<String, dynamic> headers = {};
      headers["content-type"] = "application/json";
      final ProcessResult result = Process.runSync(
          'bash', ['-c', 'sudo systemctl status teledart | grep active'],
          includeParentEnvironment: true, runInShell: true);
      if (result.stdout.toString().contains('running')) {
        body['running'] = true;
      } else {
        body['running'] = false;
      }
      return Response.ok(body, headers: headers);
    } else {
      final toggle = req.path.variables["toggle"];
      String command;
      if (toggle.contains('true')) {
        command = 'start';
      } else {
        command = 'stop';
      }
      Process.runSync('bash', ['-c', 'sudo systemctl $command teledart'],
          includeParentEnvironment: true, runInShell: true);
      return Response.ok('');
    }
  }

  Response _smb(Request req) {
    if (req.method == 'GET') {
      final Map<String, dynamic> body = {};
      final Map<String, dynamic> headers = {};
      headers["content-type"] = "application/json";
      final ProcessResult result = Process.runSync(
          'bash', ['-c', 'sudo systemctl status smbd | grep active'],
          includeParentEnvironment: true, runInShell: true);
      if (result.stdout.toString().contains('running')) {
        body['running'] = true;
      } else {
        body['running'] = false;
      }
      return Response.ok(body, headers: headers);
    } else {
      final toggle = req.path.variables["toggle"];
      String command;
      if (toggle.contains('true')) {
        command = 'start';
      } else {
        command = 'stop';
      }
      Process.runSync('bash', ['-c', 'sudo /etc/init.d/samba $command'],
          includeParentEnvironment: true, runInShell: true);
      return Response.ok('');
    }
  }

  Response _ssh(Request req) {
    if (req.method == 'GET') {
      final Map<String, dynamic> body = {};
      final Map<String, dynamic> headers = {};
      headers["content-type"] = "application/json";
      final ProcessResult result = Process.runSync(
          'bash', ['-c', 'sudo systemctl status ssh | grep active'],
          includeParentEnvironment: true, runInShell: true);
      if (result.stdout.toString().contains('running')) {
        body['running'] = true;
      } else {
        body['running'] = false;
      }
      return Response.ok(body, headers: headers);
    } else {
      final toggle = req.path.variables["toggle"];
      String command;
      if (toggle.contains('true')) {
        command = 'start';
      } else {
        command = 'stop';
      }
      Process.runSync('bash', ['-c', 'sudo systemctl $command ssh'],
          includeParentEnvironment: true, runInShell: true);
      return Response.ok('');
    }
  }
}
