import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gas_lng_pjm/services/auth_service_mock.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/data_service_mock.dart';
import '../supervisor/export_report_screen.dart';

class ManagementDashboard extends StatefulWidget {
  const ManagementDashboard({Key? key}) : super(key: key);

  @override
  _ManagementDashboardState createState() => _ManagementDashboardState();
}

class _ManagementDashboardState extends State<ManagementDashboard> {
  Map<String, dynamic>? _summary;
  bool _isLoading = true;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _isLoading = true);
    final dataService = Provider.of<DataService>(context, listen: false);
    final summary = await dataService.getMonthlySummary(_selectedYear, _selectedMonth);
    setState(() {
      _summary = summary;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Manajemen'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month),
            onPressed: _selectMonth,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      // ← NEW: Tambahkan FAB di sini (sejajar dengan appBar dan body)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ExportReportScreen()),
          );
        },
        icon: Icon(Icons.file_download),
        label: Text('Export'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSummary,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  _buildPeriodCard(),
                  SizedBox(height: 16),
                  _buildSummaryCards(),
                  SizedBox(height: 24),
                  _buildMonthlyChart(),
                  SizedBox(height: 24),
                  _buildMachineChart(),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodCard() {
    final monthName = DateFormat.MMMM('id_ID').format(DateTime(_selectedYear, _selectedMonth));
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Periode',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '$monthName $_selectedYear',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Icon(Icons.calendar_today, color: Colors.blue, size: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final formatter = NumberFormat('#,##0.0', 'id_ID');
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Total Konsumsi',
                value: '${formatter.format(_summary!['totalConsumption'])} m³',
                icon: Icons.local_gas_station,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Total Biaya',
                value: currencyFormatter.format(_summary!['totalCost']),
                icon: Icons.attach_money,
                color: Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Rata-rata Harian',
                value: '${formatter.format(_summary!['avgDaily'])} m³',
                icon: Icons.trending_up,
                color: Colors.orange,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Total Records',
                value: '${_summary!['recordCount']}',
                icon: Icons.description,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthlyChart() {
    final dailyData = _summary!['dailyConsumption'] as Map<int, double>;
    
    if (dailyData.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('Tidak ada data untuk ditampilkan'),
          ),
        ),
      );
    }

    final spots = dailyData.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trend Konsumsi Harian',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(color: Colors.grey.shade300),
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMachineChart() {
    final machineData = _summary!['machineConsumption'] as Map<String, double>;
    
    if (machineData.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('Tidak ada data mesin'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Konsumsi per Mesin',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: machineData.entries
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data.value,
                          color: Colors.primaries[index % Colors.primaries.length],
                          width: 40,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          final machines = machineData.keys.toList();
                          if (value.toInt() < machines.length) {
                            return Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: RotatedBox(
                                quarterTurns: -1,
                                child: Text(
                                  machines[value.toInt()],
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(color: Colors.grey.shade300),
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectMonth() async {
    final result = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedYear, _selectedMonth),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (result != null) {
      setState(() {
        _selectedYear = result.year;
        _selectedMonth = result.month;
      });
      _loadSummary();
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}