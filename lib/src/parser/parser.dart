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
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:socket_io_common/socket_io_common.dart';
import 'package:socket_io_common/src/util/event_emitter.dart';

import 'is_binary.dart';

const int CONNECT = 0;
const int DISCONNECT = 1;
const int EVENT = 2;
const int ACK = 3;
const int CONNECT_ERROR = 4;
const int BINARY_EVENT = 5;
const int BINARY_ACK = 6;

/// These strings must not be used as event names, as they have a special meaning.
const List<String> RESERVED_EVENTS = [
  "connect", // used on the client side
  "connect_error", // used on the client side
  "disconnect", // used on both sides
  "disconnecting", // used on the server side
  "newListener", // used by the Node.js EventEmitter
  "removeListener", // used by the Node.js EventEmitter
];

/// A socket.io Encoder instance
List<String?> PacketTypes = <String?>[
  'CONNECT',
  'DISCONNECT',
  'EVENT',
  'ACK',
  'CONNECT_ERROR',
  'BINARY_EVENT',
  'BINARY_ACK'
];

class Encoder {
  static final Logger _logger = new Logger('socket_io:parser.Encoder');

  /// Encode a packet as a single string if non-binary, or as a
  /// buffer sequence, depending on packet type.
  encode(obj) {
    if (_logger.isLoggable(Level.FINE)) {
      _logger.fine('encoding packet $obj');
    }

    if (EVENT == obj['type'] || ACK == obj['type']) {
      if (hasBinary(obj)) {
        obj['type'] = obj['type'] == EVENT ? BINARY_EVENT : BINARY_ACK;
        return encodeAsBinary(obj);
      }
    }
    return [encodeAsString(obj)];
  }

  /// Encode packet as string.
  static String encodeAsString(obj) {
    // first is type
    var str = '${obj['type']}';

    // attachments if we have them
    if (BINARY_EVENT == obj['type'] || BINARY_ACK == obj['type']) {
      str += '${obj['attachments']}-';
    }

    // if we have a namespace other than `/`
    // we append it followed by a comma `,`
    if (obj['nsp'] != null && '/' != obj['nsp']) {
      str += obj['nsp'] + ',';
    }

    // immediately followed by the id
    if (null != obj['id']) {
      str += '${obj['id']}';
    }

    // json data
    if (null != obj['data']) {
      str += json.encode(obj['data']);
    }

    if (_logger.isLoggable(Level.FINE)) {
      _logger.fine('encoded $obj as $str');
    }
    return str;
  }

  /// Encode packet as 'buffer sequence' by removing blobs, and
  /// deconstructing packet into object with placeholders and
  /// a list of buffers.
  static encodeAsBinary(obj) {
    final deconstruction = Binary.deconstructPacket(obj);
    final pack = encodeAsString(deconstruction['packet']);
    final buffers = deconstruction['buffers'];

    // add packet info to beginning of data list
    return <dynamic>[pack]..addAll(buffers); // write all the buffers
  }
}

/// A socket.io Decoder instance
class Decoder extends EventEmitter {
  BinaryReconstructor? reconstructor = null;

  /// Decodes an encoded packet string into packet JSON.
  add(obj) {
    var packet;
    if (obj is String) {
      if (reconstructor != null) {
        throw Exception("got plaintext data when reconstructing a packet");
      }
      packet = decodeString(obj);
      if (BINARY_EVENT == packet['type'] || BINARY_ACK == packet['type']) {
        // binary packet's json
        this.reconstructor = new BinaryReconstructor(packet);

        // no attachments, labeled binary but no binary data to follow
        if (packet['attachments'] == 0) {
          this.emitReserved('decoded', packet);
        }
      } else {
        // non-binary full packet
        this.emitReserved('decoded', packet);
      }
    } else if (isBinary(obj) || obj is Map && obj['base64'] != null) {
      // raw binary data
      if (this.reconstructor == null) {
        throw new UnsupportedError(
            'got binary data when not reconstructing a packet');
      } else {
        packet = this.reconstructor!.takeBinaryData(obj);
        if (packet != null) {
          // received final buffer
          this.reconstructor = null;
          this.emitReserved('decoded', packet);
        }
      }
    } else {
      throw new UnsupportedError('Unknown type: ' + obj);
    }
  }

  /// Decode a packet String (JSON data)
  static decodeString(String str) {
    var i = 0;
    var endLen = str.length - 1;
    // look up type
    var p = <String, dynamic>{'type': num.parse(str[0])};

    if (null == PacketTypes[p['type']]) {
      throw new UnsupportedError("unknown packet type " + p['type']);
    }

    // look up attachments if type binary
    if (BINARY_EVENT == p['type'] || BINARY_ACK == p['type']) {
      final start = i + 1;
      while (str[++i] != '-' && i != str.length) {}
      var buf = str.substring(start, i);
      if (buf != '${num.tryParse(buf) ?? -1}' || str[i] != '-') {
        throw new ArgumentError('Illegal attachments');
      }
      p['attachments'] = num.parse(buf);
    }

    // look up namespace (if any)
    if (i < endLen - 1 && '/' == str[i + 1]) {
      var start = i + 1;
      while (++i > 0) {
        if (i == str.length) break;
        var c = str[i];
        if ("," == c) break;
      }
      p['nsp'] = str.substring(start, i);
    } else {
      p['nsp'] = '/';
    }

    // look up id
    var next = i < endLen - 1 ? str[i + 1] : null;
    if (next?.isNotEmpty == true && '${num.tryParse(next!)}' == next) {
      var start = i + 1;
      while (++i > 0) {
        var c = str.length > i ? str[i] : null;
        if ('${num.tryParse(c!)}' != c) {
          --i;
          break;
        }
        if (i == str.length) break;
      }
      p['id'] = int.tryParse(str.substring(start, i + 1));
    }

    // look up json data
    if (i < endLen - 1 && str[++i].isNotEmpty == true) {
      var payload = tryParse(str.substring(i));
      if (isPayloadValid(p['type'], payload)) {
        p['data'] = payload;
      } else {
        throw new UnsupportedError("invalid payload");
      }
    }

//    debug('decoded %s as %j', str, p);
    return p;
  }

  static tryParse(str) {
    try {
      return json.decode(str);
    } catch (e) {
      return false;
    }
  }

  static isPayloadValid(type, payload) {
    switch (type) {
      case CONNECT:
        return isObject(payload);
      case DISCONNECT:
        return payload == null;
      case CONNECT_ERROR:
        return payload is String || isObject(payload);
      case EVENT:
      case BINARY_EVENT:
        return payload is List &&
            payload.isNotEmpty &&
            ((payload[0] is int) ||
                (payload[0] is String &&
                    !RESERVED_EVENTS.contains(payload[0])));
      case ACK:
      case BINARY_ACK:
        return payload is List;
    }
  }

  /// Deallocates a parser's resources
  destroy() {
    if (this.reconstructor != null) {
      this.reconstructor!.finishedReconstruction();
      this.reconstructor = null;
    }
  }
}

/// A manager of a binary event's 'buffer sequence'. Should
/// be constructed whenever a packet of type BINARY_EVENT is
/// decoded.
class BinaryReconstructor {
  Map? reconPack;
  List buffers = [];

  BinaryReconstructor(packet) {
    this.reconPack = packet;
  }

  /// Method to be called when binary data received from connection
  /// after a BINARY_EVENT packet.
  takeBinaryData(binData) {
    this.buffers.add(binData);
    if (this.buffers.length == this.reconPack!['attachments']) {
      // done with buffer list
      var packet = Binary.reconstructPacket(this.reconPack!, this.buffers);
      this.finishedReconstruction();
      return packet;
    }
    return null;
  }

  /// Cleans up binary packet reconstruction variables.
  void finishedReconstruction() {
    this.reconPack = null;
    this.buffers = [];
  }
}

bool isNamespaceValid(nsp) {
  return nsp is String;
}

bool isInteger(dynamic value) {
  return value is int;
}

bool isAckIdValid(dynamic id) {
  return id == null || isInteger(id);
}

bool isObject(payload) {
  return payload == null || payload is Map || payload is List;
}

bool isPacketValid(packet) {
  return isNamespaceValid(packet['nsp']) &&
      isAckIdValid(packet['id']) &&
      Decoder.isPayloadValid(packet['type'], packet['data']);
}
