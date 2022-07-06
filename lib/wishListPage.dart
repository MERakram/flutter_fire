import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import 'models/Item.dart';

class wishListPage extends StatefulWidget {
  @override
  _wishListPageState createState() {
    return _wishListPageState();
  }
}

const collection_name = 'wish_list';

class _wishListPageState extends State<wishListPage> {
  List<Item> wishList = [];

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('wish_list')
        .snapshots()
        .listen((records) {
      mapRecords(records);
    });
    fetchRecords();
  }

  fetchRecords() async {
    var records =
        await FirebaseFirestore.instance.collection(collection_name).get();
    mapRecords(records);
  }

  mapRecords(QuerySnapshot<Map<String, dynamic>> records) async {
    var _list = records.docs
        .map(
          (item) => Item(
            id: item.id,
            name: item['name'],
            quantity: item['quantity'],
          ),
        )
        .toList();
    setState(() {
      wishList = _list;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    double height = Get.height;
    double width = Get.width;
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('wishList'),
        actions: [
          IconButton(
            onPressed: () {
              Get.dialog(
                Center(
                  child: Container(
                    height: height * 0.8,
                    child: Dialog(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: quantityController,
                              decoration: InputDecoration(
                                labelText: 'quantity',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextButton(
                              onPressed: () {
                                var name = nameController.text.trim();
                                var quantity = quantityController.text.trim();
                                addItem(name, quantity);
                                Get.back();
                              },
                              child: Container(
                                height: 60,
                                width: 80,
                                color: Colors.green.shade300,
                                child: Center(
                                  child: Text(
                                    'submit',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Center(
        child: wishList.isEmpty
            ? CircularProgressIndicator()
            : ListView.builder(
                itemCount: wishList.length,
                itemBuilder: (context, index) {
                  return Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (c) {
                            deleteItem(wishList[index].id);
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                          spacing: 10,
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(wishList[index].name),
                      subtitle: Text(wishList[index].quantity ?? ''),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection(collection_name)
                              .doc(wishList[index].id)
                              .delete();
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

addItem(name, quantity) {
  // var item = Item(
  //   id: 'id',
  //   name: name,
  //   quantity: quantity,
  // );
  FirebaseFirestore.instance.collection(collection_name).add({
    'name': name,
    'quantity': quantity,
  });
}

deleteItem(id) {
  FirebaseFirestore.instance.collection(collection_name).doc(id).delete();
}
