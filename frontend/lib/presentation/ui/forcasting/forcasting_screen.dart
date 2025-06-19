import 'package:app/application/forcasting/forcasting_bloc.dart';
import 'package:app/application/forcasting/forcasting_event.dart';
import 'package:app/application/forcasting/forcasting_state.dart';
import 'package:app/domain/entity/forcasting_result_entity.dart';
import 'package:app/presentation/utils/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/constants/mappings.dart';
import 'package:app/presentation/ui/common/loading_button.dart';
import 'package:go_router/go_router.dart';

const List<String> seasons = ['Belg', 'Kiremt', 'Bega'];

class ForcastingScreen extends StatefulWidget {
  final void Function(ForcastingResultEntity result)? onSubmitted;

  const ForcastingScreen({super.key, this.onSubmitted});

  @override
  State<ForcastingScreen> createState() => _ForcastingScreenState();
}

class _ForcastingScreenState extends State<ForcastingScreen> {
  final Map<String, String?> _formData = {
    'region': null,
    'zone': null,
    'woreda': null,
    'marketname': null,
    'cropname': null,
    'varietyname': null,
    'season': null,
  };

  final Map<String, GlobalKey> _fieldKeys = {
    'region': GlobalKey(),
    'zone': GlobalKey(),
    'woreda': GlobalKey(),
    'marketname': GlobalKey(),
    'cropname': GlobalKey(),
    'varietyname': GlobalKey(),
    'season': GlobalKey(),
  };

  final _formKey = GlobalKey<FormState>();

  void _updateInputFieldData() {
    context.read<ForcastingBloc>().add(
          UpdateInputFieldEvent(
            _formData['region'] != null ? [_formData['region']!] : [],
            _formData['zone'] != null ? [_formData['zone']!] : [],
            _formData['woreda'] != null ? [_formData['woreda']!] : [],
            _formData['marketname'] != null ? [_formData['marketname']!] : [],
            _formData['cropname'] != null ? [_formData['cropname']!] : [],
            _formData['varietyname'] != null ? [_formData['varietyname']!] : [],
            _formData['season'] != null ? [_formData['season']!] : [],
          ),
        );
  }

  Future<void> _showCustomDropdown(
      String key, BuildContext context, List<String> items) async {
    final renderBox =
        _fieldKeys[key]!.currentContext!.findRenderObject() as RenderBox;

    final offset = renderBox.localToGlobal(Offset.zero);

    final size = renderBox.size;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          offset.dx, offset.dy + size.height, offset.dx + size.width, 0),
      color: Theme.of(context).indicatorColor,
      items: items
          .map(
            (item) => PopupMenuItem(
              value: item,
              child: SizedBox(
                width: size.width,
                child: Text(
                  item,
                  style: TextStyle(color: Theme.of(context).focusColor),
                ),
              ),
            ),
          )
          .toList(),
    );

    if (selected != null) {
      setState(() {
        _formData[key] = selected;

        final clearMap = {
          'region': [
            'zone',
            'woreda',
            'marketname',
            'cropname',
            'varietyname',
            'season'
          ],
          'zone': ['woreda', 'marketname', 'cropname', 'varietyname', 'season'],
          'woreda': ['marketname', 'cropname', 'varietyname', 'season'],
          'marketname': ['cropname', 'varietyname', 'season'],
          'cropname': ['varietyname', 'season'],
          'varietyname': ['season'],
        };

        if (clearMap.containsKey(key)) {
          for (var k in clearMap[key]!) {
            _formData[k] = null;
          }
        }
      });

      _updateInputFieldData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForcastingBloc, ForcastingState>(
      listener: (ctx, state) {
        if (state is ForcastingSuccess && widget.onSubmitted != null) {
          GoRouter.of(ctx)
              .push('/forecast-output', extra: state.forcastingResult);
        }

        if (state is ForcastingFailure) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(context.commonLocals.assessment_failed)),
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildDropdown('region', context.commonLocals.region),
              _buildDropdown('zone', context.commonLocals.zone),
              _buildDropdown('woreda', context.commonLocals.woreda),
              _buildDropdown('marketname', context.commonLocals.market_name),
              _buildDropdown('cropname', context.commonLocals.crop_type),
              _buildDropdown('varietyname', context.commonLocals.variety_name),
              _buildDropdown('season', context.commonLocals.season),
              const SizedBox(height: 50),
              Center(child: _buildSubmitButton(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String key, String label) {
    List<String>? items;

    bool enabled = false;

    switch (key) {
      case 'region':
        items = regions;

        enabled = true;

        break;

      case 'zone':
        final parent = _formData['region'];

        items = parent != null ? regionZoneMapping[parent] : [];

        enabled = parent != null;

        break;

      case 'woreda':
        final parent = _formData['zone'];

        items = parent != null ? zoneWoredaMapping[parent] : [];

        enabled = parent != null;

        break;

      case 'marketname':
        final parent = _formData['woreda'];

        items = parent != null ? woredaMarketMapping[parent] : [];

        enabled = parent != null;

        break;

      case 'cropname':
        final parent = _formData['marketname'];

        items = parent != null ? marketCropNameMapping[parent] : [];

        enabled = parent != null;

        break;

      case 'varietyname':
        final parent = _formData['cropname'];

        items = parent != null ? cropNameVarietyMapping[parent] : [];

        enabled = parent != null;

        break;

      case 'season':
        items = seasons;

        enabled = true;

        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: GestureDetector(
        onTap: enabled && items != null
            ? () => _showCustomDropdown(key, context, items!)
            : null,
        child: Container(
          key: _fieldKeys[key],
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: enabled
                  ? const Color.fromARGB(255, 148, 196, 149)
                  : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _formData[key] ?? label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: _formData[key] != null
                        ? FontWeight.w300
                        : FontWeight.normal,
                    color: enabled
                        ? (_formData[key] != null
                            ? Theme.of(context).focusColor
                            : Colors.grey)
                        : Colors.grey,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: enabled
                    ? const Color.fromARGB(255, 148, 196, 149)
                    : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext ctx) {
    return BlocBuilder<ForcastingBloc, ForcastingState>(
      builder: (c, state) {
        final loading = state is ForcastingLoading;

        return LoadingButton(
          label: ctx.commonLocals.submit,
          loading: loading,
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              context.read<ForcastingBloc>().add(
                    SubmitForcastingEvent(
                      region: _formData['region'] != null
                          ? [_formData['region']!]
                          : [],
                      zone:
                          _formData['zone'] != null ? [_formData['zone']!] : [],
                      woreda: _formData['woreda'] != null
                          ? [_formData['woreda']!]
                          : [],
                      marketname: _formData['marketname'] != null
                          ? [_formData['marketname']!]
                          : [],
                      cropname: _formData['cropname'] != null
                          ? [_formData['cropname']!]
                          : [],
                      varietyname: _formData['varietyname'] != null
                          ? [_formData['varietyname']!]
                          : [],
                      season: _formData['season'] != null
                          ? [_formData['season']!]
                          : [],
                    ),
                  );
            }
          },
        );
      },
    );
  }
}
