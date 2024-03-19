import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EditProduct extends StatefulWidget {
  final int productId;

  const EditProduct({super.key, required this.productId});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _editFormKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _price = TextEditingController();

  String? userToken;

  @override
  void initState() {
    super.initState();
    getUserToken();
    getProductById(widget.productId);
  }

  Future<void> getUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userToken = prefs.getString('userToken');
    });
  }

  Future<void> getProductById(int productId) async {
    // Check if data is already loaded
    if (_name.text.isNotEmpty) {
      return;
    }

    print(productId);
    var url = Uri.parse(
        'https://642021153.pungpingcoding.online/api/product/$productId');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userToken = prefs.getString('userToken');

      var response = await http.get(url, headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $userToken',
      });

      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Extract product details from the payload
        Map<String, dynamic> payload = jsonResponse['payload'];
        String productName = payload['product_name'];
        double price = payload['price'].toDouble();
        
        // Update the UI with the retrieved data
        setState(() {
          _name.text = productName;
          _price.text = price.toString();
        });
      } else if (response.statusCode == 429) {
        // Handle rate-limiting by adding a delay and retrying
        await Future.delayed(
            const Duration(seconds: 5)); // Adjust the delay as needed
        getProductById(productId); // Retry the request
      } else {
        // Handle other status codes
        print('Failed to load products: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูลสินค้า'),
      ),
      body: Form(
        key: _editFormKey,
        child: mainInput(),
      ),
    );
  }

  Widget mainInput() {
    return FutureBuilder(
        future: getProductById(widget.productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('อยู่ระหว่างประมวลผล'),
                  )
                ],
              ),
            );
          } else {
            return ListView(
              children: [
                inputName(),
                inputPrice(),
                // dropdownType(),
                updateButton(),
              ],
            );
          }
        });
  }

  Container inputPrice() {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(left: 32, right: 32, top: 8, bottom: 8),
      child: TextFormField(
        controller: _price,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณากรอกราคาสินค้า!!';
          }
          return null;
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          prefixIcon: Icon(
            Icons.sell,
            color: Colors.blue,
          ),
          label: Text(
            'ราคา',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ),
    );
  }

  Container inputName() {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(left: 32, right: 32, top: 32, bottom: 8),
      child: TextFormField(
        controller: _name,
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณากรอกชื่อสินค้า!!';
          }
          return null;
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          prefixIcon: Icon(
            Icons.emoji_objects,
            color: Colors.blue,
          ),
          label: Text(
            'ชื่อสินค้า',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ),
    );
  }

  Widget updateButton() {
    return Container(
      width: 150,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
        onPressed: () async {
          if (_editFormKey.currentState!.validate()) {
              updateProduct();
          } else {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              text: 'กรุณากรอกข้อมูลให้ครบถ้วน!!',
              confirmBtnText: 'ตกลง',
              showConfirmBtn: true,
            );
          }
        },
        child: const Text('บันทึกข้อมูล'),
      ),
    );
  }

  Future<void> updateProduct() async {
    print("------------------------------------");
    print("Update Success");
    print("product_name: ${_name.text}");
    print("price: ${double.parse(_price.text)}");
    print("userToken: $userToken");
    print("-----------------------------------");

    final id = widget.productId;
    // Check if the form is valid
    if (_editFormKey.currentState!.validate()) {
      try {
        // Get the user token from SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userToken = prefs.getString('userToken');

        // Convert values to JSON
        Map<String, dynamic> productData = {
          'pd_name': _name.text,
          'pd_price': double.parse(_price.text),
        };

        // Define the Laravel API endpoint for updating a product
        var url =
            Uri.parse('https://642021153.pungpingcoding.online/api/product/$id');

        // Request for updating the product
        var response = await http.put(
          url,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'Bearer $userToken',
          },
          body: jsonEncode(productData),
        );

        // Check the status code
        if (response.statusCode == 200) {
          // Navigate to the DashboardScreen
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'อัพเดทข้อมูลสำเร็จ!',
            confirmBtnText: 'ตกลง',
            showConfirmBtn: false,
            autoCloseDuration: const Duration(seconds: 3),
          ).then((value) async {
            // Close the modal
            Navigator.of(context).pop();
          });
        } else if (response.statusCode == 429) {
          // Handle rate-limiting by adding a delay and retrying
          await Future.delayed(const Duration(seconds: 5));
          updateProduct(); // Retry the request
        } else {
          // Handle other status codes
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'ไม่สามารถอัพเดทข้อมูลได้ กรุณาลองใหม่!',
            confirmBtnText: 'ตกลง',
            showConfirmBtn: false,
          );
          print('Failed to update product: ${response.statusCode}');
        }
      } catch (error) {
        print('Error updating product: $error');
      }
    }
  }
}
