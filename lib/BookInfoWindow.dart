import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:textbook_app/AddBookLink.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info/device_info.dart';

import 'package:textbook_app/UserDocument.dart';

class BookInfoWindow extends State {

  String isbn;
  String name;
  BookInfoWindow(this.isbn, this.name);
  bool ready;
  CollectionReference resourceCollection;
  List<String> votedIDs;

  @override
  void initState() {
    super.initState();
    ready = false;
    votedIDs = List();
    getLinks().whenComplete(()=>this.setState((){}));

  }


  @override
  Widget build(BuildContext context) {
    print("BUILDING");
    return Scaffold(
        appBar: AppBar(
          title: Text(name),
        ),
        body: ((ready!= null && ready)? (_buildPage(context)):(Container(color: Colors.red,))));
  }

  _buildPage(BuildContext c){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        _buildInfo(),
        _buildAddButton(c),
        _buildLinks()
      ],
    );
  }

  _buildInfo(){
    print("BUILDINFO");
    return Container(
      color: Color.fromRGBO(180, 180, 180, 1),
      width: MediaQuery.of(context).size.width,
      height: 120,
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(

            ),
          ),
          Expanded(
            flex: 12,
            child: Container(

              child: Text(name,
                textAlign: TextAlign.left,
                style: TextStyle(fontWeight: FontWeight.bold),
                textScaleFactor: 1.5,),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
                "ISBN: " + isbn,
                textAlign: TextAlign.left
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(

            ),
          ),
        ],
      ),
    );
  }

  _buildAddButton(BuildContext context){
    print("build add");
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: 38,
      child: Row(
        children: <Widget>[

          Expanded(
            flex: 6,
            child: Container(),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerRight,
              //color: Colors.black,
              child: Text(
                "Add Link", textAlign: TextAlign.right,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
                icon: Icon(Icons.add),
                onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AddLink(isbn);
                }));}
            ),
          ),
        ],
      )
    );
  }


  _buildLinks(){
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: resourceCollection.snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return new Text('Loading...');
            return new ListView(
              children: snapshot.data.documents.map((DocumentSnapshot document) {
                return new Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                          title: _buildWidget(document),
                      ),

                    ],
                  )
                );
              }).toList(),
            );
          },
      )
    );

  }
  
  Future<void> getLinks() async {
    print("GET LINKS");
    resourceCollection = (await Firestore.instance.collection('books').where("ISBN", isEqualTo: isbn).getDocuments()).documents.elementAt(0).reference.collection('Resources');
    votedIDs = await UserDocument.instance.getVotes();
    setState(() {
      ready = true;
    });


  }

   _buildWidget(DocumentSnapshot document) {
    print("BUILDWIDG");
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height/12,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 26,
            child: Container(

              child: ConstrainedBox(
                constraints: BoxConstraints.expand(),
                child: FlatButton(
                  highlightColor: Colors.blueAccent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(document['Description'].toString(),
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        textScaleFactor: 1.3,),
                      Container(
                        height: 3,
                      ),
                      Text(
                        document['Link'],
                        textAlign: TextAlign.left,
                        textScaleFactor: 0.9,
                      ),
                      Container(
                        height: 2,
                      ),
                    ],
                  ),
                  onPressed: (){
                    print("PRESSED");
                    launch(document['Link']);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Container(
                    color: Color.fromRGBO(0, 0, 0, .04),
                      //decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black26)),
                      //padding: EdgeInsets.all(4),
                      margin: EdgeInsets.only(bottom: 4),
                      //height: 40,
                      child: ConstrainedBox(
                        constraints: BoxConstraints.expand(),
                        child: FlatButton(

                            onPressed:  ()  async{
                              bool disable = await UserDocument.instance.hasVoted(document.documentID);
                              if (!disable) {
                                document.reference.updateData({'Votes': document['Votes'] + 1});
                                votedIDs.add(document.documentID);
                              }
                              else{
                                document.reference.updateData({'Votes': document['Votes'] - 1});
                                votedIDs.remove(document.documentID);
                              }
                              UserDocument.instance.addVote(document.documentID);


                            },
                            padding: EdgeInsets.all(0.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(child: Icon(Icons.thumb_up, size: 18,color: votedIDs.indexOf(document.documentID)==-1?Colors.black12:Colors.black,)),
                                Expanded(
                                  //width: 22,
                                  child: Text(document['Votes'].toString()),

                                ),
                              ],
                            )
                        ),
                      )
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                      color: Color.fromRGBO(0, 0, 0, .04),
                      //decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black26)),


                      //height: 40,
                      child: ConstrainedBox(
                        constraints: BoxConstraints.expand(),
                        child: FlatButton(

                            onPressed:  () {
                              document.reference.updateData({'Reports': document['Reports']+1});
                              //setState(() {resources[index].reports++;});
                            },
                            padding: EdgeInsets.all(0.0),
                            child: Text("Report")
                        ),
                      )
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }


}


class BookInfo extends StatefulWidget{
  String isbn;
  String name;
  BookInfo(this.isbn, this.name);

  @override
  BookInfoWindow createState() => BookInfoWindow(this.isbn, this.name);
}