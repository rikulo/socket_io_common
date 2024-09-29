// Copyright (C) 2024 Potix Corporation. All Rights Reserved
// History: 2024/2/13 1:46 PM
// Author: jumperchen
import 'dart:convert';
import 'dart:typed_data';

import 'commons.dart';

encodePacket(Packet packet, bool supportsBinary, callback(_)) {
  if (packet.data is ByteBuffer || packet.data is Uint8List) {
    return callback(supportsBinary
        ? packet.data
        : 'b' + base64Encode(toBuffer(packet.data, true)));
  } else {
    // plain string
    return callback('${PacketTypeMap[packet.type]}' + (packet.data ?? ''));
  }
}

Uint8List toBuffer(dynamic data, bool forceBufferConversion) {
  if (data is Uint8List && !forceBufferConversion) {
    return data;
  } else if (data is ByteBuffer) {
    return data.asUint8List();
  } else {
    // Assuming data is TypedData and extracting buffer
    return Uint8List.view(data.buffer, data.offsetInBytes, data.lengthInBytes);
  }
}

final TextEncoder _textEncoder = TextEncoder();

void encodePacketToBinary(Packet packet, callback(_)) {
  if (packet.data is ByteBuffer || packet.data is Uint8List) {
    callback(toBuffer(packet.data, false));
  } else {
    encodePacket(packet, true, (encoded) {
      callback(_textEncoder.encode(encoded));
    });
  }
}

class Packet {
  String type;
  dynamic data;

  Packet(this.type, this.data);
}

class TextEncoder {
  Uint8List encode(String input) {
    return Uint8List.fromList(utf8.encode(input));
  }
}
