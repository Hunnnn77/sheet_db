import "dart:async";

import "package:flutter_test/flutter_test.dart";
import "package:sheet/vm/vm_base.dart";

Future<Result<int, Exception>> run1(int i) async {
  if (i == 10) {
    return Ok(i);
  }
  return Err(Exception("err"));
}

Future<Option<int>> run2(int i) async {
  if (i == 10) {
    return Some(i);
  }
  return const None();
}

Future<Result<int, Exception>> r1() => Try(run1(-1)).toFuture;

void main() {
  test("func test", () async {
    final Stream<Result<int, Exception>> res2 = Try(r1()).stream$;
    res2.listen(
      (Result<int, Exception> event) => event.when(
        ok: (int ok) => print(ok),
        err: (Exception e) {
          print(-1);
        },
      ),
    );
    // // final String result0 = await res.then(
    // //   (Result<String, Exception> ok) =>
    // //       ok.when((String ok) => ok, err: (Exception e) => e.toString()),
    // // );
    // const int i = 1;
    // final int result = run1(i).when(
    //   (int value) => value * 2,
    //   err: (_) => -1,
    // );
    // final int result1 = run1(i).mapError((Exception e) => -1).eq(-1);
    // equals(result == -1);
    // equals(result1 == -1);
  });
}
