import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_rest_http/flutter_rest_http.dart';

void main()  {
  test('adds one to input values', ()async {
    RestHttp.init(
      baseURL: "https://jsonplaceholder.typicode.com/",
      globalHeaders: () async {
        return {"Authorization": "Bearer 123"};
      },
    );

    var res = await RestHttp.get("posts/1");
    expect(200, res.code);
  });
}
