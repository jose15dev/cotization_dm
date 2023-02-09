import 'dart:ui';

import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/core/infrastructure/configuration/setup.dart';
import 'package:cotizacion_dm/shared/utilities/utilities.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
    var width = page.getClientSize().width;
    var height = page.getClientSize().height;
    var taxPercent = cotization.tax ?? 0;
    var bussinessName = AppSetup.getBusinessName() ?? "";
    var location = AppSetup.getLocation() ?? "";
    var nit = AppSetup.getNIT() ?? "";

    List<Map<String, dynamic>> listPosition = [
      // App Bussiness Name
      {
        "text": bussinessName,
        "top": 0.0,
        "left": 0.0,
        "width": 100.0,
        "height": 50.0,
        "style": PdfFontStyle.bold,
        "size": 20.0,
      },

      // App Bussiness Location
      {
        "text": location,
        "top": 40.0,
        "left": 0.0,
        "width": 100.0,
        "height": 20.0,
      },

      // Cotization Reference Id
      {
        "text": "Referencia",
        "top": 100.0,
        "left": 0.0,
        "width": 100.0,
        "height": 20.0,
        "style": PdfFontStyle.bold,
      },
      {
        "text": cotization.id?.toString(),
        "top": 100.0,
        "left": 150.0,
        "width": 50.0,
        "height": 20.0,
        "aligment": PdfTextAlignment.right,
      },
      // Cotization Date
      {
        "text": "Fecha",
        "top": 120.0,
        "left": 0.0,
        "width": 100.0,
        "height": 20.0,
        "style": PdfFontStyle.bold,
      },
      {
        "text": DateFormat.yMd().format(cotization.createdAt),
        "top": 120.0,
        "left": 150.0,
        "width": 50.0,
        "height": 20.0,
        "aligment": PdfTextAlignment.right,
      },
      // App Bussiness Nit
      {
        "text": "NIT",
        "top": 140.0,
        "left": 0.0,
        "width": 100.0,
        "height": 20.0,
        "style": PdfFontStyle.bold,
      },
      {
        "text": nit,
        "top": 140.0,
        "left": 100.0,
        "width": 100.0,
        "height": 20.0,
        "aligment": PdfTextAlignment.right,
      },

      // Table Title Above Header
      {
        "text": cotization.isAccount ? "CUENTA DE COBRO" : "COTIZACIÓN",
        "top": 200.0,
        "left": 0.0,
        "width": 200.0,
        "height": 50.0,
        "style": PdfFontStyle.bold,
        "size": 20.0,
      },
// Client Name
      {
        "text": "A nombre de: ",
        "top": 250.0,
        "left": 0.0,
        "width": 100.0,
        "height": 20.0,
        "style": PdfFontStyle.bold,
      },

      {
        "text": cotization.name,
        "top": 250.0,
        "left": 100.0,
        "width": width,
        "height": 20.0,
      },
      // Cotization Description
      {
        "text": "Descripción:",
        "top": 270.0,
        "left": 0.0,
        "width": 100.0,
        "height": 20.0,
        "size": 12.0,
        "style": PdfFontStyle.bold,
      },
      {
        "text": cotization.description,
        "top": 290.0,
        "left": 0.0,
        "width": width,
        "height": 100.0,
        "size": 12.0,
        "lineAligment": PdfVerticalAlignment.top,
      }
    ];

    for (Map<String, dynamic> item in listPosition) {
      page.graphics.drawString(
        item["text"],
        PdfStandardFont(PdfFontFamily.helvetica, item["size"] ?? 12,
            style: item["style"] ?? PdfFontStyle.regular),
        bounds: Rect.fromLTWH(
            item["left"], item["top"], item["width"], item["height"]),
        format: PdfStringFormat(
          alignment: item["aligment"] ?? PdfTextAlignment.left,
          lineAlignment: item["lineAligment"] ?? PdfVerticalAlignment.middle,
        ),
      );
    }

    //QR Code
    double qrSize = 150.0;
    var qrBytes = (await (await QrPainter(
      data: cotizationToQrCode(cotization),
      version: QrVersions.auto,
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.circle,
        color: ColorPalete.black,
      ),
      gapless: false,
    ).toImage(1440))
            .toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();

    page.graphics.drawImage(
        PdfBitmap(qrBytes), Rect.fromLTWH(width - qrSize, 40, qrSize, qrSize));

    // Table

    PdfGrid grid = PdfGrid();

    grid.style.font = pdfStandardFont;

    var headers = ["Concepto", "Unidad", "Cantidad", "V. Unit", "V. Total"];
    var data = cotization.items.map((e) {
      return [
        "${e.name}. ${e.description}.",
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

    var fontBold =
        PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);

    var result = grid.draw(
      page: page,
      bounds: Rect.fromLTWH(
        0,
        350,
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
