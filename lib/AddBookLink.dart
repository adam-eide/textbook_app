import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:textbook_app/BookInfoWindow.dart';
import 'package:url_launcher/url_launcher.dart';


class AddBookLink extends State {

  Map<String, dynamic> map;
  String isbn;
  AddBookLink(this.isbn);

  @override
  void initState() {
    super.initState();
    map = new Map<String, dynamic>();
    map.putIfAbsent('Votes', ()=>0);
    map.putIfAbsent('Reports', ()=>0);


  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("New Link"),
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
                          child: Text("Description", style: TextStyle(color:Color.fromRGBO(195, 195, 195, 1), fontWeight: FontWeight.bold ),),
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
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 5, right: 5),
                            isDense: false,
                            filled: true,
                            fillColor: Color.fromRGBO(220, 220, 220, 1),
                            hintText: "Enter a description",
                            //contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                            //focusedBorder: OutlineInputBorder(
                            //  borderSide: BorderSide(color: Colors.white),
                            //  borderRadius: BorderRadius.circular(25.7),
                            //),
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            }
                            map.putIfAbsent("Description", ()=>value.toString());//SAVE IT
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



                  /////////////////LINK
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
                          child: Text("Link", style: TextStyle(color:Color.fromRGBO(195, 195, 195, 1), fontWeight: FontWeight.bold ),),
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
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 5, right: 5),
                            isDense: false,
                            filled: true,
                            fillColor: Color.fromRGBO(220, 220, 220, 1),
                            hintText: "Enter a link",
                            //contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                            //focusedBorder: OutlineInputBorder(
                            //  borderSide: BorderSide(color: Colors.white),
                            //  borderRadius: BorderRadius.circular(25.7),
                            //),
                            border: InputBorder.none,
                            //contentPadding: EdgeInsets.zero
                          ),
                          validator: (value) {
                            print(value + "        value");
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            }
                            if (value.indexOf('.') == -1)
                              return 'This is not a valid url';
                            if (value.lastIndexOf('.') != value.indexOf('.')){
                              value = value.substring(value.indexOf('.')+1);
                            }
                            value = value.substring((value.contains('//') ? value.indexOf('//')+2 : 0));

                            value = ((value.startsWith('http:'))?(""):("http:")) + value;
                            print(value + "        value");
                            map.putIfAbsent("Link", ()=>value.toString());//SAVE IT
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
                              Firestore.instance.collection("books").where("ISBN", isEqualTo: isbn).getDocuments().then((doc){
                                if (doc.documents.isNotEmpty)
                                  doc.documents.elementAt(0).reference.collection("Resources").document()
                                      .setData({"Description":map["Description"], "Link":map["Link"], "Votes":0, "Reports":0}).then((v){
                                        Navigator.pop(context);
                                  });
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
                      "Verify that the description and link are correct, then press Submit to make a new resource link",
                      style: TextStyle(color: Color.fromRGBO(170, 170, 170, 1), fontSize: 14),),
                  )
                ]
            )
        ));
  }


}


class AddLink extends StatefulWidget{
  String isbn;
  AddLink(this.isbn);

  @override
  AddBookLink createState() => AddBookLink(this.isbn);
}