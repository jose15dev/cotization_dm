import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/core/infrastructure/configuration/setup.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

abstract class PDFCotizationService {
  Future<PdfDocument> exportToPDF(Cotization cotization);
}

@Injectable(as: PDFCotizationService)
class MainPDFCotizationService implements PDFCotizationService {
  var centerStringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle);
  var startStringFormat =
      PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle);
  var pdfStandardFont =
      PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.regular);
  var border = PdfBorders(
    top: PdfPen(PdfColor.empty, width: 0),
    bottom: PdfPen(PdfColor.empty, width: 0),
    left: PdfPen(PdfColor.empty, width: 0),
    right: PdfPen(PdfColor.empty, width: 0),
  );

  var pdfPaddings = PdfPaddings(
    bottom: 8.0,
    top: 8.0,
    left: 10.0,
    right: 10.0,
  );
  @override
  Future<PdfDocument> exportToPDF(Cotization cotization) async {
    PdfDocument document = PdfDocument();
    PdfPage page = document.pages.add();

    var taxPercent = cotization.tax ?? 0;
    var bussinessName = AppSetup.getBusinessName() ?? "";
    var location = AppSetup.getLocation() ?? "";
    var nit = AppSetup.getNIT() ?? "";

    PdfGrid grid = PdfGrid();

    grid.style.font = pdfStandardFont;

    var headers = ["Descripcion", "Unidad", "Cantidad", "V. Unit", "V. Total"];
    var data = cotization.items.map((e) {
      return [
        e.name,
        e.unit,
        e.amount.toString(),
        CurrencyUtility.doubleToCurrency(e.unitValue),
        CurrencyUtility.doubleToCurrency(e.total),
      ];
    }).toList();

    var totals = [
      {
        "Subtotal": CurrencyUtility.doubleToCurrency(cotization.total),
      },
    ];
    var num = (100 * taxPercent).toInt();
    totals.addAll([
      {
        "IVA ($num%)":
            CurrencyUtility.doubleToCurrency(cotization.total * taxPercent)
      },
      {
        "Total": CurrencyUtility.doubleToCurrency(
            cotization.total * (1 + taxPercent))
      }
    ]);

    var cols = headers.length;
    grid.columns.add(count: cols);

    _drawHeaders(grid.headers.add(1)[0], headers);

    _drawData(grid, data);
    _drawTotals(grid, totals);

    var width = page.getClientSize().width;
    var height = page.getClientSize().height;
    var fontBold =
        PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    var fontNormal = PdfStandardFont(PdfFontFamily.helvetica, 12,
        style: PdfFontStyle.regular);

    // Bussiness Name
    page.graphics.drawString(
      bussinessName,
      fontBold,
      bounds: const Rect.fromLTWH(0, 0, 300, 50),
    );

    // Location
    page.graphics.drawString(
      location,
      fontNormal,
      bounds: const Rect.fromLTWH(0, 40, 300, 50),
    );
    var load = await rootBundle.load("assets/img/qrcode.png");
    var bytes = load.buffer.asUint8List();
    // QR Code
    page.graphics
        .drawImage(PdfBitmap(bytes), Rect.fromLTWH(width - 50, 0, 50, 50));

    // Number of Cotization
    page.graphics.drawString(
      "Referencia:",
      fontBold,
      bounds: Rect.fromLTWH(width - 150, 70, 300, 50),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );

    page.graphics.drawString(
      cotization.id.toString(),
      fontBold,
      bounds: Rect.fromLTWH(width - 300, 70, 300, 50),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );

    // Date of cotization
    page.graphics.drawString(
      "Fecha:",
      fontBold,
      bounds: Rect.fromLTWH(width - 150, 90, 300, 50),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );

    var now = DateTime.now();
    var date = DateFormat("yyyy-MM-dd").format(now);

    page.graphics.drawString(
      date,
      fontBold,
      bounds: Rect.fromLTWH(width - 300, 90, 300, 50),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );

    // Nit
    page.graphics.drawString(
      "NIT:",
      fontBold,
      bounds: Rect.fromLTWH(width - 150, 110, 300, 50),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );
    page.graphics.drawString(
      nit,
      fontBold,
      bounds: Rect.fromLTWH(width - 300, 110, 300, 50),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );

    // Table
    page.graphics.drawString(
      cotization.isAccount ? "CUENTA DE COBRO" : "COTIZACION",
      PdfStandardFont(PdfFontFamily.helvetica, 20, style: PdfFontStyle.bold),
      bounds: const Rect.fromLTWH(0, 130, 300, 50),
    );

    page.graphics.drawString(
      cotization.description,
      PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.regular),
      bounds: const Rect.fromLTWH(0, 160, 300, 50),
    );

    var result = grid.draw(
      page: page,
      bounds: Rect.fromLTWH(
        0,
        200,
        width,
        600,
      ),
    );

    if (result is PdfLayoutResult) {
      var lastPage = result.page;
      lastPage.graphics.drawLine(PdfPen(PdfColor(0, 0, 0)),
          Offset(20, height - 120), Offset(200, height - 120));
      lastPage.graphics.drawString("Firma", fontBold,
          bounds: Rect.fromLTWH(20, height - 110, 300, 50));
    }
    return document;
  }

  void _drawHeaders(PdfGridRow row, List<String> headers) {
    for (int i = 0; i < headers.length; i++) {
      row.cells[i].value = headers[i];

      row.cells[i].style = PdfGridCellStyle(
          backgroundBrush: PdfSolidBrush(PdfColor(104, 114, 255)),
          textBrush: PdfBrushes.whiteSmoke,
          borders: border,
          format: PdfStringFormat(
            alignment: i == 0 ? PdfTextAlignment.left : PdfTextAlignment.right,
          ),
          cellPadding: pdfPaddings);
    }

    row.style = PdfGridRowStyle(
      backgroundBrush: PdfBrushes.cadetBlue,
      font: PdfStandardFont(PdfFontFamily.helvetica, 12,
          style: PdfFontStyle.bold),
    );
  }

  void _drawData(PdfGrid grid, List<List<String>> data) {
    for (int i = 0; i < data.length; i++) {
      var row = grid.rows.add();

      for (int j = 0; j < data[i].length; j++) {
        row.cells[j].value = data[i][j];
        row.cells[j].style = PdfGridCellStyle(
          borders: border,
          cellPadding: pdfPaddings,
          textBrush: PdfBrushes.darkSlateGray,
        );
        if (j > 0) {
          row.cells[j].style.stringFormat =
              PdfStringFormat(alignment: PdfTextAlignment.right);
        }
        if (i == data.length - 1) {
          row.cells[j].style.borders = PdfBorders(
            bottom: PdfPen(PdfColor(0, 0, 0), width: 2),
            top: PdfPen(
              PdfColor.empty,
              width: 0,
            ),
            left: PdfPen(
              PdfColor.empty,
              width: 0,
            ),
            right: PdfPen(
              PdfColor.empty,
              width: 0,
            ),
          );
        }
      }
    }
  }

  void _drawTotals(PdfGrid grid, List<Map<String, String>> totals) {
    for (int i = 0; i < totals.length; i++) {
      var row = grid.rows.add();
      row.cells[0].columnSpan = 3;

      var key = totals[i].keys.toList()[0];
      row.cells[3].value = key;
      row.cells[4].value = totals[i][key];
      var font = PdfStandardFont(PdfFontFamily.helvetica, 12,
          style: PdfFontStyle.bold);
      row.cells[0].style = PdfGridCellStyle(
        font: font,
        borders: border,
      );

      row.cells[3].style = PdfGridCellStyle(
        borders: border,
        font: font,
      );

      row.cells[4].style = PdfGridCellStyle(
        borders: border,
        font: font,
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
        cellPadding: PdfPaddings(
          right: 10.0,
          bottom: 5.0,
        ),
      );

      if (i == 0) {
        row.cells[0].style.cellPadding = PdfPaddings(top: 10.0);
        row.cells[3].style.cellPadding = PdfPaddings(top: 10.0);
        row.cells[4].style.cellPadding = PdfPaddings(top: 10.0, right: 10.0);
      }

      if (i == totals.length - 1) {
        row.cells[3].style.borders = PdfBorders(
          bottom: PdfPen(PdfColor(0, 0, 0), width: 2),
          left: PdfPen(PdfColor.empty),
          right: PdfPen(PdfColor.empty),
          top: PdfPen(PdfColor(0, 0, 0), width: 2),
        );

        row.cells[3].style.stringFormat =
            PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle);
        row.cells[4].style.borders = PdfBorders(
          bottom: PdfPen(PdfColor(0, 0, 0), width: 2),
          left: PdfPen(PdfColor.empty),
          right: PdfPen(PdfColor.empty),
          top: PdfPen(PdfColor(0, 0, 0), width: 2),
        );
        row.cells[4].style.stringFormat = PdfStringFormat(
            lineAlignment: PdfVerticalAlignment.middle,
            alignment: PdfTextAlignment.right);
      }
    }
  }
}
