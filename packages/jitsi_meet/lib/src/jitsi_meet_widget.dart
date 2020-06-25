import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:jitsi_meet/src/jitsi_meet_controller.dart';

const String viewType = 'surfstudio/jitsi_meet';

class JitsiMeetWidget extends StatefulWidget {
  final JitsiMeetViewCreatedCallback onControllerCreated;
  final VoidCallback onJoined;
  final VoidCallback onWillJoin;
  final VoidCallback onTerminated;

  const JitsiMeetWidget({
    Key key,
    @required this.onControllerCreated,
    this.onJoined,
    this.onWillJoin,
    this.onTerminated,
  }) : super(key: key);

  @override
  _JitsiMeetWidgetState createState() => _JitsiMeetWidgetState();
}

class _JitsiMeetWidgetState extends State<JitsiMeetWidget> {
  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: viewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParamsCodec: const StandardMessageCodec(),
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          ].toSet(),
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: viewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParamsCodec: const StandardMessageCodec(),
        );
      default:
        throw Exception("Unsupported TargetPlatform - $defaultTargetPlatform ");
    }
  }

  void _onPlatformViewCreated(int id) {
    widget.onControllerCreated?.call(
      JitsiMeetController.init(
        id,
        widget.onWillJoin,
        widget.onJoined,
        widget.onTerminated,
      ),
    );
  }
}
