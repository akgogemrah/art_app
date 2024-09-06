import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  final String imageUrl;
  final String labelText;

  const CategoryButton({
    Key? key,
    required this.imageUrl,
    required this.labelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 3,),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Text(
                    labelText,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
