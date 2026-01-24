import 'package:flutter/material.dart';
import '../model/payslip_model.dart';

class PayslipTile extends StatelessWidget {
  final PayslipModel payslip;
  final VoidCallback onDownload;

  const PayslipTile({
    super.key,
    required this.payslip,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        title: Text(payslip.monthName),
        subtitle: Text("₹ ${payslip.amount} • ${payslip.status}"),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: onDownload,
        ),
      ),
    );
  }
}
