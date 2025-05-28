// screens/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:money_tracking/Model/hive.dart';

class AnalyticsScreen extends StatefulWidget {
  final List<Expense> userExpenses;

  const AnalyticsScreen({super.key, required this.userExpenses});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = [
    'This Week',
    'This Month',
    'This Year',
    'All Time',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = _getFilteredExpenses();
    final categoryData = _getCategoryData(filteredExpenses);
    final monthlyData = _getMonthlyData();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
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
              child: DropdownButton<String>(
                value: _selectedPeriod,
                isExpanded: true,
                underline: SizedBox(),
                items:
                    _periods.map((period) {
                      return DropdownMenuItem(
                        value: period,
                        child: Text(period),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPeriod = value!;
                  });
                },
              ),
            ),
            SizedBox(height: 30),

            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Income',
                    filteredExpenses
                        .where((e) => e.type == 'income')
                        .fold(0.0, (sum, e) => sum + e.amount),
                    Colors.green,
                    Icons.trending_up,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Expense',
                    filteredExpenses
                        .where((e) => e.type == 'expense')
                        .fold(0.0, (sum, e) => sum + e.amount),
                    Colors.red,
                    Icons.trending_down,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            // Monthly Trend Chart
            Container(
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
                  Text(
                    'Monthly Trend',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child:
                        monthlyData.isEmpty
                            ? Center(
                              child: Text(
                                'No data available',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                            : LineChart(
                              LineChartData(
                                gridData: FlGridData(show: true),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: true),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: true),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: true),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: monthlyData,
                                    isCurved: true,
                                    color: Colors.teal,
                                    barWidth: 3,
                                    dotData: FlDotData(show: true),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Category Breakdown
            Container(
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
                  Text(
                    'Expense by Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  categoryData.isEmpty
                      ? Center(
                        child: Text(
                          'No expense data available',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                      : Column(
                        children:
                            categoryData.entries.map((entry) {
                              return _buildCategoryItem(
                                entry.key,
                                entry.value,
                                filteredExpenses
                                    .where((e) => e.type == 'expense')
                                    .fold(0.0, (sum, e) => sum + e.amount),
                              );
                            }).toList(),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
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
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    String category,
    double amount,
    double totalExpense,
  ) {
    final percentage = totalExpense > 0 ? (amount / totalExpense) * 100 : 0.0;

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                '₹${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
          SizedBox(height: 5),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  List<Expense> _getFilteredExpenses() {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        return widget.userExpenses;
    }

    return widget.userExpenses.where((expense) {
      return expense.date.isAfter(startDate.subtract(Duration(days: 1)));
    }).toList();
  }

  Map<String, double> _getCategoryData(List<Expense> expenses) {
    final Map<String, double> categoryData = {};

    for (var expense in expenses) {
      if (expense.type == 'expense') {
        categoryData[expense.category] =
            (categoryData[expense.category] ?? 0) + expense.amount;
      }
    }

    return categoryData;
  }

  List<FlSpot> _getMonthlyData() {
    final Map<int, double> monthlyExpenses = {};

    for (var expense in widget.userExpenses) {
      if (expense.type == 'expense') {
        final month = expense.date.month;
        monthlyExpenses[month] = (monthlyExpenses[month] ?? 0) + expense.amount;
      }
    }

    final List<FlSpot> spots = [];
    for (int i = 1; i <= 12; i++) {
      spots.add(FlSpot(i.toDouble(), monthlyExpenses[i] ?? 0));
    }

    return spots;
  }
}
