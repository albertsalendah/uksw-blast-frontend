// ignore_for_file: non_constant_identifier_names, library_prefixes
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../utils/SessionManager.dart';
import '../utils/link.dart';

class SocketProvider extends ChangeNotifier {
  IO.Socket? socket;
  String qr = '';
  String message = '';
  bool loading = true;
  bool mainmenuV = false;
  bool showQR = false;
  List<Job> jobs = [];
  Function(bool)? updateLoading;
  Function(bool)? updateMainMenu;
  Function(bool)? updateQR;
  Function(List<Job>)? listJob;
  Function(String)? QR;
  Function(String)? messages;

  final String link = Links().link;

  void connectToSocket() async {
    try {
      socket = IO.io(link, <String, dynamic>{
        'transports': ['websocket'],
      });
      socket?.on('log', (response) {
        if (response != null) {
          message = response;
          messages?.call(response);
        }
      });

      socket?.on('logout',(data) async {
        await SessionManager.logout();
      });

      socket?.on('qr', (response) {
        if (response != null) {
          qr = response;
          mainmenuV = false;
          showQR = true;
          loading = false;
          updateLoading?.call(loading);
          updateMainMenu?.call(mainmenuV);
          updateQR?.call(showQR);
          QR?.call(qr);
        }
      });

      socket?.on("qrstatus", (data) {
        if (data != null) {
          if (data.toString() == 'connected') {
            loading = false;
            mainmenuV = true;
            showQR = false;
            updateLoading?.call(loading);
            updateMainMenu?.call(mainmenuV);
            updateQR?.call(showQR);
          } else if (data.toString() == 'disconnected') {
            loading = true;
            mainmenuV = false;
            showQR = false;
            updateLoading?.call(loading);
            updateMainMenu?.call(mainmenuV);
            updateQR?.call(showQR);           
          }
        }
      });

      socket?.on('job', (data) {
        //setState(() {
        final jobId = data['jobId'];
        final progress = data['progress'];
        final status = data['status'];
        final sendto = data['sendto'];
        final message = data['message'];

        Job? existingJob;
        for (final job in jobs) {
          if (job.id == jobId) {
            existingJob = job;
            break;
          }
        }

        if (existingJob != null) {
          // Update the existing job's progress and status
          existingJob.progress = progress;
          existingJob.status = status;
          existingJob.message = message;
        } else {
          // Add the new job to the list
          jobs.add(Job(
              id: jobId,
              progress: progress,
              status: status,
              sendto: sendto,
              message: message));
        }
        listJob?.call(jobs);
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }
}

class Job {
  final String id;
  int progress;
  String status;
  String sendto;
  String message;

  Job(
      {required this.id,
      this.progress = 0,
      this.status = 'processing',
      this.sendto = '',
      this.message = ""});
}
