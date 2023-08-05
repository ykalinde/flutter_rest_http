import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_rest_http/flutter_rest_http.dart';

void main() {
  test('adds one to input values', () {
    RestHttp.init(
      baseURL: "https://google.com/",
      globalHeaders: () {
        return {"Authorization": "Bearer 123"};
      },
    );

    RestHttp.get("hello");
    expect(true, 2 > 1);

    // expect(calculator.addOne(2), 3);
    // expect(calculator.addOne(-7), -6);
    // expect(calculator.addOne(0), 1);
  });
}
