// Copyright (C) 2020 Potix Corporation. All Rights Reserved
// History: 2020/12/18 4:44 PM
// Author: jumperchen<jumperchen@potix.com>

import 'dart:typed_data';

bool isView(Object obj) {
  // Dart's typed data library provides a way to work with binary data.
  // Here, we check if obj is a subtype of TypedData, which includes views of ByteBuffers.
  return obj is TypedData;
}

bool isBinary(obj) {
  return (obj != null && obj is ByteBuffer) || isView(obj);
}

bool hasBinary(obj, [bool toJSON = false]) {
  if (obj == null) {
    return false;
  }

  if (obj is Map) {
    if (obj['toJSON'] != null && obj['toJSON'] is Function && toJSON == false) {
      return hasBinary(obj["toJSON"]!(), true);
    }

    for (var entry in obj.entries) {
      if (hasBinary(entry.value)) {
        return true;
      }
    }
  } else if (obj is List) {
    for (var value in obj) {
      if (hasBinary(value)) {
        return true;
      }
    }
  }

  if (isBinary(obj)) {
    return true;
  }

  return false;
}
