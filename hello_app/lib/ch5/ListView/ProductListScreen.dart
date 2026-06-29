import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // 1. fetch ข้อมูลจาก API (Asynchronous)
  Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('https://fakestoreapi.com/products'),
    );

    if (response.statusCode == 200) {
      // ok, convert Text to Dart's List
      return jsonDecode(response.body);
    } else {
      throw Exception('Can not load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fake Store Products'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),

      // 2. ใช้ FutureBuilder to get data with fetchProducts()
      body: FutureBuilder<List<dynamic>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          // state1: loaddata(Async กำลังทำงาน)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // state2: error (เช่น เน็ตหลุด หรือ API ล่ม)
          else if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }
          // state3: success
          else if (snapshot.hasData) {
            final products = snapshot.data!;

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final item = products[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: Image.network(
                      item['image'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      item['title'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // บังคับให้ข้อความชิดซ้ายทั้งหมด
                      mainAxisSize: MainAxisSize
                          .min, // ให้ขนาดของ Column พอดีกับตัวอักษร ไม่ขยายเกินไป
                      children: [
                        // บรรทัดที่ 1: ราคาเดิมของคุณ
                        Text(
                          '${item['price']} USD',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ), // เพิ่มช่องว่างระหว่างบรรทัดนิดหน่อย
                        // บรรทัดที่ 2: ข้อมูลที่ต้องการเพิ่ม (เช่น รายละเอียด หรือ สต็อกสินค้า)
                        Text(
                          item['category'] ?? 'ไม่มีรายละเอียดสินค้า',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ), // ใส่ไอคอนดาวสีทองสวย ๆ
                            const SizedBox(width: 4),
                            Text(
                              // 💡 ดึงค่า rate และ count จากชั้นในสุด
                              '${item['rating']['rate']} (${item['rating']['count']} รีวิว)',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // ...navigation
                    },
                  ),
                );
              },
            );
          }

          return const Center(child: Text('no data'));
        },
      ),
    );
  }
}
