import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_text_field.dart';

class ShippingInfoStepContent extends StatelessWidget {
  final String? selectedPackaging;
  final TextEditingController weightController;
  final String? weightUnit;
  final String dimensionsControllerText;
  final String dimensionsUnit;
  final VoidCallback onShowDimensionsDialog;
  final ValueChanged<String?> onPackagingChanged;
  final ValueChanged<String?> onWeightUnitChanged;

  const ShippingInfoStepContent({
    super.key,
    required this.selectedPackaging,
    required this.weightController,
    required this.weightUnit,
    required this.dimensionsControllerText,
    required this.dimensionsUnit,
    required this.onShowDimensionsDialog,
    required this.onPackagingChanged,
    required this.onWeightUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DropdownButtonFormField<String>(
          value: selectedPackaging,
          items: Constants.packagingTypes.map((String packaging) {
            return DropdownMenuItem<String>(
              value: packaging,
              child: Text(packaging),
            );
          }).toList(),
          onChanged: onPackagingChanged,
          decoration: InputDecoration(
            labelText: 'Packaging *',
            prefixIcon: const Icon(Icons.inventory),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a packaging type';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Weight',
                controller: weightController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.scale,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the weight';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0 || weight > 10000) {
                    return 'Please enter a valid weight between 1 gram and 10 kg';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: weightUnit ?? 'grams',
                items: ['grams', 'kg', 'ounces', 'carats', 'pounds']
                    .map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: onWeightUnitChanged,
                decoration: InputDecoration(
                  labelText: 'Weight Unit *',
                  prefixIcon: const Icon(Icons.straighten),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a weight unit';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (selectedPackaging == 'Boxed')
          TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Dimensions *',
              prefixIcon: const Icon(Icons.crop_din),
              suffixIcon: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onShowDimensionsDialog,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the dimensions';
              }
              return null;
            },
            initialValue: dimensionsControllerText,
          ),
      ],
    );
  }
}
