import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 💡 อย่าลืมรันคำสั่ง flutter pub add intl ใน terminal เพื่อใช้จัดฟอร์แมตเวลา

// 📦 1. สร้างคลาสสำหรับเก็บข้อมูลประวัติ (Transaction Model)
class Transaction {
  final String type; // 'ฝากเงิน' หรือ 'ถอนเงิน'
  final double amount;
  final DateTime dateTime;

  Transaction({
    required this.type,
    required this.amount,
    required this.dateTime,
  });
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double myBalance = 5000.0;
  bool showBalance = true;

  // 💡 2. ตัวแปร State สำหรับเก็บรายการประวัติธุรกรรม
  final List<Transaction> transactions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- โซนการ์ดเงินสด ---
            Card(
              margin: const EdgeInsets.all(16),
              color: Colors.deepPurple,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ยอดเงินคงเหลือ',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          showBalance ? '฿$myBalance' : '฿ * * * *',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        showBalance ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          showBalance = !showBalance;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // --- โซนโปรโมชันพิเศษ ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'โปรโมชันพิเศษ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const ListTile(
              leading: CircleAvatar(child: Text('A')),
              title: Text('ลดทันที 50 บาท'),
              subtitle: Text('เมื่อจ่ายบิลค่าน้ำไฟครั้งแรกของเดือน'),
              trailing: Icon(Icons.favorite_rounded),
              iconColor: Colors.red,
            ),

            const Divider(height: 32, thickness: 1), // เส้นคั่น

            // 💡 3. โซนแสดงประวัติธุรกรรม (Transaction History Zone)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ประวัติรายการ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'ทั้งหมด ${transactions.length} รายการ',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            // เช็กสถานะก่อนว่าถ้ายังไม่มีประวัติ ให้โชว์ข้อความว่างเปล่า
            transactions.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('ยังไม่มีประวัติการทำรายการ', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    shrinkWrap: true, // ⚠️ สำคัญมาก: เพื่อให้รันใน SingleChildScrollView ได้โดยหน้าไม่พัง
                    physics: const NeverScrollableScrollPhysics(), // ปิดการสกรอลล์ซ้อนกัน
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      // ดึงรายการจากหลังสุดมาแสดงก่อน (เอาล่าสุดขึ้นบน)
                      final item = transactions[transactions.length - 1 - index];
                      final isDeposit = item.type == 'ฝากเงิน';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isDeposit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          child: Icon(
                            isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isDeposit ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(item.type, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(DateFormat('dd MMM yyyy - HH:mm').format(item.dateTime)), // แสดงวันเวลาสวยงาม
                        trailing: Text(
                          '${isDeposit ? '+' : '-'} ฿${item.amount}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDeposit ? Colors.green : Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 100), // เว้นพื้นที่ด้านล่างหลบปุ่ม FAB
          ],
        ),
      ),

      // --- ปุ่มกดด้านล่าง ซ้าย-ขวา ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.extended(
              backgroundColor: Colors.green,
              onPressed: _showDepositDialog,
              label: const Text('ฝากเงิน', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            FloatingActionButton.extended(
              backgroundColor: Colors.red,
              onPressed: _showExpenseDialog,
              label: const Text('ถอนเงิน', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  // 🟢 ฟังก์ชันฝากเงิน + บันทึกประวัติ
  void _showDepositDialog() {
    final depositController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Deposit'),
          content: TextField(
            controller: depositController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter deposit amount:'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (depositController.text.isNotEmpty) {
                  final amount = double.parse(depositController.text);
                  setState(() {
                    myBalance = myBalance + amount;
                    // 💡 แอดประวัติเพิ่มเข้าไปใน List
                    transactions.add(Transaction(
                      type: 'ฝากเงิน',
                      amount: amount,
                      dateTime: DateTime.now(),
                    ));
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  // 🔵 ฟังก์ชันถอนเงิน + บันทึกประวัติ
  void _showExpenseDialog() {
    final priceController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Expense'),
          content: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter your expense:'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (priceController.text.isNotEmpty) {
                  final amount = double.parse(priceController.text);
                  setState(() {
                    myBalance = myBalance - amount;
                    // 💡 แอดประวัติเพิ่มเข้าไปใน List
                    transactions.add(Transaction(
                      type: 'ถอนเงิน',
                      amount: amount,
                      dateTime: DateTime.now(),
                    ));
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}