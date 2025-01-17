import 'dart:typed_data';

import 'package:socket_io_common/src/parser/is_binary.dart';
import 'package:test/test.dart';

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

  test("With ByteBuffer:", () {
    expect(hasBinary(byteData.buffer), true);
  });

  test("With ByteData:", () {
    expect(hasBinary(byteData), true);
  });

  test("With map and binary:", () {
    expect(hasBinary(createMap(byteData)), true);
  });
  test("With map and null:", () {
    expect(hasBinary(createMap(null)), false);
  });

  test("With map with array and binary:", () {
    expect(hasBinary(createMapWithArray(byteData)), true);
  });
  test("With map with array and null:", () {
    expect(hasBinary(createMapWithArray(null)), false);
  });

  test("With deep map and binary:", () {
    expect(hasBinary(createDeepMap(byteData)), true);
  });
  test("With deep map and null:", () {
    expect(hasBinary(createDeepMap(null)), false);
  });

  test("With deep map with array and binary:", () {
    expect(hasBinary(createDeepMapWithArray(byteData)), true);
  });
  test("With deep map with array and null:", () {
    expect(hasBinary(createDeepMapWithArray(null)), false);
  });

  test("With array and binary:", () {
    expect(hasBinary(createArray(byteData)), true);
  });
  test("With array and null:", () {
    expect(hasBinary(createArray(null)), false);
  });

  test("With array in array and binary:", () {
    expect(hasBinary(createArrayInArray(byteData)), true);
  });
  test("With array in array and null:", () {
    expect(hasBinary(createArrayInArray(null)), false);
  });

  test("With array with map and binary:", () {
    expect(hasBinary(createArrayWithMap(byteData)), true);
  });
  test("With array with map and null:", () {
    expect(hasBinary(createArrayWithMap(null)), false);
  });

  test("With array with deep map and binary:", () {
    expect(hasBinary(createArrayWithDeepMap(byteData)), true);
  });
  test("With array with deep map and null:", () {
    expect(hasBinary(createArrayWithDeepMap(null)), false);
  });

  test("With toJSON and binary:", () {
    expect(hasBinary(createMapWithToJson(byteData)), true);
  });
  test("With toJSON and null:", () {
    expect(hasBinary(createMapWithToJson(null)), false);
  });
  test("With toJSON from an Object:", () {
    expect(hasBinary(MyObject()), true);
  });
  test("With toJSON from an String:", () {
    expect(hasBinary('plain'), false);
  });
}

class MyObject {
  Map toJSON() {
    return {"child": ByteData(1)};
  }
}
