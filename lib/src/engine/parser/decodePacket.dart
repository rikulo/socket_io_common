// Copyright (C) 2024 Potix Corporation. All Rights Reserved
// History: 2024/2/13 2:02 PM
// Author: jumperchen

import 'dart:convert';
import 'dart:typed_data';

import 'commons.dart';

mapBinary(data, binaryType) {
  final isBuffer = data is ByteBuffer;
  if (binaryType == 'arraybuffer') {
    return isBuffer ? data.asUint8List() : data;
  }
  return data;
}

decodePacket(dynamic encodedPacket, binaryType) {
  if (encodedPacket is! String) {
    return {'type': "message", 'data': mapBinary(encodedPacket, binaryType)};
  }
  var type = encodedPacket[0];

  if (type == 'b') {
    var buffer =
        base64.decode(utf8.decode(encodedPacket.substring(1).codeUnits));
    return {'type': "message", 'data': mapBinary(buffer, binaryType)};
  }

  if (!PACKET_TYPES_REVERSE.containsKey(type)) {
    return ERROR_PACKET;
  }

  if (encodedPacket.length > 1) {
    return {
      'type': PACKET_TYPES_REVERSE[type],
      'data': encodedPacket.substring(1)
    };
  } else {
    return {'type': PACKET_TYPES_REVERSE[type]};
  }
}
