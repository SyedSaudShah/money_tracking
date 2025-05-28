// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:money_tracking/Model/hive.dart';
import 'package:money_tracking/add_expense.dart';
import 'package:money_tracking/analytics_screen.dart';
import 'package:money_tracking/login.dart';
import 'package:money_tracking/profile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late String currentUserId;
  List<Expense> userExpenses = [];
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  bool showAllTransactions =
      false; // Toggle between recent and all transactions

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final settingsBox = Hive.box('settings');
    currentUserId = settingsBox.get('currentUserId');
    _loadExpenses();
  }

  void _loadExpenses() {
    final expenseBox = Hive.box<Expense>('expenses');
    userExpenses =
        expenseBox.values
            .where((expense) => expense.userId == currentUserId)
            .toList();

    // Sort by date (newest first)
    userExpenses.sort((a, b) => b.date.compareTo(a.date));

    totalIncome = userExpenses
        .where((expense) => expense.type == 'income')
        .fold(0.0, (sum, expense) => sum + expense.amount);

    totalExpense = userExpenses
        .where((expense) => expense.type == 'expense')
        .fold(0.0, (sum, expense) => sum + expense.amount);

    setState(() {});
  }

  void _deleteExpense(Expense expense) async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Transaction'),
          content: Text('Are you sure you want to delete "${expense.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final expenseBox = Hive.box<Expense>('expenses');

      // Find and delete the expense
      final expenseKey = expenseBox.keys.firstWhere((key) {
        final exp = expenseBox.get(key);
        return exp?.userId == expense.userId &&
            exp?.title == expense.title &&
            exp?.amount == expense.amount &&
            exp?.date == expense.date;
      }, orElse: () => null);

      if (expenseKey != null) {
        await expenseBox.delete(expenseKey);
        _loadExpenses(); // Refresh data

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _logout() async {
    final settingsBox = Hive.box('settings');
    await settingsBox.put('isLoggedIn', false);
    await settingsBox.delete('currentUserId');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Widget _buildHomeScreen() {
    // Get transactions to display
    final transactionsToShow =
        showAllTransactions ? userExpenses : userExpenses.take(5).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Cards - Fixed with Flexible
          Row(
            children: [
              Flexible(
                child: _buildBalanceCard(
                  'Total Income',
                  totalIncome,
                  Colors.green,
                  Icons.trending_up,
                ),
              ),
              SizedBox(width: 15),
              Flexible(
                child: _buildBalanceCard(
                  'Total Expense',
                  totalExpense,
                  Colors.red,
                  Icons.trending_down,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildBalanceCard(
            'Net Balance',
            totalIncome - totalExpense,
            totalIncome >= totalExpense ? Colors.green : Colors.red,
            Icons.account_balance_wallet,
            isFullWidth: true,
          ),
          SizedBox(height: 30),

          // Quick Actions
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Add Income',
                  Icons.add_circle,
                  Colors.green,
                  () => _navigateToAddExpense('income'),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: _buildQuickActionButton(
                  'Add Expense',
                  Icons.remove_circle,
                  Colors.red,
                  () => _navigateToAddExpense('expense'),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),

          // Transactions Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  showAllTransactions
                      ? 'All Transactions'
                      : 'Recent Transactions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              if (userExpenses.length > 5)
                TextButton(
                  onPressed: () {
                    setState(() {
                      showAllTransactions = !showAllTransactions;
                    });
                  },
                  child: Text(
                    showAllTransactions
                        ? 'Show Recent'
                        : 'Show All (${userExpenses.length})',
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
            ],
          ),
          SizedBox(height: 15),

          // Transactions List
          userExpenses.isEmpty
              ? Container(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
                    SizedBox(height: 20),
                    Text(
                      'No transactions yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Start by adding your first transaction',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : Column(
                children:
                    transactionsToShow
                        .map((expense) => _buildTransactionItem(expense))
                        .toList(),
              ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
    String title,
    double amount,
    Color color,
    IconData icon, {
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: EdgeInsets.all(16), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20), // Reduced icon size
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '₹${_formatAmount(amount)}',
              style: TextStyle(
                fontSize: isFullWidth ? 24 : 18, // Reduced font size
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to format large amounts
  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Expense expense) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  expense.type == 'income'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              expense.type == 'income'
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: expense.type == 'income' ? Colors.green : Colors.red,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5),
                Text(
                  expense.category,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3),
                Text(
                  '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FittedBox(
                child: Text(
                  '${expense.type == 'income' ? '+' : '-'}₹${_formatAmount(expense.amount)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: expense.type == 'income' ? Colors.green : Colors.red,
                  ),
                ),
              ),
              SizedBox(height: 5),
              GestureDetector(
                onTap: () => _deleteExpense(expense),
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToAddExpense(String type) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddExpenseScreen(type: type)),
    );

    if (result == true) {
      _loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeScreen(),
      AnalyticsScreen(userExpenses: userExpenses),
      ProfileScreen(onLogout: _logout),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar:
          _currentIndex == 0
              ? AppBar(
                title: Text(
                  'Dashboard',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.teal,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.white),
                    onPressed: _loadExpenses,
                  ),
                ],
              )
              : null,
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                onPressed: () => _navigateToAddExpense('expense'),
                backgroundColor: Colors.teal,
                child: Icon(Icons.add, color: Colors.white),
              )
              : null,
    );
  }
}
