import 'dart:typed_data';

import 'package:socket_io_common/src/parser/is_binary.dart';

createMap(TypedData? byteData) => {
      "child": byteData,
    };

createMapWithArray(TypedData? byteData) => {
      "child": [byteData]
    };

createDeepMap(TypedData? byteData) => {
      "child": {
        "deep": {"deep": byteData}
      },
    };

createDeepMapWithArray(TypedData? byteData) => {
      "child": {
        "deep": {
          "deep": [byteData]
        }
      },
    };

createArray(TypedData? byteData) => [byteData];

createArrayInArray(TypedData? byteData) => [
      [byteData]
    ];

createArrayWithMap(TypedData? byteData) => [createMap(byteData)];

createArrayWithDeepMap(TypedData? byteData) => [createDeepMap(byteData)];

createMapWithToJson(TypedData? byteData) => {
      "toJSON": () => {"child": byteData}
    };

main() {
  final byteData = ByteData(1);

  // -------------
  print("With ByteBuffer: ${hasBinary(byteData.buffer)}");
  print("With ByteData: ${hasBinary(byteData)}");
  print("-" * 30);
  // -------------
  print("With map and binary: ${hasBinary(createMap(byteData))}");
  print("With map and null: ${hasBinary(createMap(null))}");
  print("-" * 30);
  // -------------
  print(
      "With map with array and binary: ${hasBinary(createMapWithArray(byteData))}");
  print("With map with array and null: ${hasBinary(createMapWithArray(null))}");
  print("-" * 30);
  // -------------
  print("With deep map and binary: ${hasBinary(createDeepMap(byteData))}");
  print("With deep map and null: ${hasBinary(createDeepMap(null))}");
  print("-" * 30);
  // -------------
  print(
      "With deep map with array and binary: ${hasBinary(createDeepMapWithArray(byteData))}");
  print(
      "With deep map with array and null: ${hasBinary(createDeepMapWithArray(null))}");
  print("-" * 30);
  // -------------
  print("With array and binary: ${hasBinary(createArray(byteData))}");
  print("With array and null: ${hasBinary(createArray(null))}");
  print("-" * 30);
  // -------------
  print(
      "With array in array and binary: ${hasBinary(createArrayInArray(byteData))}");
  print("With array in array and null: ${hasBinary(createArrayInArray(null))}");
  print("-" * 30);
  // -------------
  print(
      "With array with map and binary: ${hasBinary(createArrayWithMap(byteData))}");
  print("With array with map and null: ${hasBinary(createArrayWithMap(null))}");
  print("-" * 30);
  // -------------
  print(
      "With array with deep map and binary: ${hasBinary(createArrayWithDeepMap(byteData))}");
  print(
      "With array with deep map and null: ${hasBinary(createArrayWithDeepMap(null))}");
  print("-" * 30);
  // -------------
  print("With toJSON and binary: ${hasBinary(createMapWithToJson(byteData))}");
  print("With toJSON and null: ${hasBinary(createMapWithToJson(null))}");
  print("With toJSON from an Object: ${hasBinary(MyObject())}");
}

class MyObject {
  Map toJSON() {
    return {"child": ByteData(1)};
  }
}
