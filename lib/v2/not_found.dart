import 'package:flutter/material.dart';

class NotFound extends StatelessWidget {
  final Function() setSelectedPage;
  const NotFound({
    super.key,
    required this.setSelectedPage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "404",
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const Text("The page you are looking for is not here."),
          TextButton(
            child: const Text("Home"),
            onPressed: () {
              setSelectedPage();
            },
          ),
        ],
      ),
    );
  }
}
