import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
            isbn,
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

class _MyHomePageState extends State<MyHomePage> {

  TextEditingController _controller;
  List<BookCover> books;


  void initState() {
    super.initState();
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
                  height: MediaQuery.of(context).size.height / 38,
                  color: Colors.grey,
                ),

              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(

                        color: Colors.grey,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: TextField(
                        autofocus: true,
                        minLines: 1,
                        maxLines: 1,
                        controller: _controller,
                        onSubmitted: (String value)  {
                          books.clear();
                           getBooks(value);
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(

                        color: Colors.grey,
                      ),
                   ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 38,
                color: Colors.grey,
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
              //print(await FlutterBarcodeScanner.scanBarcode('#FFFF0F', "done", false, ScanMode.BARCODE));
              print(books[index].title);
            //Navigator.of(context).pop();
          },
          ),
        );
      },
    );
  }

  void getBooks(String input){

    String title;
    List<String> isbns;
    print("STARTING");
    Firestore.instance.collection('books')
        .where('ISBN', arrayContainsAny: [input, input.replaceAll('-', '')]).getDocuments().then(
            (snap){
              Map<String, dynamic> map = snap.documents.elementAt(0).data;
              print(map.toString());
            if (snap.documents.length > 1)
              print("MULTIPLE BOOKS WERE FOUND, RESULTS ARE NOT BEING DISPLAYED");
            if (map.containsKey("Name")){
              title = map['Name'];
            }
            if (map.containsKey("ISBN")){
                String s = map['ISBN'].toString();
                s = s.substring(1, s.length-1);
                isbns = s.split(", ");
            }

          books.add(new BookCover(title, formatISBNs(isbns), ""));
          setState((){});
          print("dont w slow part");
          print(books[0].title + books[0].isbn);
  } );
    /*Firestore.instance.collection('books').where('ISBN', arrayContainsAny: [input, input.replaceAll('-', '')]).snapshots()
        .listen((data) =>
        data.documents.forEach((doc) => books.add(new BookCover(doc['Title'], formatISBNs(doc['ISBN']), ""))));*/

print("LEAVING");
  }

  String formatISBNs(List<String> list){
    if (list == null) return "";
    String out = "";
    list = list.toSet().toList();
    list.sort((a,b){return (a.length - b.length);});
    //list.forEach((l){out += l; out += "\n";});
    
    list.forEach((l){
      print(l.length);print( "         length");
      if(l.length.toInt() == 10){
      for (int i = 0; i < 10; i++) {
        out += l[i];
        if (i == 0 || i == 3 || i == 8)
          out += "-";
      }
      out += "\n";
    }
      else if(l.length.toInt() == 13){
        for (int i = 0; i < 13; i++) {
          out += l[i];
          if (i == 2 || i == 3 || i == 5 || i == 11)
            out += "-";
        }
      }

    }
    );
    print(out);
    return out;
  }


}
