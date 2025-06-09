import 'package:flutter/material.dart';

class DividerLoginWidget extends StatelessWidget {
  const DividerLoginWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 30,
      child: Row(
        children: [
          Expanded(
            child: Divider(
              thickness: 1,
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "أو",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              thickness: 1,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
