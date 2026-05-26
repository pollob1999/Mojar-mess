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
  bool _isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Natore Pioneer Mess Pro',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        cardColor: Colors.white,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        primarySwatch: Colors.blue,
        useMaterial3: true,
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
  final String date;
  final String memberName;
  final double amount;
  final String item;
  BazaarLog({required this.date, required this.memberName, required this.amount, required this.item});
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
  final String _messName = "Natore Pioneer Mess 👑";
  
  final List<Member> _members = [
    Member(id: 1, name: "Arif", meals: 24.5),
    Member(id: 2, name: "Azazul", meals: 22.0),
    Member(id: 3, name: "Sakib", meals: 18.0),
  ];

  final List<OtherExpense> _otherExpenses = [
    OtherExpense(tag: "Gas Cylinder", amount: 1400)
  ];

  final List<BazaarLog> _bazaarLogs = [
    BazaarLog(date: "25 May", memberName: "Arif", amount: 1850, item: "Chicken & Rice"),
    BazaarLog(date: "26 May", memberName: "Azazul", amount: 650, item: "Eggs & Oil")
  ];

  final List<CashDeposit> _cashDeposits = [
    CashDeposit(memberId: 1, amount: 3000),
    CashDeposit(memberId: 2, amount: 3000),
    CashDeposit(memberId: 3, amount: 4500),
  ];

  final _rentController = TextEditingController(text: "12000");
  final _maidController = TextEditingController(text: "2000");
  final _electricityController = TextEditingController(text: "1600");
  final _wifiController = TextEditingController(text: "500");

  int _selectedMemberId = 1;
  bool _bfChecked = false;
  bool _lunchChecked = true;
  bool _dinnerChecked = true;

  final _depositController = TextEditingController();
  final _bazaarAmountController = TextEditingController();
  final _bazaarItemController = TextEditingController();
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
    
    double totalFixedExpenses = currentRent + currentElectricity + currentWifi + currentMaidBill + totalOthers;
    double totalExpense = totalBazaar + totalFixedExpenses;
    
    double mealRate = totalMeals > 0 ? totalBazaar / totalMeals : 0;
    double fixedPerPerson = totalFixedExpenses / _members.length;

    double getIndividualDeposit(int memberId, String name) {
      double cash = _cashDeposits.where((c) => c.memberId == memberId).fold(0, (sum, c) => sum + c.amount);
      double bazaar = _bazaarLogs.where((b) => b.memberName == name).fold(0, (sum, b) => sum + b.amount);
      return cash + bazaar;
    }

    double totalDeposit = _members.fold(0, (sum, m) => sum + getIndividualDeposit(m.id, m.name));

    return Scaffold(
      appBar: AppBar(
        title: Text(_messName, style: const TextStyle(fontWeight: FontWeight.black, fontSize: 19)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round),
            onPressed: () => widget.onThemeChanged(!widget.isDarkMode),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildGlassCard("Total Members", "${_members.length} Active", const Color(0xFF3B82F6), Icons.group),
                _buildGlassCard("Total Meals", totalMeals.toString(), const Color(0xFF06B6D4), Icons.restaurant),
                _buildGlassCard("Total Deposit", "৳${totalDeposit.toStringAsFixed(0)}", const Color(0xFF10B981), Icons.account_balance_wallet),
                _buildGlassCard("Total Expense", "৳${totalExpense.toStringAsFixed(0)}", const Color(0xFFF43F5E), Icons.analytics),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue.withOpacity(0.15), Colors.cyan.withOpacity(0.15)]),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("🔥 Meal Rate: ৳${mealRate.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueAccent)),
                  Text("💼 Shared/Head: ৳${fixedPerPerson.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.cyan)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildHeading("Monthly Utilities Config"),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.withOpacity(0.15))),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _rentController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Rent (Custom)", prefixText: "৳"), onChanged: (v) => setState(() {}))),
                        const SizedBox(width: 14),
                        Expanded(child: TextField(controller: _maidController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Maid (Split)", prefixText: "৳"), onChanged: (v) => setState(() {}))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _electricityController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Electricity", prefixText: "৳"), onChanged: (v) => setState(() {}))),
                        const SizedBox(width: 14),
                        Expanded(child: TextField(controller: _wifiController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "WiFi Router", prefixText: "৳"), onChanged: (v) => setState(() {}))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildHeading("Live Matrix Ledger"),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.withOpacity(0.15))),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _members.length,
                separatorBuilder: (c, i) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final member = _members[index];
                  double individualDeposit = getIndividualDeposit(member.id, member.name);
                  double individualCost = (member.meals * mealRate) + fixedPerPerson;
                  double balance = individualDeposit - individualCost;
                  bool isProfit = balance >= 0;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    title: Row(
                      children: [
                        Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isProfit ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isProfit ? "IN PROFIT" : "OWES CASH",
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.black, color: isProfit ? Colors.green : Colors.redAccent),
                          ),
                        )
                      ],
                    ),
                    subtitle: Text("${member.meals} Meals Taken • Deposited: ৳${individualDeposit.toStringAsFixed(0)}", style: const TextStyle(fontSize: 12)),
                    trailing: Text(
                      "${isProfit ? '+' : ''}৳${balance.toStringAsFixed(0)}",
                      style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.black, fontSize: 15, color: isProfit ? Colors.green : Colors.redAccent),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            _buildHeading("Smart Log Workspace"),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.withOpacity(0.15))),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<int>(
                    value: _selectedMemberId,
                    decoration: const InputDecoration(labelText: "Select Roommate Focus", border: OutlineInputBorder()),
                    items: _members.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
                    onChanged: (val) => setState(() => _selectedMemberId = val!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _depositController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "1. Handover Cash (Can be 0)"))),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_moderator),
                        onPressed: () {
                          double amt = double.tryParse(_depositController.text) ?? 0;
                          setState(() => _cashDeposits.add(CashDeposit(memberId: _selectedMemberId, amount: amt)));
                          _depositController.clear();
                        },
                        label: const Text("Save"),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("2. Advanced Meal Checkbox Matrix", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMealCheck("Breakfast (0.5)", _bfChecked, (v) => setState(() => _bfChecked = v!)),
                      _buildMealCheck("Lunch (1.0)", _lunchChecked, (v) => setState(() => _lunchChecked = v!)),
                      _buildMealCheck("Dinner (1.0)", _dinnerChecked, (v) => setState(() => _dinnerChecked = v!)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.dinner_dining),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                      onPressed: () {
                        double sessionSum = 0;
                        if (_bfChecked) sessionSum += 0.5;
                        if (_lunchChecked) sessionSum += 1.0;
                        if (_dinnerChecked) sessionSum += 1.0;
                        setState(() {
                          _members.firstWhere((m) => m.id == _selectedMemberId).meals += sessionSum;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added $sessionSum meals successfully!")));
                      },
                      label: const Text("Commit Selected Meals Matrix"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("3. Log Daily Bazaar Expenditure", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _bazaarItemController, decoration: const InputDecoration(hintText: "Fish, Dal, etc."))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: _bazaarAmountController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Cost"))),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () {
                          double amt = double.tryParse(_bazaarAmountController.text) ?? 0;
                          if (amt <= 0 || _bazaarItemController.text.isEmpty) return;
                          String activeName = _members.firstWhere((m) => m.id == _selectedMemberId).name;
                          setState(() => _bazaarLogs.insert(0, BazaarLog(date: "26 May", memberName: activeName, amount: amt, item: _bazaarItemController.text)));
                          _bazaarAmountController.clear();
                          _bazaarItemController.clear();
                        },
                        icon: const Icon(Icons.shopping_cart_checkout),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildHeading("Bazaar Log Statement Feed"),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.withOpacity(0.15))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _bazaarLogs.length > 4 ? 4 : _bazaarLogs.length,
                  itemBuilder: (context, index) {
                    final log = _bazaarLogs[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.emerald.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.receipt_long, color: Colors.emerald, size: 20),
                      ),
                      title: Text(log.item, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text("Bought by ${log.memberName} • ${log.date}", style: const TextStyle(fontSize: 11)),
                      trailing: Text("৳${log.amount.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildHeading("Custom Miscellaneous Bills"),
            Card(
              padding: const EdgeInsets.all(14),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.withOpacity(0.15))),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _otherTagController, decoration: const InputDecoration(hintText: "Tag Name (e.g., Tissue)"))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: _otherAmountController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Cost"))),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blueAccent, size: 32),
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
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _otherExpenses.map((o) => Chip(
                      label: Text("#${o.tag}: ৳${o.amount.toStringAsFixed(0)}"),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    )).toList(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.black, letterSpacing: 0.3)),
    );
  }

  Widget _buildMealCheck(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGlassCard(String title, String val, Color highlightColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(color: highlightColor.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title.toUpperCase(), style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.black, letterSpacing: 0.5)),
              Icon(icon, size: 16, color: highlightColor.withOpacity(0.6)),
            ],
          ),
          const SizedBox(height: 6),
          Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.black, color: highlightColor)),
        ],
      ),
    );
  }
}
