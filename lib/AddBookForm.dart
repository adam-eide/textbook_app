import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class AddBookForm extends State {

  Map<String, String> map;
  String isbn;
  AddBookForm(this.isbn);

  @override
  void initState() {
    super.initState();
    map = new Map<String, String>();

  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text("New Book"),
    ),
    body: Form(
        key: _formKey,
        child: Column(
            children: <Widget>[
              TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  map.putIfAbsent("ISBN", ()=>value.toString());//SAVE IT
                  return null;
                },
              ),
              TextFormField(
                validator: (value) {
                if (value.isEmpty) {
              return 'Please enter some text';
            }
                map.putIfAbsent("Name", ()=>value.toString());//SAVE IT
                  return null;
                },
          ),
              TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  map.putIfAbsent("Edition", ()=>value.toString());//SAVE IT
                  return null;
                },
              ),
              RaisedButton(
          onPressed: () {
          // Validate returns true if the form is valid, otherwise false.
              if (_formKey.currentState.validate()) {
                  Firestore.instance.collection("books")
                      .document().setData({'ISBN':isbn, 'Name': map['Name'], "Edition":map['Edition'] });

                Scaffold
                    .of(context)
                    .showSnackBar(SnackBar(content: Text('Processing Data')));
              }
           },
          child: Text('Submit'),
          )

            ]
        )
    ));
  }


}


class AddBook extends StatefulWidget{
String isbn;
  AddBook(this.isbn);

  @override
  AddBookForm createState() => AddBookForm(this.isbn);
}