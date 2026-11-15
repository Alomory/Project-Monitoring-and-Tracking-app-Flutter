
import 'package:flutter/material.dart';

AppBar appBar (String text, Function reload){
  return AppBar(
  title:  Text(text),
  centerTitle: true,
  actions: [
    IconButton(onPressed: ()=> reload, icon: Icon(Icons.refresh))
  ],
);
}

SnackBar snackBar (String content, Function doSomething){
  return SnackBar(content:  Text(content),
    action: SnackBarAction(
    label: 'Add Phase',
    onPressed: () => doSomething,
  ),
  );
}
// ref: https://stackoverflow.com/questions/29628989/how-to-capitalize-the-first-letter-of-a-string-in-dart
extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}
