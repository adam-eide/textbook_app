import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:textbook_app/AddBookForm.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:textbook_app/BookInfoWindow.dart';

import 'package:url_launcher/url_launcher.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firestore Test',
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
      ),
      home: MyHomePage(title: 'Flutter Firestore Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class BookCover{
  String title;
  String isbn;
  BookCover(String title, String isbn, String info){

    this.title = (((title == null) ? ("") : (title)));
    this.isbn = (((isbn == null) ? ("") : (isbn)));
    // INFO is there in case we need it later for image or edition or class
  }

  String formatISBNs(String s){
    String out = "";
    if(s.length.toInt() == 13){
      for (int i = 0; i < 13; i++) {
        out += s[i];
        if (i == 2 || i == 3 || i == 5 || i == 11)
          out += "-";
      }
    }

    print(out);
    return out;
  }
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
          Text(title,
          textAlign: TextAlign.left,
          style: TextStyle(fontWeight: FontWeight.bold),
        textScaleFactor: 1.3,),
          Container(
            height: 3,
          ),
          Text(
              ((isbn.length == 0)?("does not exist yet\nclick here to add book"):(formatISBNs(isbn))),
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

enum SearchBy{
  isbn, name
}

class _MyHomePageState extends State<MyHomePage> {

  TextEditingController _controller;
  List<BookCover> books;
  SearchBy searchBy;
  List<String> searchForLabel;

  void initState() {
    super.initState();
    searchForLabel = new List<String>();
    searchForLabel.add("ISBN");
    searchForLabel.add("Name");
    searchBy = SearchBy.isbn;
    books = new List<BookCover>();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 18,
                  color: Colors.white,
                ),
              /*Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(left: 8, right: 8),
                height: 2,
                color: Colors.black,
              ),*/
              Container(
                height: 60,//MediaQuery.of(context).size.height / 15,
                margin: EdgeInsets.only(left: 8, right: 8),
                color: Color.fromRGBO(220, 220, 220, 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      flex: 9,
                      child: Container(
                        //color: Colors.white,
                        padding: EdgeInsets.all(6),
                        child: Container(
                          //color: Colors.black12,
                          /*decoration: BoxDecoration(
                            //borderRadius: BorderRadius.circular(15.0),
                            //color: Colors.white70,
                            border: Border.all(
                                color: Colors.black26, style: BorderStyle.solid, width: 1),
                          ),*/
                          padding: EdgeInsets.only(left: 6),
                          child: DropdownButton<SearchBy>(

                            value: searchBy,
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 16,
                            style: TextStyle(
                                color: Colors.black,
                              fontSize:16,
                            ),
                            underline: Container(
                              height: 2,
                              color: Colors.black12,
                            ),

                            onChanged: (SearchBy newValue) {
                              setState(() {
                                searchBy = newValue;
                              });
                            },
                            items: <SearchBy>[SearchBy.isbn, SearchBy.name]
                                .map<DropdownMenuItem<SearchBy>>((SearchBy value) {
                              return DropdownMenuItem<SearchBy>(
                                value: value,
                                child: Text(((value == SearchBy.isbn)?("ISBN"):("Title"))),
                              );
                            }).toList(),
                          ),


                        ),
                      ),
                    ),
                    Expanded(
                      flex: 24,
                      
                        child: TextField(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 6),
                              isDense: false,
                              filled: false,

                              fillColor: Colors.black12,
                              hintText: ((searchBy == SearchBy.isbn)?("Enter the ISBN 13"):("Enter the title")),
                              //contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                              //focusedBorder: OutlineInputBorder(
                              //  borderSide: BorderSide(color: Colors.white),
                              //  borderRadius: BorderRadius.circular(25.7),
                              //),
                              border: InputBorder.none,
                              //contentPadding: EdgeInsets.zero
                            ),
                          autofocus: false,
                          minLines: 1,
                          maxLines: 1,
                          controller: _controller,
                          onSubmitted: (String value)  {
                            books.clear();
                             getBooks(value);
                            //BarcodeScanner.scan().then((value){
                              //print("BARCODE");
                              //print(value);
                            //});
                          },
                        ),

                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      flex: 6,
                          child: Container(

                            //color: Colors.black12,
                            padding: EdgeInsets.all(4),

                            child: ConstrainedBox(
                            constraints: BoxConstraints.expand(),
                            child: FlatButton(

                                onPressed:  () {

                                  BarcodeScanner.scan().then((value){
                                    setState(() {
                                      searchBy = SearchBy.isbn;
                                    });
                                    _controller.text = value;
                                    books.clear();
                                    getBooks(value);
                                  });

                                },
                                padding: EdgeInsets.all(0.0),
                                child: Image(image: AssetImage('assets/scan.png'))
                            )
                            ),
                          )
                   ),
                  ],
                ),
              ),
              /*Container(
                width: MediaQuery.of(context).size.width,
                height: 2,
                margin: EdgeInsets.only(left: 8, right: 8),
                color: Colors.black,
              ),*/
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 38,
                color: Colors.white,
              ),

              bookList(),
            ],
          ),


      );

  }

  Widget bookList(){
    return ListView.builder(
      itemCount: books.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Container(

          child: ListTile(
            title: books[index]._widget(),
            onTap: () async{
              if (books[index].isbn.length == 0){
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AddBook("", books[index].title);
                }));
              }
              else{
                print("MAP.isbn");
                print(books[index].isbn);
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return BookInfo(books[index].isbn, books[index].title);
                }));
              }
          },
          ),
        );
      },
    );
  }

  void getBooks(String input){

    String title;
    print("STARTING");

    print(searchForLabel[searchBy.index]);
    if (searchBy == SearchBy.isbn) input = input.replaceAll('-', '');
    Firestore.instance.collection('books')
    // this searches for name if searchBy=name and isbn if it = isbn
        .where(searchForLabel[searchBy.index], isEqualTo: input.toUpperCase()).getDocuments().then(
            (snap){
              Map<String, dynamic> map;
              if (snap.documents.isEmpty ){
                print("documents = empty");
                if (searchBy == SearchBy.isbn) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return AddBook(input, "");
                  }));
                }
                if (searchBy == SearchBy.name) {
                  books.add(new BookCover(input, "", ""));
                }
              }
              else {
                print("documents != empty");
                snap.documents.forEach((d){
                  map = d.data;
                  books.add(new BookCover(map['Name'], map['ISBN'], ""));
                });
              }



          setState((){


          });
  }
  );
    /*Firestore.instance.collection('books').where('ISBN', arrayContainsAny: [input, input.replaceAll('-', '')]).snapshots()
        .listen((data) =>
        data.documents.forEach((doc) => books.add(new BookCover(doc['Title'], formatISBNs(doc['ISBN']), ""))));*/

print("LEAVING");
  }




}
