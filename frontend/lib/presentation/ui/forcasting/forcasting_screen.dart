// lib/presentation/ui/forcasting/forcasting_screen.dart

import 'package:app/application/forcasting/forcasting_bloc.dart';
import 'package:app/application/forcasting/forcasting_event.dart';
import 'package:app/application/forcasting/forcasting_state.dart';
import 'package:app/domain/entity/forcasting_result_entity.dart';
import 'package:app/presentation/ui/common/custom_input_field.dart';
import 'package:app/presentation/ui/common/loading_button.dart';
import 'package:app/presentation/utils/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/constants/mappings.dart';

/// Replace these with your real season names:
const List<String> seasons = [
  'Belg',
  'Kiremt',
  'Bega',
];

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForcastingBloc, ForcastingState>(
      listener: (ctx, state) {
        if (state is ForcastingSuccess && widget.onSubmitted != null) {
          widget.onSubmitted!(state.forcastingResult);
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
          child: Column(children: [
            _buildDropdown('region', context.commonLocals.region),
            _buildDropdown('zone', context.commonLocals.zone),
            _buildDropdown('woreda', context.commonLocals.woreda),
            _buildDropdown('marketname', context.commonLocals.market_name),
            _buildDropdown('cropname', context.commonLocals.crop_type),
            _buildDropdown('varietyname', context.commonLocals.variety_name),
            _buildDropdown('season', context.commonLocals.season),  // <-- now a dropdown
            const SizedBox(height: 50),
            Center(child: _buildSubmitButton(context)),
          ]),
        ),
      ),
    );
  }

  Widget _buildDropdown(String key, String label) {
    List<String>? items;
    bool enabled = false;

    if (key == 'region') {
      items = regions;
      enabled = true;
    } else if (key == 'zone') {
      final parent = _formData['region'];
      items = parent != null ? regionZoneMapping[parent] : [];
      enabled = parent != null;
    } else if (key == 'woreda') {
      final parent = _formData['zone'];
      items = parent != null ? zoneWoredaMapping[parent] : [];
      enabled = parent != null;
    } else if (key == 'marketname') {
      final parent = _formData['woreda'];
      items = parent != null ? woredaMarketMapping[parent] : [];
      enabled = parent != null;
    } else if (key == 'cropname') {
      final parent = _formData['marketname'];
      items = parent != null ? marketCropNameMapping[parent] : [];
      enabled = parent != null;
    } else if (key == 'varietyname') {
      final parent = _formData['cropname'];
      items = parent != null ? cropNameVarietyMapping[parent] : [];
      enabled = parent != null;
    } else if (key == 'season') {
      items = seasons;
      enabled = true;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: CustomInputField(
        label: label,
        hintText: label,
        enabled: enabled,
        dropdownItems: items,
        selectedValue: _formData[key],
        onDropdownChanged: (val) {
          setState(() {
            _formData[key] = val;
            // clear downstream for hierarchical keys, season has none
            final clearMap = {
              'region': ['zone','woreda','marketname','cropname','varietyname','season'],
              'zone': ['woreda','marketname','cropname','varietyname','season'],
              'woreda': ['marketname','cropname','varietyname','season'],
              'marketname': ['cropname','varietyname','season'],
              'cropname': ['varietyname','season'],
              'varietyname': ['season'],
            };
            if (clearMap.containsKey(key)) {
              for (var k in clearMap[key]!) _formData[k] = null;
            }
          });
          _updateInputFieldData();
        },
        isRequired: true,
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
                      region: _formData['region'] != null ? [_formData['region']!] : [],
                      zone: _formData['zone'] != null ? [_formData['zone']!] : [],
                      woreda: _formData['woreda'] != null ? [_formData['woreda']!] : [],
                      marketname: _formData['marketname'] != null ? [_formData['marketname']!] : [],
                      cropname: _formData['cropname'] != null ? [_formData['cropname']!] : [],
                      varietyname: _formData['varietyname'] != null ? [_formData['varietyname']!] : [],
                      season: _formData['season'] != null ? [_formData['season']!] : [],
                    ),
                  );
            }
          },
        );
      },
    );
  }
}
