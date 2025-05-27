// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:money_tracking/Model/hive.dart';

// class ProfileScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Profile'),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.settings),
//             onPressed: () => _showSettingsDialog(context),
//           ),
//         ],
//       ),
//       body: ValueListenableBuilder(
//         valueListenable: Hive.box<Expense>('expenses').listenable(),
//         builder: (context, Box<Expense> box, _) {
//           final expenses = box.values.toList();
//           final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
//           final avgExpense =
//               expenses.isEmpty ? 0.0 : totalExpenses / expenses.length;

//           // Calculate additional statistics
//           final thisMonthExpenses =
//               expenses
//                   .where(
//                     (e) =>
//                         e.date.year == DateTime.now().year &&
//                         e.date.month == DateTime.now().month,
//                   )
//                   .toList();
//           final thisMonthTotal = thisMonthExpenses.fold(
//             0.0,
//             (sum, e) => sum + e.amount,
//           );

//           final mostExpensiveCategory = _getMostExpensiveCategory(expenses);
//           final expenseFrequency = _getExpenseFrequency(expenses);

//           return SingleChildScrollView(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // Profile Header
//                 Container(
//                   padding: EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.blue[700]!, Colors.blue[500]!],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     children: [
//                       CircleAvatar(
//                         radius: 40,
//                         backgroundColor: Colors.white,
//                         child: Icon(
//                           Icons.person,
//                           size: 40,
//                           color: Colors.blue[700],
//                         ),
//                       ),
//                       SizedBox(height: 12),
//                       Text(
//                         'Expense Tracker User',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       Text(
//                         'Managing expenses since ${DateTime.now().year}',
//                         style: TextStyle(color: Colors.white70),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 20),

//                 // Quick Stats Cards
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildStatCard(
//                         'Total Expenses',
//                         '₹${totalExpenses.toStringAsFixed(0)}',
//                         Icons.account_balance_wallet,
//                         Colors.orange,
//                       ),
//                     ),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: _buildStatCard(
//                         'This Month',
//                         '₹${thisMonthTotal.toStringAsFixed(0)}',
//                         Icons.calendar_month,
//                         Colors.green,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildStatCard(
//                         'Total Entries',
//                         '${expenses.length}',
//                         Icons.receipt_long,
//                         Colors.purple,
//                       ),
//                     ),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: _buildStatCard(
//                         'Average',
//                         '₹${avgExpense.toStringAsFixed(0)}',
//                         Icons.trending_up,
//                         Colors.teal,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 20),

//                 // Detailed Statistics
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.1),
//                         spreadRadius: 1,
//                         blurRadius: 4,
//                         offset: Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.all(16),
//                         child: Text(
//                           'Detailed Statistics',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       _buildStatRow(
//                         'Most Expensive Category',
//                         mostExpensiveCategory,
//                         Icons.category,
//                       ),
//                       _buildStatRow(
//                         'Expense Frequency',
//                         expenseFrequency,
//                         Icons.schedule,
//                       ),
//                       _buildStatRow(
//                         'First Entry',
//                         expenses.isEmpty
//                             ? 'No entries yet'
//                             : _formatDate(
//                               expenses
//                                   .map((e) => e.date)
//                                   .reduce((a, b) => a.isBefore(b) ? a : b),
//                             ),
//                         Icons.first_page,
//                       ),
//                       _buildStatRow(
//                         'Latest Entry',
//                         expenses.isEmpty
//                             ? 'No entries yet'
//                             : _formatDate(
//                               expenses
//                                   .map((e) => e.date)
//                                   .reduce((a, b) => a.isAfter(b) ? a : b),
//                             ),
//                         Icons.last_page,
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 20),

//                 // Actions
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.1),
//                         spreadRadius: 1,
//                         blurRadius: 4,
//                         offset: Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.all(16),
//                         child: Text(
//                           'Actions',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       ListTile(
//                         leading: Icon(Icons.download, color: Colors.blue),
//                         title: Text('Export Data'),
//                         subtitle: Text('Export your expenses to CSV'),
//                         trailing: Icon(Icons.arrow_forward_ios, size: 16),
//                         onTap: () => _exportData(context, expenses),
//                       ),
//                       Divider(height: 1),
//                       ListTile(
//                         leading: Icon(Icons.delete_forever, color: Colors.red),
//                         title: Text('Clear All Data'),
//                         subtitle: Text('Delete all expense records'),
//                         trailing: Icon(Icons.arrow_forward_ios, size: 16),
//                         onTap: () => _showClearDataDialog(context, box),
//                       ),
//                       Divider(height: 1),
//                       ListTile(
//                         leading: Icon(Icons.info, color: Colors.grey),
//                         title: Text('About App'),
//                         subtitle: Text('Version 1.0.0'),
//                         trailing: Icon(Icons.arrow_forward_ios, size: 16),
//                         onTap: () => _showAboutDialog(context),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 20),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildStatCard(
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 4,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: color, size: 24),
//           SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatRow(String label, String value, IconData icon) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: Colors.grey[600]),
//           SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               label,
//               style: TextStyle(fontSize: 14, color: Colors.grey[700]),
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getMostExpensiveCategory(List<Expense> expenses) {
//     if (expenses.isEmpty) return 'No data';

//     final categoryTotals = <String, double>{};
//     for (final expense in expenses) {
//       categoryTotals[expense.category] =
//           (categoryTotals[expense.category] ?? 0) + expense.amount;
//     }

//     final maxCategory = categoryTotals.entries.reduce(
//       (a, b) => a.value > b.value ? a : b,
//     );

//     return '${maxCategory.key} (₹${maxCategory.value.toStringAsFixed(0)})';
//   }

//   String _getExpenseFrequency(List<Expense> expenses) {
//     if (expenses.isEmpty) return 'No data';

//     final now = DateTime.now();
//     final daysWithExpenses =
//         expenses
//             .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
//             .toSet()
//             .length;

//     if (daysWithExpenses == 0) return 'No data';

//     final daysSinceFirst =
//         now
//             .difference(
//               expenses
//                   .map((e) => e.date)
//                   .reduce((a, b) => a.isBefore(b) ? a : b),
//             )
//             .inDays +
//         1;

//     final frequency = daysWithExpenses / daysSinceFirst;

//     if (frequency >= 0.8) return 'Daily';
//     if (frequency >= 0.4) return 'Regular';
//     if (frequency >= 0.1) return 'Weekly';
//     return 'Occasional';
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   void _showSettingsDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Text('Settings'),
//             content: Text('Settings functionality coming soon!'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('OK'),
//               ),
//             ],
//           ),
//     );
//   }

//   void _exportData(BuildContext context, List<Expense> expenses) {
//     if (expenses.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('No data to export')));
//       return;
//     }

//     // In a real app, you would implement CSV export here
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Export functionality coming soon!')),
//     );
//   }

//   void _showClearDataDialog(BuildContext context, Box<Expense> box) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Text('Clear All Data'),
//             content: Text(
//               'Are you sure you want to delete all expense records? This action cannot be undone.',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   box.clear();
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('All data cleared successfully')),
//                   );
//                 },
//                 style: TextButton.styleFrom(foregroundColor: Colors.red),
//                 child: Text('Delete All'),
//               ),
//             ],
//           ),
//     );
//   }

//   void _showAboutDialog(BuildContext context) {
//     showAboutDialog(
//       context: context,
//       applicationName: 'Expense Tracker',
//       applicationVersion: '1.0.0',
//       applicationIcon: Icon(Icons.account_balance_wallet, size: 48),
//       children: [
//         Text('A simple and elegant expense tracking app built with Flutter.'),
//         SizedBox(height: 16),
//         Text('Features:'),
//         Text('• Add and manage expenses'),
//         Text('• View analytics and charts'),
//         Text('• Track spending by categories'),
//         Text('• Export data (coming soon)'),
//       ],
//     );
//   }
// }
