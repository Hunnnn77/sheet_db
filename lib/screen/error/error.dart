import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:go_router/go_router.dart";
import "package:sheet/extension/strings.dart";
import "package:sheet/global/errs.dart";

class ErrorScreen extends StatelessWidget {
  const ErrorScreen(this.exception, {super.key, this.goException});

  final Exception? exception;
  final GoException? goException;

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          fontFamily: "jetbrainsmono",
          scaffoldBackgroundColor: Colors.grey[500],
          useMaterial3: true,
        ),
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("${goException?.message ?? exception}"),
                const Gap(8),
                switch (exception) {
                  _ when exception is! InitException => ElevatedButton(
                      onPressed: () => context.pop(),
                      child: SizedBox(
                        width: 300,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(Icons.arrow_back),
                            const Gap(8),
                            Text("back to home".cap),
                          ],
                        ),
                      ),
                    ),
                  _ => const SizedBox(),
                },
              ],
            ),
          ),
        ),
      );
}
