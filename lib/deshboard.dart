import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_tracking/Model/hive.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  final DateTime _selectedDate = DateTime.now();

  void _addExpense() async {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        category: _categoryController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        title: '',
      );
      final box = Hive.box<Expense>('expenses');
      await box.add(expense);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) => value!.isEmpty ? 'Enter category' : null,
              ),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Amount'),
                validator: (value) => value!.isEmpty ? 'Enter amount' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addExpense,
                child: Text('Add Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard'), elevation: 0),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Expense>('expenses').listenable(),
        builder: (context, Box<Expense> box, _) {
          final expenses = box.values.toList();
          final today = DateTime.now();
          final thisMonth =
              expenses
                  .where(
                    (e) =>
                        e.date.month == today.month &&
                        e.date.year == today.year,
                  )
                  .toList();

          final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
          final avgExpense =
              expenses.isEmpty ? 0.0 : totalExpenses / expenses.length;
          final totalThisMonth = thisMonth.fold(
            0.0,
            (sum, e) => sum + e.amount,
          );
          final totalAllTime = expenses.fold(0.0, (sum, e) => sum + e.amount);

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'This Month',
                          '₹${totalThisMonth.toStringAsFixed(0)}',
                          Icons.calendar_month,
                          Colors.blue,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          'Total',
                          '₹${totalAllTime.toStringAsFixed(0)}',
                          Icons.account_balance_wallet,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Your Statistics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildStatItem(
                        'Total Expenses',
                        '₹${totalExpenses.toStringAsFixed(0)}',
                        Icons.account_balance_wallet,
                      ),
                      _buildStatItem(
                        'Number of Transactions',
                        '${expenses.length}',
                        Icons.receipt_long,
                      ),
                      _buildStatItem(
                        'Average Expense',
                        '₹${avgExpense.toStringAsFixed(0)}',
                        Icons.trending_up,
                      ),
                      _buildStatItem(
                        'Highest Expense',
                        expenses.isEmpty
                            ? '₹0'
                            : '₹${expenses.map((e) => e.amount).reduce((a, b) => a > b ? a : b).toStringAsFixed(0)}',
                        Icons.arrow_upward,
                      ),
                    ],
                  ),
                ),

                // Recent Transactions
                Container(
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Recent Expenses',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: expenses.length > 5 ? 5 : expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses.reversed.toList()[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getCategoryColor(
                                expense.category,
                              ),
                              child: Icon(
                                _getCategoryIcon(expense.category),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(expense.title),
                            subtitle: Text(expense.category),
                            trailing: Text(
                              '₹${expense.amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red[600],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Settings Section
                Container(
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.notifications,
                          color: Colors.blue[700],
                        ),
                        title: Text('Notifications'),
                        subtitle: Text('Manage your notification preferences'),
                        trailing: Switch(value: true, onChanged: (value) {}),
                      ),
                      ListTile(
                        leading: Icon(Icons.backup, color: Colors.green),
                        title: Text('Backup Data'),
                        subtitle: Text('Export your expense data'),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Backup feature coming soon!'),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.delete_forever, color: Colors.red),
                        title: Text('Clear All Data'),
                        subtitle: Text('Delete all expenses permanently'),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _showClearDataDialog(context, box),
                      ),
                      ListTile(
                        leading: Icon(Icons.info, color: Colors.grey),
                        title: Text('About'),
                        subtitle: Text('Version 1.0.0'),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'Expense Tracker',
                            applicationVersion: '1.0.0',
                            applicationIcon: Icon(Icons.account_balance_wallet),
                            children: [
                              Text(
                                'A professional expense tracking app built with Flutter and Hive database.',
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[700]),
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue[700],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'shopping':
        return Colors.purple;
      case 'entertainment':
        return Colors.red;
      case 'bills':
        return Colors.green;
      case 'health':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'bills':
        return Icons.receipt;
      case 'health':
        return Icons.local_hospital;
      default:
        return Icons.money;
    }
  }

  void _showClearDataDialog(BuildContext context, Box<Expense> box) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Clear All Data'),
            content: Text(
              'This will permanently delete all your expenses. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  box.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('All data cleared successfully'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                child: Text('Clear All', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
