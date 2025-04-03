// Copyright (C) 2025 Potix Corporation. All Rights Reserved
// History: 2025/4/2 3:48 PM
// Author: jumperchen<jumperchen@potix.com>
import "package:socket_io_common/src/util/js_type_adapter.dart"
    if (dart.library.js_interop) 'js_interop_type_adapter.dart';

bool isJSString(Object obj) {
  return isString(obj);
}
