import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:textbook_app/AddBookLink.dart';
import 'package:url_launcher/url_launcher.dart';

class Resource{
  String description;
  String link;
  int reports;
  int votes;

  Resource(this.description, this.link, this.reports, this.votes);


  Widget _widget(){
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(description,
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.bold),
            textScaleFactor: 1.1,),
          Container(
            height: 3,
          ),
          Text(
              link,
              textAlign: TextAlign.left
          ),
          Container(
            height: 2,
          ),
        ],
      ),
    );
  }

}

class BookInfoWindow extends State {

  String isbn;
  String name;
  List<Resource> resources;
  BookInfoWindow(this.isbn, this.name);

  @override
  void initState() {
    super.initState();
    resources = new List<Resource>();
    print("init");
    print(isbn);
    getLinks();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(name),
        ),
        body: buildPage(context));
  }

  Widget buildPage(BuildContext c){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        buildInfo(),
        buildAddButton(c),
        buildLinks()
      ],
    );
  }

  Widget buildInfo(){
    print("BUILDINFO");
    return Container(
      color: Color.fromRGBO(180, 180, 180, 1),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(name,
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.bold),
            textScaleFactor: 1.5,),
          Container(
            height: 18,
          ),
          Text(
              isbn,
              textAlign: TextAlign.left
          ),
          Container(
            height: 4,
          ),
        ],
      ),
    );
  }

  Widget buildAddButton(BuildContext context){
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


  Widget buildLinks(){
    return Expanded(
      child: ListView.builder(
        itemCount: resources.length,
        shrinkWrap: true,

        itemBuilder: (context, index) {
          return Container(
            child: ListTile(
              title: resources[index]._widget(),
              trailing: IconButton(
                icon: Icon(Icons.thumb_up),
                onPressed: (){
                  Firestore.instance.collection("books").where("ISBN", isEqualTo: isbn).getDocuments().then((doc){
                    if (doc.documents.isNotEmpty)
                      doc.documents.elementAt(0).reference.collection("Resources")
                          .where("Description", isEqualTo: resources[index].description)
                          .where("Link", isEqualTo: resources[index].link).getDocuments().then((d){
                            d.documents.forEach((v){
                              v.reference.setData({
                                "Votes":v.data['Votes']+1,
                              "Description":v.data['Description'],
                                "Reports":v.data['Reports'],
                                "Link":v.data['Link']});
                            });
                      });
                  });

                },
              ),
              onTap: () async {
                await launch(resources[index].link);
              },
            ),
          );
        },
      ),
    );
  }
  
  void getLinks(){
    print("GET LINKS");
    resources.clear();
    Firestore.instance.collection("books").where("ISBN", isEqualTo: isbn).getDocuments().then((doc){
      doc.documents.elementAt(0).reference.collection("Resources").getDocuments().then((res){
        print("!!!!!!!!!!!!!!!!!!!!!!!!");
        res.documents.forEach((d){
          print(d.data.toString());
          resources.add(new Resource(d.data["Description"], d.data["Link"], d.data["Reports"], d.data["Votes"]));
        }
        );
        setState((){

        });
      });
    });
  }


}


class BookInfo extends StatefulWidget{
  String isbn;
  String name;
  BookInfo(this.isbn, this.name);

  @override
  BookInfoWindow createState() => BookInfoWindow(this.isbn, this.name);
}