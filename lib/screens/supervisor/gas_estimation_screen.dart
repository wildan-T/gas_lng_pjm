import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/data_service.dart';
import '../../models/forecast_model.dart';
import 'forecast_input_screen.dart';

class GasEstimationScreen extends StatefulWidget {
  const GasEstimationScreen({Key? key}) : super(key: key);

  @override
  _GasEstimationScreenState createState() => _GasEstimationScreenState();
}

class _GasEstimationScreenState extends State<GasEstimationScreen> {
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estimasi Kebutuhan Gas'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Input Forecast',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForecastInputScreen()),
              );
              setState(() {}); // Refresh
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Selector
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.month == 1
                            ? _selectedDate.year - 1
                            : _selectedDate.year,
                        _selectedDate.month == 1 ? 12 : _selectedDate.month - 1,
                      );
                    });
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      DateFormat.yMMMM('id_ID').format(_selectedDate),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.month == 12
                            ? _selectedDate.year + 1
                            : _selectedDate.year,
                        _selectedDate.month == 12 ? 1 : _selectedDate.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: FutureBuilder<GasEstimation?>(
              future: Provider.of<DataService>(
                context,
                listen: false,
              ).getGasEstimation(_selectedDate.year, _selectedDate.month),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                final estimation = snapshot.data;

                if (estimation == null) {
                  return _buildEmptyState();
                }

                return _buildEstimationContent(estimation);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assessment_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 24),
            Text(
              'Belum ada data forecast',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Silakan input forecast produksi untuk\nmelihat estimasi kebutuhan gas',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForecastInputScreen(),
                  ),
                );
                setState(() {});
              },
              icon: Icon(Icons.add),
              label: Text('Input Forecast'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstimationContent(GasEstimation estimation) {
    final numberFormat = NumberFormat('#,##0.0', 'id_ID');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Forecast Info Card
        Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.factory, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Forecast Produksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  '${numberFormat.format(estimation.forecastProduction)} Pcs',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Target produksi bulan ini',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        // Estimation Results
        Card(
          elevation: 2,
          color: Colors.green.shade50,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_gas_station, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Estimasi Kebutuhan Gas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Divider(height: 24),

                // Estimated Gas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Volume Gas:', style: TextStyle(fontSize: 14)),
                    Text(
                      '${numberFormat.format(estimation.estimatedGas)} m³',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Estimated Cost
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Estimasi Biaya:', style: TextStyle(fontSize: 14)),
                    Text(
                      currencyFormat.format(estimation.estimatedCost),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        // Calculation Details
        Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calculate, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Detail Perhitungan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Divider(height: 24),

                _buildDetailRow(
                  'Rata-rata Gas Historis',
                  '${numberFormat.format(estimation.historicalAvgGas)} m³',
                ),
                SizedBox(height: 8),
                _buildDetailRow(
                  'Harga Gas per m³',
                  currencyFormat.format(estimation.gasPricePerM3),
                ),
                SizedBox(height: 16),

                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Formula Estimasi:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Estimasi Gas = Rata-rata Historis',
                        style: TextStyle(fontSize: 11),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Estimasi Biaya = Estimasi Gas × Harga per m³',
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        // Notes
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Estimasi ini berdasarkan rata-rata konsumsi gas historis. Konsumsi aktual dapat bervariasi tergantung kondisi produksi.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
