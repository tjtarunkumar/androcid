import 'dart:convert';

import 'package:androcid/models/personmodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ViewScreen extends StatefulWidget {
  const ViewScreen({Key? key}) : super(key: key);

  @override
  _ViewScreenState createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  List<Person> dataList = [];
  bool isLoading = false;
  int _pageno = 1;
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();

    ////LOADING FIRST  DATA
    addItemIntoLisT(_pageno);

    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);
  }

  //// ADDING THE SCROLL LISTINER
  _scrollListener() {
    if (_scrollController!.offset >=
            _scrollController!.position.maxScrollExtent &&
        !_scrollController!.position.outOfRange) {
      setState(() {
        isLoading = true;

        if (isLoading) {
          _pageno = _pageno + 1;
          addItemIntoLisT(_pageno);
        }
      });
    }
  }

  ////ADDING DATA INTO ARRAYLIST
  void addItemIntoLisT(var pageCount) async {
    final List<dynamic> _response = await _loaddata();
    if (_response.length > 0) {
      for (int _i = 0; _i < _response.length; _i++) {
        dataList.add(Person(
            name: _response[_i]['name'],
            mobile: _response[_i]['mobile'],
            img: _response[_i]['img']));
        isLoading = false;
      }
      setState(() {});
    }
  }

  Future<dynamic> _loaddata() async {
    var url = Uri.parse(
        'https://gnutechnocrats.com/androcid/index.php?pageno=$_pageno');
    final http.Response _response = await http.get(url);
    return json.decode(_response.body);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      controller: _scrollController,
      scrollDirection: Axis.vertical,
      crossAxisCount: 2,
      padding: EdgeInsets.only(top: 10),
      mainAxisSpacing: 10.0,
      physics: const AlwaysScrollableScrollPhysics(),
      children: dataList.map((value) {
        return Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height * 0.2,
          margin: EdgeInsets.only(left: 10.0, right: 10.0),
          decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: MemoryImage(base64Decode(
                  value.img,
                ))),
            border: Border.all(color: Colors.black),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                color: Colors.white,
                child: Text(
                  value.name,
                  style: TextStyle(fontSize: 19),
                ),
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: Text(value.mobile, style: TextStyle(fontSize: 19))),
            ],
          ),
        );
      }).toList(),
    );
  }
}
