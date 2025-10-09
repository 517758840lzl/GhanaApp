import 'package:flutter/material.dart';

class ReadOnlyField extends StatelessWidget {
  final String label;
  final String currentValue;

  const ReadOnlyField({
    Key? key,
    required this.label,
    required this.currentValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 3),
      padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black,
            ),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              currentValue,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
