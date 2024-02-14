/// parser.dart
///
/// Purpose:
///
/// Description:
///
/// History:
///    20/02/2017, Created by jumperchen
///
/// Copyright (C) 2017 Potix Corporation. All Rights Reserved.
import 'dart:async';

import 'decodePacket.dart' as decoder;
import 'encodePacket.dart' as encoder;

// Protocol version used in socket.io-client
final protocol = 4;

final SEPARATOR = String.fromCharCode(30);

class PacketParser {
  static String? encodePacket(Map packet,
      {required bool supportsBinary,
      required callback(_),
      bool fromClient = false}) {
    return encoder.encodePacket(encoder.Packet(packet['type'], packet['data']),
        supportsBinary, callback);
  }

  static encodePayload(List packets, {required callback(_)}) {
    final length = packets.length;
    final encodedPackets = []..length = length;
    var count = 0;
    var i = 0;
    packets.forEach((packet) {
      // force base64 encoding for binary packets
      encoder
          .encodePacket(encoder.Packet(packet['type'], packet['data']), false,
              (encodedPacket) {
        encodedPackets[i++] = encodedPacket;
        if (++count == length) {
          callback(encodedPackets.join(SEPARATOR));
        }
      });
    });
  }

  /// Async array map using after
  static map(List ary, each(_, callback(msg)), done(results)) {
    var result = [];
    Future.wait(ary.map((e) {
      return new Future.microtask(() => each(e, (msg) {
            result.add(msg);
          }));
    })).then((r) => done(result));
  }

  /// Decodes data when a payload is maybe expected. Possible binary contents are
  /// decoded from their base64 representation
  ///
  static decodePayload(encodedPayload, binaryType) {
    var encodedPackets = encodedPayload.split(SEPARATOR);
    var packets = [];
    for (var i = 0; i < encodedPackets.length; i++) {
      var decodedPacket = decoder.decodePacket(encodedPackets[i], binaryType);
      packets.add(decodedPacket);
      if (decodedPacket['type'] == "error") {
        break;
      }
    }
    return packets;
  }

  static decodePacket(dynamic encodedPacket, binaryType) {
    return decoder.decodePacket(encodedPacket, binaryType);
  }
}
