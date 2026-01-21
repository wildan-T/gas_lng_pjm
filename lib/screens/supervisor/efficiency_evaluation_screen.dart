import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/data_service_mock.dart';
import '../../models/forecast_model.dart';

class EfficiencyEvaluationScreen extends StatefulWidget {
  const EfficiencyEvaluationScreen({Key? key}) : super(key: key);

  @override
  _EfficiencyEvaluationScreenState createState() =>
      _EfficiencyEvaluationScreenState();
}

class _EfficiencyEvaluationScreenState
    extends State<EfficiencyEvaluationScreen> {
  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  // ✅ Helper methods untuk warna
  Color _getCategoryMainColor(EfficiencyCategory category) {
    switch (category) {
      case EfficiencyCategory.efficient:
        return Colors.green;
      case EfficiencyCategory.normal:
        return Colors.orange;
      case EfficiencyCategory.wasteful:
        return Colors.red;
    }
  }

  Color _getCategoryLightColor(EfficiencyCategory category) {
    switch (category) {
      case EfficiencyCategory.efficient:
        return Colors.green.shade50;
      case EfficiencyCategory.normal:
        return Colors.orange.shade100;
      case EfficiencyCategory.wasteful:
        return Colors.red.shade50;
    }
  }

  Color _getCategoryDarkColor(EfficiencyCategory category) {
    switch (category) {
      case EfficiencyCategory.efficient:
        return Colors.green.shade900;
      case EfficiencyCategory.normal:
        return Colors.orange.shade900;
      case EfficiencyCategory.wasteful:
        return Colors.red.shade900;
    }
  }

  Color _getCategoryMediumColor(EfficiencyCategory category) {
    switch (category) {
      case EfficiencyCategory.efficient:
        return Colors.green.shade700;
      case EfficiencyCategory.normal:
        return Colors.orange.shade700;
      case EfficiencyCategory.wasteful:
        return Colors.red.shade700;
    }
  }

  IconData _getCategoryIcon(EfficiencyCategory category) {
    switch (category) {
      case EfficiencyCategory.efficient:
        return Icons.trending_down;
      case EfficiencyCategory.normal:
        return Icons.remove;
      case EfficiencyCategory.wasteful:
        return Icons.trending_up;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evaluasi Efisiensi'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            tooltip: 'Riwayat',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EfficiencyHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Selector
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.purple.shade50,
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
            child: FutureBuilder<EfficiencyEvaluation?>(
              future: Provider.of<DataService>(context, listen: false)
                  .getEfficiencyEvaluation(_selectedDate.year, _selectedDate.month),
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

                final evaluation = snapshot.data;

                if (evaluation == null) {
                  return _buildEmptyState();
                }

                return _buildEvaluationContent(evaluation);
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
              Icons.analytics_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 24),
            Text(
              'Belum ada data konsumsi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Evaluasi efisiensi akan tersedia setelah\nada data konsumsi yang terverifikasi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationContent(EfficiencyEvaluation evaluation) {
    final numberFormat = NumberFormat('#,##0.0', 'id_ID');

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Category Card (Big)
        Card(
          elevation: 4,
          color: _getCategoryLightColor(evaluation.category),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  _getCategoryIcon(evaluation.category),
                  size: 64,
                  color: _getCategoryMainColor(evaluation.category),
                ),
                SizedBox(height: 16),
                Text(
                  evaluation.categoryLabel,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _getCategoryDarkColor(evaluation.category),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${evaluation.deviation >= 0 ? '+' : ''}${evaluation.deviation.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: _getCategoryMediumColor(evaluation.category),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Deviasi dari rata-rata historis',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        // Consumption Comparison
        Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.compare_arrows, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Perbandingan Konsumsi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Divider(height: 24),

                _buildComparisonRow(
                  'Konsumsi Aktual',
                  '${numberFormat.format(evaluation.actualConsumption)} m³',
                  Colors.blue,
                ),
                SizedBox(height: 12),
                _buildComparisonRow(
                  'Rata-rata Historis',
                  '${numberFormat.format(evaluation.averageHistorical)} m³',
                  Colors.grey,
                ),
                SizedBox(height: 12),
                Divider(),
                SizedBox(height: 12),
                _buildComparisonRow(
                  'Selisih',
                  '${evaluation.deviation >= 0 ? '+' : ''}${numberFormat.format(evaluation.actualConsumption - evaluation.averageHistorical)} m³',
                  _getCategoryMainColor(evaluation.category),
                  isBold: true,
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        // Recommendation
        Card(
          elevation: 2,
          color: _getCategoryLightColor(evaluation.category),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: _getCategoryMainColor(evaluation.category),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Rekomendasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  _getRecommendationText(evaluation.category),
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        // Category Legend
        Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kategori Efisiensi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Divider(height: 24),
                _buildLegendItem(
                  'Efisien',
                  'Konsumsi lebih rendah dari rata-rata (≤ -10%)',
                  Colors.green,
                ),
                SizedBox(height: 8),
                _buildLegendItem(
                  'Normal',
                  'Konsumsi dalam batas wajar (-10% sampai +10%)',
                  Colors.orange,
                ),
                SizedBox(height: 8),
                _buildLegendItem(
                  'Boros',
                  'Konsumsi lebih tinggi dari rata-rata (> +10%)',
                  Colors.red,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonRow(String label, String value, Color color,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 16,
          height: 16,
          margin: EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getRecommendationText(EfficiencyCategory category) {
    switch (category) {
      case EfficiencyCategory.efficient:
        return '✓ Konsumsi gas bulan ini sangat baik! Pertahankan praktik operasional yang telah dilakukan.';
      case EfficiencyCategory.normal:
        return '• Konsumsi gas masih dalam batas normal. Lakukan monitoring berkala untuk menjaga efisiensi.';
      case EfficiencyCategory.wasteful:
        return '⚠ Konsumsi gas melebihi rata-rata. Periksa kondisi mesin dan proses produksi untuk menemukan potensi pemborosan.';
    }
  }
}

// ========== EFFICIENCY HISTORY SCREEN ==========

class EfficiencyHistoryScreen extends StatelessWidget {
  const EfficiencyHistoryScreen({Key? key}) : super(key: key);

  // ✅ Helper methods untuk warna
  Color _getCategoryMainColor(EfficiencyCategory category) {
    switch (category) {
      case EfficiencyCategory.efficient:
        return Colors.green;
      case EfficiencyCategory.normal:
        return Colors.orange;
      case EfficiencyCategory.wasteful:
        return Colors.red;
    }
  }

  Color _getCategoryLightColor(EfficiencyCategory category) {
    switch (category) {
      case EfficiencyCategory.efficient:
        return Colors.green.shade100;
      case EfficiencyCategory.normal:
        return Colors.orange.shade100;
      case EfficiencyCategory.wasteful:
        return Colors.red.shade100;
    }
  }

  Color _getCategoryShade50(EfficiencyCategory category) {
    switch (category) {
      case EfficiencyCategory.efficient:
        return Colors.green.shade50;
      case EfficiencyCategory.normal:
        return Colors.orange.shade50;
      case EfficiencyCategory.wasteful:
        return Colors.red.shade50;
    }
  }

  Color _getCategoryDarkColor(EfficiencyCategory category) {
    switch (category) {
      case EfficiencyCategory.efficient:
        return Colors.green.shade900;
      case EfficiencyCategory.normal:
        return Colors.orange.shade900;
      case EfficiencyCategory.wasteful:
        return Colors.red.shade900;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Evaluasi Efisiensi'),
      ),
      body: FutureBuilder<List<EfficiencyEvaluation>>(
        future: Provider.of<DataService>(context, listen: false)
            .getEfficiencyHistory(limit: 12),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                  SizedBox(height: 16),
                  Text('Belum ada riwayat evaluasi'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final eval = history[index];
              return _buildHistoryCard(eval);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(EfficiencyEvaluation eval) {
    final numberFormat = NumberFormat('#,##0.0', 'id_ID');

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryLightColor(eval.category),
          child: Icon(
            Icons.assessment,
            color: _getCategoryMainColor(eval.category),
          ),
        ),
        title: Text(
          eval.periodName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${numberFormat.format(eval.actualConsumption)} m³ • ${eval.categoryLabel}',
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getCategoryShade50(eval.category),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${eval.deviation >= 0 ? '+' : ''}${eval.deviation.toStringAsFixed(1)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getCategoryDarkColor(eval.category),
            ),
          ),
        ),
      ),
    );
  }
}