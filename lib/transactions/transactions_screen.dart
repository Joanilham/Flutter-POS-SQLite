import 'package:flutter/material.dart';
import 'package:flutter_pos_sqlite/models/item.dart';
import 'package:flutter_pos_sqlite/utils/format.dart';
import '../models/txn.dart';
import '../db/repository.dart';
import 'receipt_screen.dart';

class TransactionsScreen extends StatefulWidget {
  final Map<Item, int> cart;

  const TransactionsScreen({super.key, required this.cart});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  double get _totalPrice {
    return widget.cart.entries
        .map((e) => e.key.price * e.value)
        .fold(0, (a, b) => a + b);
  }

  void _checkout() async {
    if (widget.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    final details = widget.cart.entries.map((entry) {
      return TxnDetail(
        itemId: entry.key.id,
        quantity: entry.value,
      );
    }).toList();

    final txn = Txn(
      total: _totalPrice,
      datetime: DateTime.now().toIso8601String(),
      userId: 1, // Hardcoded userId
     details: details,
    );

    try {
      final txnId = await Repo.instance.createTransaction(txn);
      txn.id = txnId; // Assign the returned id to the transaction object

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout successful!')),
      );

      // Navigate to ReceiptScreen and clear the cart screen from the stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(
            transaction: txn,
            cart: widget.cart,
          ),
        ),
        (Route<dynamic> route) => route.isFirst, // Removes all routes until the first one (menu screen)
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cart.length,
              itemBuilder: (context, index) {
                final item = widget.cart.keys.elementAt(index);
                final qty = widget.cart[item]!;
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('Qty: $qty'),
                  trailing: Text(
                    formatCurrency.format(item.price * qty),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formatCurrency.format(_totalPrice),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: widget.cart.isEmpty ? null : _checkout,
                  child: const Text('Checkout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
