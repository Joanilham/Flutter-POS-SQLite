import 'package:flutter/material.dart';
import 'package:flutter_pos_sqlite/db/repository.dart';
import 'package:intl/intl.dart';

class TotalScreen extends StatefulWidget {
  const TotalScreen({super.key});

  @override
  State<TotalScreen> createState() => _TotalScreenState();
}

class _TotalScreenState extends State<TotalScreen> {
  late Future<Map<String, double>> _dailyTotalsFuture;

  @override
  void initState() {
    super.initState();
    _dailyTotalsFuture = Repo.instance.getDailyTransactionTotals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Transaction Totals'),
      ),
      body: FutureBuilder<Map<String, double>>(
        future: _dailyTotalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }

          final dailyTotals = snapshot.data!;
          final dates = dailyTotals.keys.toList();

          return ListView.builder(
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final total = dailyTotals[date]!;
              final formattedDate =
                  DateFormat.yMMMMd('en_US').format(DateTime.parse(date));
              final formattedTotal =
                  NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ')
                      .format(total);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    formattedDate,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    formattedTotal,
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}