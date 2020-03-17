import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDocument {




  // make this a singleton class
  UserDocument._privateConstructor();
  static final UserDocument instance = UserDocument._privateConstructor();
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  static DocumentReference _userDocument;
  static int count;

  factory UserDocument(){return instance;}

  Future<DocumentReference> get document async {
    print("Getting document");
    if (_userDocument != null) return _userDocument;
    // lazily instantiate the db the first time it is accessed
    _userDocument = await _initDocument();
    return _userDocument;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDocument() async {

    print("INITDOC");
    AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;
    //.then((value) {
      String id = info.androidId;
      print("ID  " + id);
      var v = await Firestore.instance.collection('users').document(id).updateData({'works':true});
          //.whenComplete(() => _userDocument = Firestore.instance.collection('users').document(id));
    count = ((await Firestore.instance.collection('users').document(id).get())).data['c'];
    DocumentReference dr = await Firestore.instance.collection('users').document(id);
    return dr;
  }

  Future<List<String>> getFavorites() async{
    DocumentReference dr = await instance.document;
    QuerySnapshot qs = await dr.collection('favorites').getDocuments();
    List<String> list = new List();
    qs.documents.forEach((element) { list.add(element.data['ISBN']); });
    return list;
  }

  Future<void> setFavorite(String isbn) async {
    DocumentReference dr = await instance.document;
    QuerySnapshot qs = await dr.collection('favorites').where('ISBN', isEqualTo: isbn).getDocuments();
    if (qs.documents.isEmpty)
      var v = await dr.collection('favorites').document().setData({'ISBN': isbn});
    else
      var v = await dr.collection('favorites').document(qs.documents.first.documentID).delete();
  }

  Future<List<String>> getVotes() async{
    DocumentReference dr = await instance.document;
    QuerySnapshot qs = await dr.collection('votes').getDocuments();
    List<String> list = new List();
    qs.documents.forEach((element) { list.add(element.data['ID']); });
    return list;
  }
  Future<bool> hasVoted(String id) async{
    DocumentReference dr = await instance.document;
    QuerySnapshot qs = await dr.collection('votes').where('ID', isEqualTo: id).getDocuments();
    if (qs.documents.isEmpty)
      return false;
    else
      return true;
  }

  Future<void> addVote(String id) async{
    DocumentReference dr = await instance.document;
    QuerySnapshot qs = await dr.collection('votes').where('ID', isEqualTo: id).getDocuments();
    if (qs.documents.isEmpty)
      var v = await dr.collection('votes').document().setData({'ID': id});
    else
      var v = await dr.collection('votes').document(qs.documents[0].documentID).delete();

  }



}

