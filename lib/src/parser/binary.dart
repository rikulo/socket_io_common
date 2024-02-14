// Copyright (C) 2018 Potix Corporation. All Rights Reserved
// History: 2018/6/1 12:31 PM
// Author: jumperchen<jumperchen@potix.com>

import 'dart:typed_data';

class Binary {
  static final String KEY_PLACEHOLDER = "_placeholder";

  static final String KEY_NUM = "num";

  static Map deconstructPacket(Map packet) {
    List buffers = [];

    packet['data'] = _deconstructPacket(packet['data'], buffers);
    packet['attachments'] = buffers.length;

    return {'packet': packet, 'buffers': buffers};
  }

  static Object? _deconstructPacket(Object? data, List buffers) {
    if (data == null) return null;

    if (data is Uint8List || data is ByteBuffer) {
      final placeholder = {KEY_PLACEHOLDER: true, KEY_NUM: buffers.length};
      buffers.add(data);
      return placeholder;
    } else if (data is List) {
      final newData = [];
      final _data = data;
      int len = _data.length;
      for (int i = 0; i < len; i++) {
        newData.add(_deconstructPacket(_data[i], buffers));
      }
      return newData;
    } else if (data is Map) {
      final newData = {};
      final _data = data;
      data.forEach((k, v) {
        newData[k] = _deconstructPacket(_data[k], buffers);
      });
      return newData;
    }
    return data;
  }

  static Map reconstructPacket(Map packet, List<dynamic> buffers) {
    packet['data'] = _reconstructPacket(packet['data'], buffers);
    packet['attachments'] = -1; // no longer useful
    return packet;
  }

  static Object? _reconstructPacket(Object? data, List<dynamic> buffers) {
    // Check if data is null or doesn't exist
    if (data == null) return data;

    // Check if data is marked as a placeholder and process accordingly
    if (data is Map && data[KEY_PLACEHOLDER] == true) {
      bool isIndexValid = data[KEY_NUM] is int &&
          data[KEY_NUM] >= 0 &&
          data[KEY_NUM] < buffers.length;
      if (isIndexValid) {
        // Return the appropriate buffer
        return buffers[data[KEY_NUM]];
      } else {
        // Throw an error if the index is not valid
        throw FormatException("Illegal attachments");
      }
    }

    if (data is List) {
      final _data = data;
      int i = 0;
      _data.forEach((v) {
        _data[i++] = _reconstructPacket(v, buffers);
      });
      return _data;
    } else if (data is Map) {
      final _data = data;
      if ('${_data[KEY_PLACEHOLDER]}'.toLowerCase() == 'true') {
        final knum = _data[KEY_NUM]!;
        int num = knum is int ? knum : int.parse(knum).toInt();
        return num >= 0 && num < buffers.length ? buffers[num] : null;
      }
      data.forEach((key, value) {
        _data[key] = _reconstructPacket(value, buffers);
      });
      return _data;
    }
    return data;
  }
}
