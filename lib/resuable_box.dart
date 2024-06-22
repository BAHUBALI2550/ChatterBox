import 'package:flutter/cupertino.dart';

class ReusableBox extends StatelessWidget {
  final String heading;
  final String description;
  final Color color;
  const ReusableBox({super.key, required this.color, required this.heading, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 35,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(15))
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20).copyWith(left: 15,),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(heading,style: TextStyle(
                fontFamily: 'Cera Pro',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: CupertinoColors.black,
              ),),
            ),
            SizedBox(height: 3,),
            Padding(
              padding: const EdgeInsets.only(right: 35.0),
              child: Text(description,style: TextStyle(
                fontFamily: 'Cera Pro',
                color: CupertinoColors.black,
              ),),
            ),
          ],
        ),
      ),
    );
  }
}
