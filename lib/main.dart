import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

const appId = "541e5c51391048ab811a8d9a43f67556";
const token =
    "007eJxTYLi1K2phZpXpsxxGVZ07At/+m7d+bF9UVHuj/KOccgWHfpACg6mJYappsqmhsaWhgYlFYpKFoWGiRYploolxmpm5qamZXR1jWkMgI0Od+lJGRgYIBPGZGUqKKhkYAO48HTA=";
const channel = "try";

void main() => runApp(const MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late RtcEngine _engine;
  int _counter = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // Retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    // Create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
          });
          // Start the timer when user joins the channel
          _startTimer();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    await _engine.joinChannel(
      token: token,
      channelId: channel,
      uid: 0,
      options: const ChannelMediaOptions(
          autoSubscribeAudio: true), // Only subscribe to audio
    );
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
    // Cancel the timer when disposing the widget
    _timer.cancel();
  }

  // Start the timer
  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        _counter++;
      });
    });
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Audio Call'),
      ),
      body: Stack(
        children: [
          if(_counter == 0)...[
           
             Padding(
               padding: const EdgeInsets.all(18.0),
               child: Container(
                           alignment: Alignment.center,
               child: const Center(
                 child:  Column(
                   children: [
                      CircleAvatar(
                               child: Icon(Icons.person_2),
                             ),
                      Text('Calling...'),
                   ],
                 ),
               )
                           ),
             )
          ],

          
          // Display the counter
          Container(
            alignment: Alignment.center,
            child: _counter != 0 ? Text(
              '$_counter',
              style: const TextStyle(fontSize: 16),
            ) : const Text(''),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: _endCallUi(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _endCallUi() {
    return ElevatedButton(
      onPressed: () {
        // Implement logic to end the call here
        // For example, call _dispose() to leave the channel
        _showEndCallOptions();
        _dispose();
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
      ),
      child: const Text('End Call'),
    );
  }

  void _showEndCallOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Call Ended'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'How was the call?',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Implement logic for "Call Again"
                    },
                    child: const Text('Call Again'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Implement logic for "Thanks"
                    },
                    child: const Text('Thanks'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
