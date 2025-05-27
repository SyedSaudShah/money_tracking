// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:money_tracking/Model/hive.dart';
import 'package:money_tracking/add_expense.dart';
import 'package:money_tracking/analytics_screen.dart';
import 'package:money_tracking/login.dart';
import 'package:money_tracking/profile.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late String currentUserId;
  List<Expense> userExpenses = [];
  double totalIncome = 0.0;
  double totalExpense = 0.0;

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

    totalIncome = userExpenses
        .where((expense) => expense.type == 'income')
        .fold(0.0, (sum, expense) => sum + expense.amount);

    totalExpense = userExpenses
        .where((expense) => expense.type == 'expense')
        .fold(0.0, (sum, expense) => sum + expense.amount);

    setState(() {});
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
    // Get recent transactions
    final recentExpenses =
        userExpenses.take(5).toList()..sort((a, b) => b.date.compareTo(a.date));

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Cards
          Row(
            children: [
              Expanded(
                child: _buildBalanceCard(
                  'Total Income',
                  totalIncome,
                  Colors.green,
                  Icons.trending_up,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
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
          // Recent Transactions
          Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 15),
          recentExpenses.isEmpty
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
                  ],
                ),
              )
              : Column(
                children:
                    recentExpenses
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
      padding: EdgeInsets.all(20),
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
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isFullWidth ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
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
                ),
                SizedBox(height: 5),
                Text(
                  expense.category,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '${expense.type == 'income' ? '+' : '-'}₹${expense.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: expense.type == 'income' ? Colors.green : Colors.red,
            ),
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
