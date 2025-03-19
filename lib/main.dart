import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/firebase_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final FireBaseController firebaseController = Get.put(FireBaseController());

  @override
  Widget build(BuildContext context) {
    TextEditingController productNameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: Colors.grey.shade100,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Product List",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87, // สีข้อความที่เข้มขึ้นแบบมินิมอล
            ),
          ),
          backgroundColor: Colors.teal.shade100, // สีพื้นหลังเรียบง่าย
          elevation: 0, // ไม่มีเงาสำหรับลุคที่เรียบง่าย
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firebaseController.GetProductList(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List productList = snapshot.data!.docs;
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: productList.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = productList[index];
                        String docID = document.id; // For update/delete
                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          elevation: 0, // ไม่มีเงาเพื่อสไตล์มินิมอล
                          color: Colors.white,
                          child: ListTile(
                            title: Text(
                              "${data['productname']}",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              "Price: ${data['price']} Baht\n${data['description']}",
                              style: TextStyle(color: Colors.blueGrey),
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                productNameController.text = data['productname'];
                                descriptionController.text = data['description'];
                                priceController.text = data['price'].toString();
                                Get.defaultDialog(
                                  title: "Edit Data",
                                  backgroundColor: Colors.white,
                                  content: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                          controller: productNameController,
                                          decoration: InputDecoration(
                                            labelText: "Product Name",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                          controller: descriptionController,
                                          decoration: InputDecoration(
                                            labelText: "Description",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                          controller: priceController,
                                          decoration: InputDecoration(
                                            labelText: "Price",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        width: double.infinity,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                firebaseController.updateProduct(
                                                  docID,
                                                  productNameController.text,
                                                  descriptionController.text,
                                                  double.parse(priceController.text),
                                                );
                                                productNameController.clear();
                                                descriptionController.clear();
                                                priceController.clear();
                                                Get.back();
                                              },
                                              child: Text("Edit"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.teal.shade100,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12.0),
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                firebaseController.deleteProduct(docID);
                                                Get.back();
                                              },
                                              child: Text("Delete"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red.shade100,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12.0),
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Get.back();
                                              },
                                              child: Text("Close"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.grey.shade200,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12.0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: Icon(Icons.edit, color: Colors.teal),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text(
                        "No data available",
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal, // สีสดใสและสะอาดตา
          onPressed: () {
            Get.defaultDialog(
              title: "Add Product",
              backgroundColor: Colors.white, // สีขาวเรียบง่าย
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: productNameController,
                      decoration: InputDecoration(
                        labelText: "Product Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: "Price",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        firebaseController.addProduct(
                          productNameController.text,
                          descriptionController.text,
                          double.parse(priceController.text),
                        );
                        productNameController.clear();
                        descriptionController.clear();
                        priceController.clear();
                        Get.back();
                      },
                      child: Text("Add Product"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
