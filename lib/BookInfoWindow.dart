import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:textbook_app/AddBookLink.dart';
import 'package:url_launcher/url_launcher.dart';

class Resource {
  String description;
  String link;
  int reports;
  int votes;

QuerySnapshot q;
  Resource(this.description, this.link, this.reports, this.votes, this.q);
  String toString(){
    return description + "\n" + link + "\n" +reports.toString() + "\n" +votes.toString() + "\n";
  }

}

class BookInfoWindow extends State {

  String isbn;
  String name;
  List<Resource> resources;
  BookInfoWindow(this.isbn, this.name);
  bool ready;


  @override
  void initState() {
    super.initState();
    ready = false;
    resources = new List<Resource>();
    print(resources.length.toString() + "           Length");
    print(isbn);
    getLinks().whenComplete(()=>this.setState((){}));

    print("init");

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
            flex: 1,
            child: IconButton(
                icon: Icon(Icons.refresh),
                onPressed: (){
                  getLinks();
                  setState(() {

                });}
            ),
          ),
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
      child: ListView.builder(
        itemCount: resources.length,
        shrinkWrap: true,

        itemBuilder: (context, index) {

          return Container(
            child: ListTile(
              title: _buildWidget(index),

            ),
          );
        },
      ),
    );
  }
  
  Future<void> getLinks() async {
    print("GET LINKS");

    resources.clear();

    print("GET LINKSa");
    CollectionReference collectionReference =  (await Firestore.instance.collection("books").where("ISBN", isEqualTo: isbn).getDocuments()).documents.elementAt(0).reference.collection("Resources");
    print("GET LINKSb");
    List<DocumentSnapshot> docs = (await collectionReference.getDocuments()).documents;
    print("GETLINKS1");
    for(int i = 0; i < docs.length; i++) {
      resources.add(new Resource(
          docs[i].data["Description"],
          docs[i].data["Link"],
          docs[i].data["Reports"],
          docs[i].data["Votes"],
          (await  collectionReference
              .where("Description", isEqualTo: docs[i].data["Description"])
              .where("Link", isEqualTo: docs[i].data["Link"])
              .getDocuments()
          )
      ));
      print("GETLINKS2             " + resources.length.toString());
    }

    setState(() {
      ready = true;
    });

    print("GETLINKS3");

  }

   _buildWidget(int index){
    print("BUILDWIDG");
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        //color: Colors.grey,
          border: Border(
              bottom: BorderSide(
                  color: Colors.black,
                  width: 1)
          )
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 26,
            child: Container(
              height: 60,
              child: ConstrainedBox(
                constraints: BoxConstraints.expand(),
                child: FlatButton(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(resources[index].description,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        textScaleFactor: 1.3,),
                      Container(
                        height: 3,
                      ),
                      Text(
                        ((resources[index].link.length > 45)?(resources[index].link.substring(0, 40)+"..."):(resources[index].link)),
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
                    launch(resources[index].link);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              //color: Colors.black12,
                decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black26)),
                //padding: EdgeInsets.all(4),
                height: 40,
                child: ConstrainedBox(
                  constraints: BoxConstraints.expand(),
                  child: FlatButton(

                      onPressed:  ()  {
                        resources[index].q.documents.first.reference.updateData({'Votes':resources[index].votes+1});
                        setState(() {
                          resources[index].votes++;


                        });


                      },
                      padding: EdgeInsets.all(0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(child: Icon(Icons.thumb_up, size: 18,)),
                          Expanded(
                            //width: 22,
                            child: Text(resources[index].votes.toString()),
                            /*child: TextField(

                              decoration: InputDecoration(
                                  filled: false,
                                  contentPadding: EdgeInsets.only(bottom: 6),
                                  border: InputBorder.none,
                                  isDense: false
                              ),
                              controller: score[index],
                              readOnly: true,
                            ),*/
                          ),
                        ],
                      )
                  ),
                )
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Expanded(
            flex: 5,
            child: Container(
              //color: Colors.black12,
                decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black26)),
                //padding: EdgeInsets.all(4),
                height: 40,
                child: ConstrainedBox(
                  constraints: BoxConstraints.expand(),
                  child: FlatButton(

                      onPressed:  () {
                        resources[index].q.documents.first.reference.updateData({'Reports':resources[index].reports+1});
                        setState(() {
                          resources[index].reports++;
                        });
                      },
                      padding: EdgeInsets.all(0.0),
                      child: Text("Report")
                  ),
                )
            ),
          )
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