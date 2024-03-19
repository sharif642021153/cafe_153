import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crud_153/page/model/product_type.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  String? userToken;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  List<ListProductType> dropdownItems = ListProductType.getListProductType();
  late List<DropdownMenuItem<ListProductType>> dropdownMenuItems;
  int? selectedProductType;

  @override
  void initState() {
    super.initState();
    getUserToken();
  }

  Future<void> getUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userToken = prefs.getString('userToken');
    });
  }

  @override
  void dispose() {
    productNameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> addProduct() async {
    final productName = productNameController.text;
    final productType = selectedProductType;
    double? price = double.tryParse(priceController.text);

    print("------------------------------------");
    print("product_name: $productName");
    print("product_type: $productType");
    print("price: $price");
    print("userToken: $userToken");
    print("-----------------------------------");

    http.Response? response;

    try {
      response = await http.post(
        Uri.parse('https://642021153.pungpingcoding.online/api/product'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          "pd_name": productName,
          "pd_type": productType,
          "pd_price": price,
        }),
      );

      if (response.statusCode == 200) {
        print("เพิ่มข้อมูลสินค้าสำเร็จ");
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'เพิ่มข้อมูลสำเร็จ!',
          confirmBtnText: 'ตกลง',
          showConfirmBtn: false,
          autoCloseDuration: const Duration(seconds: 3),
        ).then((value) {
          Navigator.of(context).pop();
        });
      } else {
        final responseData = json.decode(response.body);
        print(response.statusCode);
        print(responseData['message'] ??
            'ไม่สามารถเพิ่มข้อมูลสินค้าได้ กรุณาลองใหม่');
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'ไม่สามารถเพิ่มข้อมูลได้ กรุณาลองใหม่!',
          confirmBtnText: 'ตกลง',
          showConfirmBtn: true,
        );
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'กรุณากรอกข้อมูลให้ถูกต้อง!!',
        confirmBtnText: 'ตกลง',
        showConfirmBtn: true,
      );
    } finally {
      if (response != null) {
        print('HTTP status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มข้อมูลสินค้า'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: productNameController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  icon: Icon(Icons.coffee_rounded),
                  labelText: 'ชื่อสินค้า',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกชื่อสินค้า';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  icon: Icon(Icons.monetization_on_outlined),
                  labelText: 'ราคา',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกราคา';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<int>(
                value: selectedProductType,
                items: ListProductType.getListProductType()
                    .map((productType) {
                  return DropdownMenuItem<int>(
                    value: productType.value,
                    child: Text(productType.name!),
                  );
                }).toList(),
                onChanged: (int? value) {
                  setState(() {
                    selectedProductType = value;
                  });
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.menu_open_rounded),
                  labelText: 'ประเภทสินค้า',
                ),
                validator: (value) {
                  if (value == null) {
                    return 'กรุณาเลือกประเภทสินค้า';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text(
                      'ยกเลิก',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 196, 63, 63),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await addProduct();
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: const Text(
                      'บันทึก',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 77, 196, 81),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}