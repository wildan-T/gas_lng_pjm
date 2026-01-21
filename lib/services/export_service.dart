import 'dart:io';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:intl/intl.dart';
import '../models/gas_record_model.dart';

class ExportService {
  // ========== PDF EXPORT ==========
  
  static Future<File> generateMonthlyReportPDF({
    required int year,
    required int month,
    required Map<String, dynamic> summary,
    required List<GasRecord> records,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final numberFormat = NumberFormat('#,##0.0', 'id_ID');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final monthName = DateFormat.MMMM('id_ID').format(DateTime(year, month));

    // Null safety defaults
    final totalConsumption = (summary['totalConsumption'] ?? 0.0) as double;
    final totalCost = (summary['totalCost'] ?? 0.0) as double;
    final avgDaily = (summary['avgDaily'] ?? 0.0) as double;
    final recordCount = summary['recordCount'] ?? 0;
    final pricePerM3 = (summary['pricePerM3'] ?? 0.0) as double;

    // Cover Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'LAPORAN KONSUMSI GAS LNG',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'PT Panata Jaya Mandiri',
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Periode
              pw.Container(
                padding: pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Periode Laporan',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '$monthName $year',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Tanggal Cetak',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now()),
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Summary Cards
              pw.Text(
                'RINGKASAN',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Total Konsumsi',
                            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '${numberFormat.format(totalConsumption)} m3',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.green50,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Total Biaya',
                            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            currencyFormat.format(totalCost),
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.orange50,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Rata-rata Harian',
                            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '${numberFormat.format(avgDaily)} m3',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.orange900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.purple50,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Total Records',
                            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '$recordCount',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.purple900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Machine Consumption
              pw.Text(
                'KONSUMSI PER MESIN',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Nama Mesin',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Total Konsumsi (m3)',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Persentase',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  // Data
                  ...((summary['machineConsumption'] ?? {}) as Map<String, double>)
                      .entries
                      .map((entry) {
                    final percentage = totalConsumption > 0
                        ? (entry.value / totalConsumption * 100)
                        : 0.0;
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(entry.key),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            numberFormat.format(entry.value),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '${percentage.toStringAsFixed(1)}%',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Detail Records Page
    if (records.isNotEmpty) {
      final recordChunks = <List<GasRecord>>[];
      for (var i = 0; i < records.length; i += 15) {
        recordChunks.add(
          records.sublist(i, i + 15 > records.length ? records.length : i + 15),
        );
      }

      for (var chunk in recordChunks) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'DETAIL KONSUMSI HARIAN',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    columnWidths: {
                      0: pw.FixedColumnWidth(80),
                      1: pw.FixedColumnWidth(120),
                      2: pw.FixedColumnWidth(80),
                      3: pw.FixedColumnWidth(100),
                      4: pw.FixedColumnWidth(80),
                    },
                    children: [
                      // Header
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          _buildTableCell('Tanggal', isHeader: true),
                          _buildTableCell('Mesin', isHeader: true),
                          _buildTableCell('Jumlah (m3)', isHeader: true, align: pw.TextAlign.right),
                          _buildTableCell('Operator', isHeader: true),
                          _buildTableCell('Status', isHeader: true, align: pw.TextAlign.center),
                        ],
                      ),
                      // Data
                      ...chunk.map((record) {
                        return pw.TableRow(
                          children: [
                            _buildTableCell(
                              DateFormat('dd/MM/yy\nHH:mm', 'id_ID').format(record.timestamp),
                            ),
                            _buildTableCell(record.machineName),
                            _buildTableCell(
                              numberFormat.format(record.amount),
                              align: pw.TextAlign.right,
                            ),
                            _buildTableCell(record.operatorName),
                            _buildTableCell(
                              record.isVerified ? 'Verified' : 'Pending',
                              align: pw.TextAlign.center,
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      }
    }

    // Kesimpulan & Rekomendasi
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          final machineData = (summary['machineConsumption'] ?? {}) as Map<String, double>;
          final maxMachine = machineData.isNotEmpty
              ? machineData.entries.reduce((a, b) => a.value > b.value ? a : b)
              : null;

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'KESIMPULAN & REKOMENDASI',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                padding: pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Kesimpulan:',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      '- Total konsumsi gas LNG pada periode $monthName $year adalah ${numberFormat.format(totalConsumption)} m3',
                      style: pw.TextStyle(fontSize: 11),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '- Dengan total biaya ${currencyFormat.format(totalCost)}',
                      style: pw.TextStyle(fontSize: 11),
                    ),
                    pw.SizedBox(height: 4),
                    if (maxMachine != null) ...[
                      pw.Text(
                        '- Mesin dengan konsumsi tertinggi adalah ${maxMachine.key} (${numberFormat.format(maxMachine.value)} m3)',
                        style: pw.TextStyle(fontSize: 11),
                      ),
                      pw.SizedBox(height: 4),
                    ],
                    pw.Text(
                      '- Rata-rata konsumsi harian: ${numberFormat.format(avgDaily)} m3',
                      style: pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                padding: pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Rekomendasi:',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    if (maxMachine != null) ...[
                      pw.Text(
                        '- Lakukan maintenance rutin pada ${maxMachine.key} mengingat konsumsi gas yang tinggi',
                        style: pw.TextStyle(fontSize: 11),
                      ),
                      pw.SizedBox(height: 4),
                    ],
                    pw.Text(
                      '- Monitor pola konsumsi harian untuk deteksi dini anomali',
                      style: pw.TextStyle(fontSize: 11),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '- Evaluasi efisiensi penggunaan gas pada jam operasional tertentu',
                      style: pw.TextStyle(fontSize: 11),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '- Pastikan operator selalu melampirkan foto meteran untuk akurasi data',
                      style: pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              pw.Spacer(),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Dicetak oleh: Sistem Gas LNG Monitoring',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                  ),
                  pw.Text(
                    'PT Panata Jaya Mandiri',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Save PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/laporan_gas_${monthName}_$year.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }

  // ========== EXCEL EXPORT ==========

  static Future<File> generateMonthlyReportExcel({
    required int year,
    required int month,
    required Map<String, dynamic> summary,
    required List<GasRecord> records,
  }) async {
    final xlsio.Workbook workbook = xlsio.Workbook();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final numberFormat = NumberFormat('#,##0.0', 'id_ID');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final monthName = DateFormat.MMMM('id_ID').format(DateTime(year, month));

    // Null safety defaults
    final totalConsumption = (summary['totalConsumption'] ?? 0.0) as double;
    final totalCost = (summary['totalCost'] ?? 0.0) as double;
    final avgDaily = (summary['avgDaily'] ?? 0.0) as double;
    final recordCount = summary['recordCount'] ?? 0;
    final pricePerM3 = (summary['pricePerM3'] ?? 0.0) as double;

    // ========== SHEET 1: RINGKASAN ==========
    final xlsio.Worksheet summarySheet = workbook.worksheets[0];
    summarySheet.name = 'Ringkasan';

    // Title
    summarySheet.getRangeByName('A1').setText('LAPORAN KONSUMSI GAS LNG');
    summarySheet.getRangeByName('A1').cellStyle.fontSize = 16;
    summarySheet.getRangeByName('A1').cellStyle.bold = true;

    summarySheet.getRangeByName('A2').setText('PT Panata Jaya Mandiri');
    summarySheet.getRangeByName('A3').setText('Periode: $monthName $year');
    summarySheet.getRangeByName('A3').cellStyle.bold = true;

    // Summary Data
    int row = 5;
    summarySheet.getRangeByName('A$row').setText('RINGKASAN KONSUMSI');
    summarySheet.getRangeByName('A$row').cellStyle.bold = true;
    summarySheet.getRangeByName('A$row').cellStyle.fontSize = 12;
    row += 2;

    summarySheet.getRangeByName('A$row').setText('Total Konsumsi');
    summarySheet.getRangeByName('B$row').setText('${numberFormat.format(totalConsumption)} m3');
    row++;

    summarySheet.getRangeByName('A$row').setText('Total Biaya');
    summarySheet.getRangeByName('B$row').setText(currencyFormat.format(totalCost));
    row++;

    summarySheet.getRangeByName('A$row').setText('Rata-rata Harian');
    summarySheet.getRangeByName('B$row').setText('${numberFormat.format(avgDaily)} m3');
    row++;

    summarySheet.getRangeByName('A$row').setText('Total Records');
    summarySheet.getRangeByName('B$row').setText('$recordCount');
    row++;

    summarySheet.getRangeByName('A$row').setText('Harga Gas per m3');
    summarySheet.getRangeByName('B$row').setText(currencyFormat.format(pricePerM3));
    row += 2;

    // Machine Consumption
    summarySheet.getRangeByName('A$row').setText('KONSUMSI PER MESIN');
    summarySheet.getRangeByName('A$row').cellStyle.bold = true;
    summarySheet.getRangeByName('A$row').cellStyle.fontSize = 12;
    row += 2;

    summarySheet.getRangeByName('A$row').setText('Nama Mesin');
    summarySheet.getRangeByName('B$row').setText('Total Konsumsi (m3)');
    summarySheet.getRangeByName('C$row').setText('Persentase');
    summarySheet.getRangeByName('A$row:C$row').cellStyle.bold = true;
    summarySheet.getRangeByName('A$row:C$row').cellStyle.backColor = '#D9E1F2';
    row++;

    final machineData = (summary['machineConsumption'] ?? {}) as Map<String, double>;
    for (var entry in machineData.entries) {
      final percentage = totalConsumption > 0
          ? (entry.value / totalConsumption * 100)
          : 0.0;
      summarySheet.getRangeByName('A$row').setText(entry.key);
      summarySheet.getRangeByName('B$row').setNumber(entry.value);
      summarySheet.getRangeByName('C$row').setText('${percentage.toStringAsFixed(1)}%');
      row++;
    }

    summarySheet.getRangeByName('A1:C$row').autoFitColumns();

    // ========== SHEET 2: DETAIL RECORDS ==========
    workbook.worksheets.addWithName('DetailKonsumsi');
    final xlsio.Worksheet detailSheet = workbook.worksheets[1];

    // Header
    detailSheet.getRangeByName('A1').setText('DETAIL KONSUMSI HARIAN');
    detailSheet.getRangeByName('A1').cellStyle.fontSize = 14;
    detailSheet.getRangeByName('A1').cellStyle.bold = true;

    // Table Header
    row = 3;
    detailSheet.getRangeByName('A$row').setText('Tanggal & Waktu');
    detailSheet.getRangeByName('B$row').setText('Mesin');
    detailSheet.getRangeByName('C$row').setText('Jumlah (m3)');
    detailSheet.getRangeByName('D$row').setText('Operator');
    detailSheet.getRangeByName('E$row').setText('Status');
    detailSheet.getRangeByName('F$row').setText('Catatan');
    detailSheet.getRangeByName('A$row:F$row').cellStyle.bold = true;
    detailSheet.getRangeByName('A$row:F$row').cellStyle.backColor = '#D9E1F2';
    row++;

    // Data
    for (var record in records) {
      detailSheet.getRangeByName('A$row').setText(dateFormat.format(record.timestamp));
      detailSheet.getRangeByName('B$row').setText(record.machineName);
      detailSheet.getRangeByName('C$row').setNumber(record.amount);
      detailSheet.getRangeByName('D$row').setText(record.operatorName);
      detailSheet.getRangeByName('E$row').setText(record.isVerified ? 'Verified' : 'Pending');
      detailSheet.getRangeByName('F$row').setText(record.notes ?? '-');
      row++;
    }

    detailSheet.getRangeByName('A1:F$row').autoFitColumns();

    // Save Excel
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/laporan_gas_${monthName}_$year.xlsx');
    await file.writeAsBytes(bytes);
    return file;
  }
}