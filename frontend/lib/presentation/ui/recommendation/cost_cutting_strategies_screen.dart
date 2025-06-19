import 'package:app/application/recommendation/cost_cutting_strategies/cost_cutting_strategies_bloc.dart';
import 'package:app/application/recommendation/cost_cutting_strategies/cost_cutting_strategies_event.dart';
import 'package:app/application/recommendation/cost_cutting_strategies/cost_cutting_strategies_state.dart';
import 'package:app/domain/dto/cost_cutting_strategies_dto.dart';
import 'package:app/presentation/ui/common/loading_button.dart';
import 'package:app/presentation/utils/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CostCuttingStrategiesScreen extends StatefulWidget {
  final VoidCallback? onSubmitted;

  const CostCuttingStrategiesScreen({super.key, this.onSubmitted});

  @override
  State<CostCuttingStrategiesScreen> createState() => _CostCuttingStrategiesScreenState();
}

class _CostCuttingStrategiesScreenState extends State<CostCuttingStrategiesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _farmSizeController = TextEditingController();
  final TextEditingController _fertilizerExpenseController = TextEditingController();
  final TextEditingController _laborExpenseController = TextEditingController();
  final TextEditingController _pesticideExpenseController = TextEditingController();
  final TextEditingController _equipmentExpenseController = TextEditingController();
  final TextEditingController _transportationExpenseController = TextEditingController();
  final TextEditingController _seedExpenseController = TextEditingController();
  final TextEditingController _utilityExpenseController = TextEditingController();

  final List<String> _cropTypes = [
    'Teff', 'Wheat', 'Maize', 'Sorghum', 'Barley', 'Coffee', 'Sesame', 'Haricot Beans'
  ];
  final List<String> _seasons = [
    'Belg', 'Bega', 'Kiremt', 'Tsedey'
  ];

  final Map<String, String?> _formData = {
    'cropType': null,
    'season': null,
  };

  final Map<String, GlobalKey> _fieldKeys = {
    'cropType': GlobalKey(),
    'season': GlobalKey(),
  };

  @override
  void dispose() {
    _farmSizeController.dispose();
    _fertilizerExpenseController.dispose();
    _laborExpenseController.dispose();
    _pesticideExpenseController.dispose();
    _equipmentExpenseController.dispose();
    _transportationExpenseController.dispose();
    _seedExpenseController.dispose();
    _utilityExpenseController.dispose();
    super.dispose();
  }

  Future<void> _showPopupDropdown({
    required String key,
    required List<String> items,
  }) async {
    final renderBox = _fieldKeys[key]!.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        0,
      ),
      color: Theme.of(context).indicatorColor,
      items: items
          .map((item) => PopupMenuItem(
                value: item,
                child: SizedBox(
                  width: size.width,
                  child: Text(item, style: TextStyle(color: Theme.of(context).focusColor)),
                ),
              ))
          .toList(),
    );

    if (selected != null) {
      setState(() {
        _formData[key] = selected;
      });
    }
  }

  Widget _buildStyledDropdown({
    required String key,
    required String label,
    required List<String> items,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: GestureDetector(
        onTap: () => _showPopupDropdown(key: key, items: items),
        child: Container(
          key: _fieldKeys[key],
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(255, 148, 196, 149)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _formData[key] ?? label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: _formData[key] != null ? FontWeight.w300 : FontWeight.normal,
                    color: _formData[key] != null ? Theme.of(context).focusColor : Colors.grey,
                  ),
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Color.fromARGB(255, 148, 196, 149)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyledNumberField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color.fromARGB(255, 148, 196, 149)),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          border: border,
          enabledBorder: border,
          focusedBorder: border,
          errorBorder: errorBorder,
          focusedErrorBorder: errorBorder,
        ),
        validator: (val) {
          if (val == null || val.trim().isEmpty) return '$label ${context.commonLocals.is_required}';
          if (double.tryParse(val.trim()) == null) return context.commonLocals.enter_valid_number;
          return null;
        },
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_formData['cropType'] == null || _formData['season'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.commonLocals.fill_all_fields)),
        );
        return;
      }

      try {
        final farmInput = FarmInput(
          farmSizeHectares: double.parse(_farmSizeController.text),
          cropType: _formData['cropType']!.toLowerCase(),
          season: _formData['season']!.toLowerCase(),
          fertilizerExpenseETB: double.parse(_fertilizerExpenseController.text),
          laborExpenseETB: double.parse(_laborExpenseController.text),
          pesticideExpenseETB: double.parse(_pesticideExpenseController.text),
          equipmentExpenseETB: double.parse(_equipmentExpenseController.text),
          transportationExpenseETB: double.parse(_transportationExpenseController.text),
          seedExpenseETB: double.parse(_seedExpenseController.text),
          utilityExpenseETB: double.parse(_utilityExpenseController.text),
        );

        context.read<RecommendationBloc>().add(
          GetRecommendationEvent(farmInput: farmInput),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.commonLocals.invalid_input}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecommendationBloc, RecommendationState>(
      listener: (context, state) {
        if (state is RecommendationSuccess) {
          context.push('/cost_cutting_result', extra: state.recommendation);
        } else if (state is RecommendationFailure) {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: Text(context.commonLocals.recommendation_error_title),
                content: Text(state.errorMessage),
                actions: <Widget>[
                  TextButton(
                    child: Text(context.commonLocals.ok),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              );
            },
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStyledNumberField(context: context, label: context.commonLocals.farm_size, controller: _farmSizeController),
              _buildStyledDropdown(key: 'cropType', label: context.commonLocals.crop_type, items: _cropTypes),
              _buildStyledDropdown(key: 'season', label: context.commonLocals.season, items: _seasons),
              _buildStyledNumberField(context: context, label: context.commonLocals.fertilizer_expense, controller: _fertilizerExpenseController),
              _buildStyledNumberField(context: context, label: context.commonLocals.pesticide_expense, controller: _pesticideExpenseController),
              _buildStyledNumberField(context: context, label: context.commonLocals.transportation_expense, controller: _transportationExpenseController),
              _buildStyledNumberField(context: context, label: context.commonLocals.equipment_expense, controller: _equipmentExpenseController),
              _buildStyledNumberField(context: context, label: context.commonLocals.seed_expense, controller: _seedExpenseController),
              _buildStyledNumberField(context: context, label: context.commonLocals.labour_expense, controller: _laborExpenseController),
              _buildStyledNumberField(context: context, label: context.commonLocals.other_utilities, controller: _utilityExpenseController),
              const SizedBox(height: 80),
              Center(
                child: BlocBuilder<RecommendationBloc, RecommendationState>(
                  builder: (context, state) {
                    final isLoading = state is RecommendationLoading;
                    return LoadingButton(
                      onPressed: isLoading ? null : _submitForm,
                      label: context.commonLocals.submit,
                      loading: isLoading,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
