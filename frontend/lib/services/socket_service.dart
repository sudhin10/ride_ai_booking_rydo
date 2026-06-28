import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../core/constants/api_endpoints.dart';

/// Real-time ride tracking over Socket.IO.
class SocketService {
  io.Socket? _socket;
  String? _rideId;

  void Function(double lat, double lng, int eta, String phase)? onDriverLocation;
  void Function(String status)? onStatus;

  bool get connected => _socket?.connected ?? false;

  void connectAndSubscribe(String rideId) {
    _rideId = rideId;
    _socket ??= io.io(
      ApiEndpoints.socketUrl,
      io.OptionBuilder().setTransports(['websocket']).enableReconnection().build(),
    );

    final s = _socket!;
    s.onConnect((_) {
      debugPrint('[socket] connected');
      s.emit('ride:subscribe', {'rideId': rideId});
    });

    s.on('driver:location', (data) {
      final lat = (data['lat'] as num).toDouble();
      final lng = (data['lng'] as num).toDouble();
      final eta = (data['eta'] ?? 0) as int;
      final phase = (data['phase'] ?? 'arriving').toString();
      onDriverLocation?.call(lat, lng, eta, phase);
    });

    s.on('ride:status', (data) => onStatus?.call(data['status'].toString()));
    s.onDisconnect((_) => debugPrint('[socket] disconnected'));
    s.onError((e) => debugPrint('[socket] error: $e'));

    if (s.connected) {
      s.emit('ride:subscribe', {'rideId': rideId});
    } else {
      s.connect();
    }
  }

  void dispose() {
    if (_socket != null && _rideId != null) {
      _socket!.emit('ride:unsubscribe', {'rideId': _rideId});
    }
    _socket?.dispose();
    _socket = null;
  }
}
