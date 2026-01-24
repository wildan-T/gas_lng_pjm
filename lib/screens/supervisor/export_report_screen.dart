import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../../services/data_service.dart';
import '../../services/export_service.dart';

class ExportReportScreen extends StatefulWidget {
  const ExportReportScreen({Key? key}) : super(key: key);

  @override
  _ExportReportScreenState createState() => _ExportReportScreenState();
}

class _ExportReportScreenState extends State<ExportReportScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  bool _isExporting = false;
  String _exportFormat = 'PDF'; // 'PDF' or 'Excel'

  Future<void> _exportReport() async {
    setState(() => _isExporting = true);

    try {
      final dataService = Provider.of<DataService>(context, listen: false);

      // Get summary
      final summary = await dataService.getMonthlySummary(
        _selectedYear,
        _selectedMonth,
      );

      // Validate data
      if (summary['recordCount'] == 0) {
        if (mounted) {
          setState(() => _isExporting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak ada data verified untuk periode ini'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Get all verified records for the month
      final allRecords = await dataService.getGasRecords();
      final startDate = DateTime(_selectedYear, _selectedMonth, 1);
      final endDate = DateTime(
        _selectedYear,
        _selectedMonth + 1,
        0,
        23,
        59,
        59,
      );

      final monthRecords = allRecords
          .where(
            (r) =>
                r.timestamp.isAfter(startDate) &&
                r.timestamp.isBefore(endDate) &&
                r.isVerified,
          )
          .toList();

      File exportedFile;

      if (_exportFormat == 'PDF') {
        exportedFile = await ExportService.generateMonthlyReportPDF(
          year: _selectedYear,
          month: _selectedMonth,
          summary: summary,
          records: monthRecords,
        );
      } else {
        exportedFile = await ExportService.generateMonthlyReportExcel(
          year: _selectedYear,
          month: _selectedMonth,
          summary: summary,
          records: monthRecords,
        );
      }

      if (mounted) {
        setState(() => _isExporting = false);

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Berhasil'),
              ],
            ),
            content: Text(
              'Laporan berhasil dibuat!\n\nFile: ${exportedFile.path.split('/').last}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Tutup'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await OpenFile.open(exportedFile.path);
                },
                child: Text('Buka File'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat.MMMM(
      'id_ID',
    ).format(DateTime(_selectedYear, _selectedMonth));

    return Scaffold(
      appBar: AppBar(title: Text('Export Laporan')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Periode Laporan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      onTap: _selectMonth,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_month, color: Colors.blue),
                                SizedBox(width: 12),
                                Text(
                                  '$monthName $_selectedYear',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Format Export',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _exportFormat = 'PDF'),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _exportFormat == 'PDF'
                                    ? Colors.blue.shade50
                                    : Colors.white,
                                border: Border.all(
                                  color: _exportFormat == 'PDF'
                                      ? Colors.blue
                                      : Colors.grey,
                                  width: _exportFormat == 'PDF' ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf,
                                    size: 48,
                                    color: _exportFormat == 'PDF'
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'PDF',
                                    style: TextStyle(
                                      fontWeight: _exportFormat == 'PDF'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () =>
                                setState(() => _exportFormat = 'Excel'),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _exportFormat == 'Excel'
                                    ? Colors.green.shade50
                                    : Colors.white,
                                border: Border.all(
                                  color: _exportFormat == 'Excel'
                                      ? Colors.green
                                      : Colors.grey,
                                  width: _exportFormat == 'Excel' ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.table_chart,
                                    size: 48,
                                    color: _exportFormat == 'Excel'
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Excel',
                                    style: TextStyle(
                                      fontWeight: _exportFormat == 'Excel'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _exportReport,
                icon: _isExporting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.download),
                label: Text(
                  _isExporting ? 'Membuat Laporan...' : 'Export Laporan',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Laporan akan berisi ringkasan, detail konsumsi harian, dan rekomendasi.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
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
    }
  }
}
