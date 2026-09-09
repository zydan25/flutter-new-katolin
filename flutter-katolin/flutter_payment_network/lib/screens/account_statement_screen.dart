import 'package:flutter/material.dart';

class AccountStatementScreen extends StatefulWidget {
  final String customerName;
  final String apiToken;
  final String baseUrl;

  const AccountStatementScreen({
    Key? key,
    this.customerName = 'زيدان محمد عبدالله علي العطاب',
    required this.apiToken,
    required this.baseUrl,
  }) : super(key: key);

  @override
  State<AccountStatementScreen> createState() => _AccountStatementScreenState();
}

class _AccountStatementScreenState extends State<AccountStatementScreen> {
  DateTime _startDate = DateTime(2026, 9, 6);
  DateTime _endDate = DateTime(2026, 9, 9);

  // Rows matching Screenshot 7 (تاريخ | البيان | عليه | له | الرصيد)
  final List<Map<String, dynamic>> _statementRows = [
    {
      'date': '19:55:56 2026-09-09',
      'statement': 'تسديد باقة سبأفون يابلاش 711751569',
      'debit': 1210.0,
      'credit': 0.0,
      'balance': 99033.43,
    },
    {
      'date': '18:30:45 2026-09-09',
      'statement': 'تسديد رصيد يمن موبايل 774952665',
      'debit': 500.0,
      'credit': 0.0,
      'balance': 100243.43,
    },
    {
      'date': '14:20:10 2026-09-09',
      'statement': 'تغذية حساب بواسطة حوالة كاش',
      'debit': 0.0,
      'credit': 50000.0,
      'balance': 100743.43,
    },
    {
      'date': '11:15:30 2026-09-08',
      'statement': 'شراء كروت واي فاي شبكة زين نت (3 كروت)',
      'debit': 810.0,
      'credit': 0.0,
      'balance': 50743.43,
    },
    {
      'date': '09:00:15 2026-09-07',
      'statement': 'عمولة تسديدات أسبوعية',
      'debit': 0.0,
      'credit': 1553.43,
      'balance': 51553.43,
    },
    {
      'date': '20:10:00 2026-09-06',
      'statement': 'رصيد افتتاحي سابق',
      'debit': 0.0,
      'credit': 50000.0,
      'balance': 50000.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F2F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFC62828),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'كشف حساب : ${widget.customerName}',
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تصدير كشف الحساب بصيغة PDF بنجاح', style: TextStyle(fontFamily: 'Cairo'))),
                );
              },
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 18),
              label: const Text('PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: Column(
          children: [
            // Date Filter Row (Matches Screenshot 7)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Color(0xFFC62828)),
                          const SizedBox(width: 4),
                          Text('من: ${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Color(0xFFC62828)),
                          const SizedBox(width: 4),
                          Text('إلى: ${_endDate.year}-${_endDate.month.toString().padLeft(2, '0')}-${_endDate.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم تحديث كشف الحساب حسب الفترة المحددة', style: TextStyle(fontFamily: 'Cairo'))),
                      );
                    },
                    child: const Text('عرض', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // Table Header (Matches Screenshot 7)
            Container(
              color: const Color(0xFFCFD8DC),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Row(
                children: const [
                  Expanded(flex: 3, child: Text('البيان', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12))),
                  Expanded(flex: 2, child: Text('عليه', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFC62828)))),
                  Expanded(flex: 2, child: Text('له', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2E7D32)))),
                  Expanded(flex: 2, child: Text('الرصيد', textAlign: TextAlign.left, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12))),
                ],
              ),
            ),

            // Table Body
            Expanded(
              child: ListView.builder(
                itemCount: _statementRows.length,
                itemBuilder: (ctx, i) {
                  final row = _statementRows[i];
                  final isEven = i % 2 == 0;
                  return Container(
                    color: isEven ? Colors.white : const Color(0xFFF9FAFB),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                row['statement'],
                                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                row['debit'] > 0 ? '${row['debit']}' : '-',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 11, color: row['debit'] > 0 ? const Color(0xFFC62828) : Colors.grey),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                row['credit'] > 0 ? '${row['credit']}' : '-',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 11, color: row['credit'] > 0 ? const Color(0xFF2E7D32) : Colors.grey),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${row['balance']}',
                                textAlign: TextAlign.left,
                                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0D47A1)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          row['date'],
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Summary Card
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('الرصيد النهائي الحالي:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('99,033.43 ر.ي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2E7D32))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
