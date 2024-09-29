// Copyright (C) 2024 Potix Corporation. All Rights Reserved
// History: 2024/2/13 1:50 PM
// Author: jumperchen

enum PacketType { OPEN, CLOSE, PING, PONG, MESSAGE, UPGRADE, NOOP }

const List<String?> PacketTypeList = const <String?>[
  'open',
  'close',
  'ping',
  'pong',
  'message',
  'upgrade',
  'noop'
];

const Map<String, int> PacketTypeMap = const <String, int>{
  'open': 0,
  'close': 1,
  'ping': 2,
  'pong': 3,
  'message': 4,
  'upgrade': 5,
  'noop': 6
};

// Create PACKET_TYPES_REVERSE by reversing the key-value pairs in PacketTypeMap
Map<String, String> PACKET_TYPES_REVERSE = {
  for (var entry in PacketTypeMap.entries) '${entry.value}': entry.key,
};

const ERROR_PACKET = const {'type': 'error', 'data': 'parser error'};
