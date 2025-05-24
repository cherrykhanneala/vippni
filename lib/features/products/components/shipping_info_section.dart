import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../components/forms/app_text_field.dart';
import '../../../components/buttons/loading_button.dart';
import '../../../utils/error_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert'; // Add this for JSON operations

class ShippingInfoSection extends StatefulWidget {
  final Map<String, dynamic> initialShippingInfo;
  final Function(Map<String, dynamic>) onShippingInfoChanged;

  const ShippingInfoSection({
    required this.initialShippingInfo,
    required this.onShippingInfoChanged,
    super.key, // Use super parameter
  });

  @override
  State<ShippingInfoSection> createState() => _ShippingInfoSectionState(); // Fix the return type
}

class _ShippingInfoSectionState extends State<ShippingInfoSection> {
  final TextEditingController _postageTypeController = TextEditingController();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<String> _productTypes = [];
  List<File> _businessDocuments = [];
  bool _isLoadingDocuments = false;
  bool _isDocumentsUploaded = false;

  @override
  void initState() {
    super.initState();
    _postageTypeController.text = widget.initialShippingInfo['postageType'] ?? '';
    if (widget.initialShippingInfo['productTypes'] != null) {
      _productTypes = List<String>.from(widget.initialShippingInfo['productTypes']);
    }
    _isDocumentsUploaded = widget.initialShippingInfo['documentsUploaded'] ?? false;
  }

  @override
  void dispose() {
    _postageTypeController.dispose();
    super.dispose();
  }

  Future<void> _uploadFileList(List<File> files, String folder) async {
    if (files.isEmpty) return;
    
    setState(() {
      _isLoadingDocuments = true;
    });
    
    await ErrorHandler.handleFuture<void>(
      context,
      Future(() async {
        final List<String> uploadedFiles = [];
        
        for (File file in files) {
          String fileName = '$folder/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
          UploadTask uploadTask = _storage.ref().child(fileName).putFile(file);
          await uploadTask;
          
          // Get download URL
          String downloadUrl = await _storage.ref().child(fileName).getDownloadURL();
          uploadedFiles.add(downloadUrl);
        }
        
        final updatedInfo = Map<String, dynamic>.from(widget.initialShippingInfo);
        updatedInfo['postageType'] = _postageTypeController.text;
        updatedInfo['productTypes'] = _productTypes;
        updatedInfo['documentUrls'] = uploadedFiles;
        updatedInfo['documentsUploaded'] = true;
        
        widget.onShippingInfoChanged(updatedInfo);
        
        setState(() {
          _isDocumentsUploaded = true;
        });
        
        if (mounted) { // Add mounted check
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Documents uploaded successfully')),
          );
        }
      }),
      errorMessage: 'Failed to upload documents',
    );
    
    setState(() {
      _isLoadingDocuments = false;
    });
  }

  Future<void> _selectFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _businessDocuments = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  void _addProductType(String type) {
    if (type.isNotEmpty && !_productTypes.contains(type)) {
      setState(() {
        _productTypes.add(type);
      });
      
      final updatedInfo = Map<String, dynamic>.from(widget.initialShippingInfo);
      updatedInfo['postageType'] = _postageTypeController.text;
      updatedInfo['productTypes'] = _productTypes;
      widget.onShippingInfoChanged(updatedInfo);
    }
  }

  void _removeProductType(String type) {
    setState(() {
      _productTypes.remove(type);
    });
    
    final updatedInfo = Map<String, dynamic>.from(widget.initialShippingInfo);
    updatedInfo['postageType'] = _postageTypeController.text;
    updatedInfo['productTypes'] = _productTypes;
    widget.onShippingInfoChanged(updatedInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipping Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        AppTextField(
          controller: _postageTypeController,
          label: 'Postage Type',
          hint: 'e.g., Standard, Express, International',
          isRequired: true,
          onChanged: (value) {
            final updatedInfo = Map<String, dynamic>.from(widget.initialShippingInfo);
            updatedInfo['postageType'] = value;
            updatedInfo['productTypes'] = _productTypes;
            widget.onShippingInfoChanged(updatedInfo);
          },
        ),
        
        const SizedBox(height: 16),
        
        const Text(
          'Product Types',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        
        Wrap(
          spacing: 8,
          children: _productTypes.map((type) => Chip(
            label: Text(type),
            deleteIcon: const Icon(Icons.close),
            onDeleted: () => _removeProductType(type),
          )).toList(),
        ),
        
        const SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Add product type',
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: _addProductType,
                  onChanged: (value) {
                    // Handle text changes if needed
                  },
                ),
              ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                final TextEditingController controller = TextEditingController();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Add Product Type'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(hintText: 'Enter product type'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          _addProductType(controller.text);
                          Navigator.pop(context);
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        const Text(
          'Business Documents',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        if (_isDocumentsUploaded)
          Card(
            color: Colors.green.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Documents uploaded successfully'),
                ],
              ),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text('Select Documents'),
                onPressed: _selectFiles,
              ),
              
              const SizedBox(height: 8),
              
              if (_businessDocuments.isNotEmpty) ...[
                Text('${_businessDocuments.length} files selected'),
                const SizedBox(height: 8),
                LoadingButton(
                  text: 'Upload Documents',
                  isLoading: _isLoadingDocuments,
                  onPressed: () => _uploadFileList(_businessDocuments, 'businessDocuments'),
                ),
              ],
            ],
          ),
      ],
    );
  }
}