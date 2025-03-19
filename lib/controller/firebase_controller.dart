import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FireBaseController extends GetxController {
  // Add data to Firebase
  final CollectionReference product = FirebaseFirestore.instance.collection('product');

  String? get docID => null;
  Stream<QuerySnapshot> GetProductList() {
    final product_snapshot = FirebaseFirestore.instance.collection('product').orderBy('time', descending: true).snapshots();
    return product_snapshot;
  }
  //update
  Future<void> addProduct(String productname, String description, double price) {
    return product.add({
      'productname': productname,
      'description': description,
      'price': price,
      'time': Timestamp.now(),
    });
  }// Update product
  Future<void> updateProduct(String docID, String editProductName, String editDescription, double editPrice) {
    return product.doc(docID).update({
      'productname': editProductName,
      'description': editDescription,
      'price': editPrice,
      'time': Timestamp.now(),
    });
  }

// Delete product
  Future<void> deleteProduct(String docID) {
    return product.doc(docID).delete();
  }

}

