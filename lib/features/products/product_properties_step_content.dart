import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/custom_text_field.dart';

class ProductPropertiesStepContent extends StatelessWidget {
  final String? selectedMaterial;
  final List<String> materials;
  final List<String> colors;
  final TextEditingController colorController;
  final ValueChanged<String?> onMaterialChanged;
  final VoidCallback onAddMaterial;
  final ValueChanged<int> onRemoveMaterial;
  final VoidCallback onAddColor;
  final ValueChanged<int> onRemoveColor;

  const ProductPropertiesStepContent({
    super.key,
    required this.selectedMaterial,
    required this.materials,
    required this.colors,
    required this.colorController,
    required this.onMaterialChanged,
    required this.onAddMaterial,
    required this.onRemoveMaterial,
    required this.onAddColor,
    required this.onRemoveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Materials', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomDropdown<String>(
                label: 'Material',
                value: selectedMaterial,
                items: Constants.materialTypes,
                onChanged: onMaterialChanged,
                prefixIcon: Icons.category,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFF31135F)),
              onPressed: onAddMaterial,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...materials.asMap().entries.map((entry) {
          final index = entry.key;
          final material = entry.value;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Chip(
              label: Text(material),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => onRemoveMaterial(index),
            ),
          );
        }).toList(),
        
        const SizedBox(height: 16),
        const Text('Colors', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Color',
                controller: colorController,
                prefixIcon: Icons.color_lens,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFF31135F)),
              onPressed: onAddColor,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: colors.asMap().entries.map((entry) {
            final index = entry.key;
            final color = entry.value;
            
            return Chip(
              label: Text(color),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => onRemoveColor(index),
              backgroundColor: _getColorFromName(color),
              labelStyle: TextStyle(
                color: _isLightColor(_getColorFromName(color)) ? Colors.black : Colors.white,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  // Helper method to convert color name to Color object
  Color _getColorFromName(String colorName) {
    final Map<String, Color> colorMap = {
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'black': Colors.black,
      'white': Colors.white,
      'grey': Colors.grey,
      'purple': Colors.purple,
      'pink': Colors.pink,
      'orange': Colors.orange,
    };
    
    String normalizedColor = colorName.toLowerCase();
    return colorMap[normalizedColor] ?? Colors.grey.shade300;
  }
  
  // Helper method to determine if text should be black or white based on background color
  bool _isLightColor(Color color) {
    return color.computeLuminance() > 0.5;
  }
}
