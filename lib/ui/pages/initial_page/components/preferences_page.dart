import 'package:cotizacion_dm/core/infrastructure/infrastructure.dart';
import 'package:cotizacion_dm/ui/bloc/setup_properties/setup_properties_cubit.dart';
import 'package:cotizacion_dm/ui/components/components.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  SetupPropertiesCubit get setupBloc => BlocProvider.of(context);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      slivers: [
        _appbar(),
        spacer,
        customPadding(heading("Datos Generales"), 10.0),
        customPadding(_buildBusinessProperties()),
        customPadding(_buildTaxPercentPropertie()),
        customPadding(_buildLocationPropertie()),
        customPadding(heading("Restablecer datos", () {
          AppSetup.reset().then((value) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil("/", (route) => false);
          });
        }, "Resetear"))
      ],
    );
  }

  Widget _buildTaxPercentPropertie() {
    var taxPercents = List.generate(10, (index) {
      var option = TaxPercentOption("${index + 15}%", (index + 15) / 100);

      return TaxPercentOptionDropwdownData(option);
    }).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const PreferencePropertieName("Impuestos (IVA)"),
        StreamBuilder<TaxPercentOption?>(
            stream: setupBloc.taxPercentOptionStream,
            builder: (context, snapshot) {
              return CustomDrowpdown<TaxPercentOption>(
                enabled: snapshot.data != null,
                value: snapshot.data,
                items: taxPercents,
                width: 80,
                onChange: setupBloc.setTaxPercentOption,
              );
            })
      ],
    );
  }

  Widget _buildLocationPropertie() {
    return _buildPropertie(setupBloc.locationStream,
        label: "Localizacion", callback: setupBloc.setLocation);
  }

  Column _buildBusinessProperties() {
    return Column(
      children: [
        _buildPropertie(
          setupBloc.nitStream,
          label: "NIT",
          callback: setupBloc.setNIT,
          formatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          inputType: TextInputType.number,
        ),
        _buildPropertie(setupBloc.businessNameStream,
            label: "Nombre de negocio", callback: setupBloc.setBusinessName),
      ],
    );
  }

  Widget _buildPropertie(Stream<String?> stream,
      {required String label,
      required Function(String) callback,
      List<TextInputFormatter> formatters = const [],
      TextInputType inputType = TextInputType.text}) {
    return StreamBuilder<String?>(
        stream: stream,
        builder: (context, snapshot) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PreferencePropertieName(label),
                  if (snapshot.data is String)
                    PreferencePropertieName(snapshot.data!, fontSize: 12),
                  if (snapshot.data == null)
                    const PreferencePropertieName("No configurado",
                        fontSize: 12),
                ],
              ),
              TextButton(
                  onPressed: () {
                    _showDialog(
                      label,
                      callback: callback,
                      value: snapshot.data ?? "",
                      formatters: formatters,
                      type: inputType,
                    );
                  },
                  child: const Text("Editar"))
            ],
          );
        });
  }

  Future<void> _showDialog(
    String label, {
    required Function(String) callback,
    required String value,
    List<TextInputFormatter> formatters = const [],
    TextInputType type = TextInputType.text,
  }) async {
    var res = await showDialog<String>(
        context: context,
        builder: (context) {
          return PropertieDialog(
            label: label,
            value: value,
            formatters: formatters,
            inputType: type,
          );
        });

    if (res is String) {
      callback(res);
    }
  }

  SliverAppBar _appbar() {
    return SliverAppBar(
      bottom: AppBar(
        title: const Text("Preferencias"),
        automaticallyImplyLeading: false,
      ),
    );
  }
}

class PreferencePropertieName extends StatelessWidget {
  final String title;
  final double fontSize;
  const PreferencePropertieName(
    this.title, {
    this.fontSize = 14.0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Text(
        title,
        maxLines: 2,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

class PayTypeDropdownData implements DropdownData<PayType> {
  final PayType type;

  PayTypeDropdownData(this.type);
  @override
  PayType value() {
    return type;
  }

  @override
  String toString() {
    return type.name;
  }
}

class TaxPercentOptionDropwdownData implements DropdownData<TaxPercentOption> {
  final TaxPercentOption option;

  TaxPercentOptionDropwdownData(this.option);
  @override
  TaxPercentOption value() {
    return option;
  }

  @override
  String toString() {
    return option.name;
  }
}

class CotizationTypeDropdownData implements DropdownData<bool> {
  final String label;
  final bool val;

  CotizationTypeDropdownData(this.label, this.val);

  @override
  bool value() {
    return val;
  }

  @override
  String toString() {
    return label;
  }
}
