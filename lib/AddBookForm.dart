import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class AddBookForm extends State {

  String isbn;
  AddBookForm(this.isbn);

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hi"),

      ),
      body: Container(),
    );
  }


}


class AddBook extends StatefulWidget{
String isbn;
  AddBook(this.isbn);

  @override
  AddBookForm createState() => AddBookForm(this.isbn);
}