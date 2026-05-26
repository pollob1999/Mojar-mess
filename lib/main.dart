import 'package:flutter/material.dart';

void main() {
  runApp(const MessManagementApp());
}

class MessManagementApp extends StatefulWidget {
  const MessManagementApp({Key? key}) : super(key: key);

  @override
  State<MessManagementApp> createState() => _MessManagementAppState();
}

class _MessManagementAppState extends State<MessManagementApp> {
  bool _isDarkMode = true; // Default to Dark Mode

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mess Manager Pro',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardColor: Colors.white,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Dark Navy
        cardColor: const Color(0xFF1E293B), // Slate Card
        primarySwatch: Colors.blue,
      ),
      home: DashboardScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: (val) => setState(() => _isDarkMode = val),
      ),
    );
  }
}

class Member {
  final int id;
  final String name;
  double meals;
  Member({required this.id, required this.name, required this.meals});
}

class OtherExpense {
  final String tag;
  final double amount;
  OtherExpense({required this.tag, required this.amount});
}

class BazaarLog {
  final int memberId;
  final double amount;
  final String item;
  BazaarLog({required this.memberId, required this.amount, required this.item});
}

class CashDeposit {
  final int memberId;
  final double amount;
  CashDeposit({required this.memberId, required this.amount});
}

class DashboardScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  const DashboardScreen({Key? key, required this.isDarkMode, required this.onThemeChanged}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final String _messName = "Natore Pioneer Mess";
  
  final List<Member> _members = [
    Member(id: 1, name: "Arif", meals: 0),
    Member(id: 2, name: "Azazul", meals: 0),
    Member(id: 3, name: "Sakib", meals: 0),
  ];

  final List<OtherExpense> _otherExpenses = [];
  final List<BazaarLog> _bazaarLogs = [];
  final List<CashDeposit> _cashDeposits = [];

  // Controllers for text boxes
  final _rentController = TextEditingController(text: "0");
  final _maidController = TextEditingController(text: "0");
  final _electricityController = TextEditingController(text: "0");
  final _wifiController = TextEditingController(text: "0");

  int _selectedMemberId = 1;
  final _depositController = TextEditingController();
  final _bazaarAmountController = TextEditingController();
  final _bazaarItemController = TextEditingController();
  final _mealController = TextEditingController();
  final _otherTagController = TextEditingController();
  final _otherAmountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double currentRent = double.tryParse(_rentController.text) ?? 0;
    double currentMaidBill = double.tryParse(_maidController.text) ?? 0;
    double currentElectricity = double.tryParse(_electricityController.text) ?? 0;
    double currentWifi = double.tryParse(_wifiController.text) ?? 0;

    double totalMeals = _members.fold(0, (sum, m) => sum + m.meals);
    double totalBazaar = _bazaarLogs.fold(0, (sum, b) => sum + b.amount);
    double totalOthers = _otherExpenses.fold(0, (sum, o) => sum + o.amount);
    
    // Shared bills calculation (Rent, Maid, Utilities, Others divided equally)
    double totalFixedExpenses = currentRent + currentElectricity + currentWifi + currentMaidBill + totalOthers;
    double totalExpense = totalBazaar + totalFixedExpenses;
    
    double mealRate = totalMeals > 0 ? totalBazaar / totalMeals : 0;
    double fixedPerPerson = totalFixedExpenses / _members.length;

    double getIndividualDeposit(int memberId) {
      double cash = _cashDeposits.where((c) => c.memberId == memberId).fold(0, (sum, c) => sum + c.amount);
      double bazaar = _bazaarLogs.where((b) => b.memberId == memberId).fold(0, (sum, b) => sum + b.amount);
      return cash + bazaar;
    }

    double totalDeposit = _members.fold(0, (sum, m) => sum + getIndividualDeposit(m.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(_messName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.onThemeChanged(!widget.isDarkMode),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 4 Core Summary Cards Requested by User
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.6,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildCard("Total Members", "${_members.length}", Colors.blueAccent),
                _buildCard("Total Meals", totalMeals.toString(), Colors.cyan),
                _buildCard("Total Deposit", "৳${totalDeposit.toStringAsFixed(0)}", Colors.green),
                _buildCard("Total Expense", "৳${totalExpense.toStringAsFixed(0)}", Colors.roseAccent),
              ],
            ),
            const SizedBox(height: 12),

            // Live rate strip
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(
                "Meal Rate: ৳${mealRate.toStringAsFixed(2)} | Fixed/Person: ৳${fixedPerPerson.toStringAsFixed(0)}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Fixed Bills Inputs (Custom Rent, Shared Maid Bill)
            const Text("Monthly Fixed Bills Config", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _rentController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Custom Rent"), onChanged: (v) => setState(() {}))),
                        const SizedBox(width: 12),
                        Expanded(child: TextField(controller: _maidController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Maid Bill (Shared)"), onChanged: (v) => setState(() {}))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _electricityController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Electricity"), onChanged: (v) => setState(() {}))),
                        const SizedBox(width: 12),
                        Expanded(child: TextField(controller: _wifiController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "WiFi"), onChanged: (v) => setState(() {}))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Roommates Status Matrix
            const Text("Live Roommate Ledger", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Card(
              margin: EdgeInsets.zero,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _members.length,
                separatorBuilder: (c, i) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final member = _members[index];
                  double individualDeposit = getIndividualDeposit(member.id);
                  double individualCost = (member.meals * mealRate) + fixedPerPerson;
                  double balance = individualDeposit - individualCost;

                  return ListTile(
                    title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text("${member.meals} Meals • Dep: ৳${individualDeposit.toStringAsFixed(0)}", style: const TextStyle(fontSize: 12)),
                    trailing: Text(
                      "${balance >= 0 ? '+' : ''}৳${balance.toStringAsFixed(1)}",
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: balance >= 0 ? Colors.green : Colors.redAccent,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Forms Panel
            const Text("Log Activity Entry Form", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Card(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    value: _selectedMemberId,
                    decoration: const InputDecoration(labelText: "Select Roommate Context", border: OutlineInputBorder()),
                    items: _members.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
                    onChanged: (val) => setState(() => _selectedMemberId = val!),
                  ),
                  const SizedBox(height: 12),

                  // Deposit Input Form Field (Accepts 0)
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _depositController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "1. Add Cash Deposit (Can be 0)"))),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        onPressed: () {
                          double amt = double.tryParse(_depositController.text) ?? 0;
                          setState(() => _cashDeposits.add(CashDeposit(memberId: _selectedMemberId, amount: amt)));
                          _depositController.clear();
                        },
                        child: const Text("Save"),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Bazaar inputs (Links to deposit history automatically)
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _bazaarItemController, decoration: const InputDecoration(hintText: "Items Bought"))),
                      const SizedBox(width: 6),
                      Expanded(child: TextField(controller: _bazaarAmountController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Cost"))),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        onPressed: () {
                          double amt = double.tryParse(_bazaarAmountController.text) ?? 0;
                          if (amt <= 0 || _bazaarItemController.text.isEmpty) return;
                          setState(() => _bazaarLogs.add(BazaarLog(memberId: _selectedMemberId, amount: amt, item: _bazaarItemController.text)));
                          _bazaarAmountController.clear();
                          _bazaarItemController.clear();
                        },
                        child: const Text("Log"),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Meals Input Form Field
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _mealController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "3. Increment Meal Count"))),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        onPressed: () {
                          double count = double.tryParse(_mealController.text) ?? 0;
                          setState(() => _members.firstWhere((m) => m.id == _selectedMemberId).meals += count);
                          _mealController.clear();
                        },
                        child: const Text("Add"),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tagged Custom Utilities Section
            const Text("Custom 'Others' Tags Panel", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Card(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _otherTagController, decoration: const InputDecoration(hintText: "Tag (e.g. Gas Cylinder)"))),
                      const SizedBox(width: 6),
                      Expanded(child: TextField(controller: _otherAmountController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Cost Amount"))),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.emerald, size: 28),
                        onPressed: () {
                          double amt = double.tryParse(_otherAmountController.text) ?? 0;
                          if (_otherTagController.text.isEmpty || amt <= 0) return;
                          setState(() => _otherExpenses.add(OtherExpense(tag: _otherTagController.text, amount: amt)));
                          _otherTagController.clear();
                          _otherAmountController.clear();
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _otherExpenses.map((o) => Chip(label: Text("#${o.tag}: ৳${o.amount.toStringAsFixed(0)}"))).toList(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title.toUpperCase(), style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
