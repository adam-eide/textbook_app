import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:textbook_app/BookInfoWindow.dart';


class AddBookForm extends State {

  Map<String, String> map;
  String isbn;
  String name;
  AddBookForm(this.isbn, this.name);

  @override
  void initState() {
    super.initState();
    map = new Map<String, String>();
    if (isbn.length > 0) map.putIfAbsent('ISBN', ()=>isbn);
    if (name.length > 0) map.putIfAbsent('Name', ()=>name);


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
          crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 30,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 16,

                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(
                      height: 16,
                      child: Text("ISBN 13", style: TextStyle(color:Color.fromRGBO(195, 195, 195, 1), fontWeight: FontWeight.bold ),),
                    ),
                  )

                ],
              ),

              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(

                    ),
                  ),

                  Expanded(
                    flex: 10,
                    child: TextFormField(
                      enabled: ((map.containsKey('ISBN'))?(false):(true)),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 5, right: 5),
                        isDense: false,
                        filled: true,
                        fillColor: Color.fromRGBO(220, 220, 220, 1),
                        hintText: ((map.containsKey('ISBN'))?(map['ISBN']):("Enter ISBN 13")),
                        //contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                        //focusedBorder: OutlineInputBorder(
                        //  borderSide: BorderSide(color: Colors.white),
                        //  borderRadius: BorderRadius.circular(25.7),
                        //),
                        border: InputBorder.none,
                        //contentPadding: EdgeInsets.zero
                      ),
                      validator: (value) {
                        if (value.isEmpty && (!map.containsKey('ISBN'))) {
                          return 'Please enter some text';
                        }
                        map.putIfAbsent("ISBN", ()=>value.toString());//SAVE IT
                        return null;
                      },
                    ),
                  ),Expanded(
                    flex: 2,
                    child: Container(

                    ),
                  ),
                ],
              ),





              Container(
                height: 20,
              ),



              /////////////////NAME
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 16,

                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(
                      height: 16,
                      child: Text("Title", style: TextStyle(color:Color.fromRGBO(195, 195, 195, 1), fontWeight: FontWeight.bold ),),
                    ),
                  )

                ],
              ),

              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(

                    ),
                  ),

                  Expanded(
                    flex: 10,
                    child: TextFormField(
                      enabled: ((map.containsKey('Name'))?(false):(true)),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 5, right: 5),
                        isDense: false,
                        filled: true,
                        fillColor: Color.fromRGBO(220, 220, 220, 1),
                        hintText: ((map.containsKey('Name'))?(map['Name']):("Enter Title")),
                        //contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                        //focusedBorder: OutlineInputBorder(
                        //  borderSide: BorderSide(color: Colors.white),
                        //  borderRadius: BorderRadius.circular(25.7),
                        //),
                        border: InputBorder.none,
                        //contentPadding: EdgeInsets.zero
                      ),
                      validator: (value) {
                        if (value.isEmpty && (!map.containsKey('Name'))) {
                          return 'Please enter some text';
                        }
                        map.putIfAbsent("Name", ()=>value.toString());//SAVE IT
                        return null;
                      },
                    ),
                  ),Expanded(
                    flex: 2,
                    child: Container(

                    ),
                  ),
                ],
              ),
              Container(
                height: 16,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 10,
                    child: Container(
                      padding: EdgeInsets.only(left: 8, right: 8),

                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: RaisedButton(
                      onPressed: () {
                      // Validate returns true if the form is valid, otherwise false.
                          if (_formKey.currentState.validate()) {

                              Firestore.instance.collection("books")
                                  .document().setData({'ISBN':map['ISBN'], 'Name': map['Name'].toUpperCase() }).then((v){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                                        return BookInfo(map['ISBN'],  map['Name']);
                                }));
                              });

                          }
                       },
                      child: Text('Submit'),
                      ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(

                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(left: 50, right: 50, top: 10),
                child: Text(
                  "Verify that the ISBN and Title are correct, then press Submit to make a new book page",
                  style: TextStyle(color: Color.fromRGBO(170, 170, 170, 1), fontSize: 14),),
              )
            ]
        )
    ));
  }


}


class AddBook extends StatefulWidget{
String isbn;
String name;
  AddBook(this.isbn, this.name);

  @override
  AddBookForm createState() => AddBookForm(this.isbn, this.name);
}