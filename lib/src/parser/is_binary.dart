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

  if (obj is List && obj is! TypedData) {
    for (var value in obj) {
      if (hasBinary(value)) {
        return true;
      }
    }
  }

  if (isBinary(obj)) {
    return true;
  }

  // Check if the object has a toJSON method, regardless of its type (Map, custom object, etc.)
  var toJsonMethod = _getToJsonMethod(obj);
  if (toJsonMethod != null && toJSON == false) {
    return hasBinary(toJsonMethod(), true);
  }

  if (obj is Map) {
    for (var entry in obj.entries) {
      if (hasBinary(entry.value)) {
        return true;
      }
    }
  }

  return false;
}

// Helper function to dynamically check if an object has a toJSON method
Function? _getToJsonMethod(obj) {
  try {
    var toJsonMethod = obj.toJSON;
    if (toJsonMethod is Function) {
      return toJsonMethod;
    }
  } catch (e) {
    // Catch and ignore errors if the method is not present
  }
  return null;
}
