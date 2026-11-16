import 'package:flutter/material.dart';

class AddnewCharacter extends StatefulWidget {
  const AddnewCharacter({super.key});

  @override
  State<AddnewCharacter> createState() => _AddnewCharacterState();
}

class _AddnewCharacterState extends State<AddnewCharacter> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Add new character'),),
      ),
    
    );
  }
}