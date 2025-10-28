import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'db/db_helper.dart';
import 'model/model.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  AddEditProductScreen({this.product});

  @override
  _AddEditProductScreenState createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _quantityController = TextEditingController(
        text: widget.product?.quantity.toString() ?? '');
    _priceController = TextEditingController(
        text: widget.product?.price.toString() ?? '');
    _imagePath = widget.product?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request permissions
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Camera permission is required')),
          );
          return;
        }
      } else {
        final status = await Permission.photos.request();
        if (status.isDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Photos permission is required')),
          );
          return;
        }
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = await File(image.path).copy('${appDir.path}/$fileName');

        setState(() {
          _imagePath = savedImage.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Product Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.indigo),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.indigo),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_imagePath != null)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Remove Image'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _imagePath = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final product = Product(
          id: widget.product?.id,
          name: _nameController.text.trim(),
          quantity: int.parse(_quantityController.text),
          price: double.parse(_priceController.text),
          imagePath: _imagePath,
          createdAt: widget.product?.createdAt,
          updatedAt: DateTime.now(),
        );

        if (widget.product == null) {
          await DatabaseHelper.instance.createProduct(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Product added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          await DatabaseHelper.instance.updateProduct(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Product updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Add Product' : 'Edit Product',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo[700],
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Section
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.indigo[700]!, Colors.indigo[400]!],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: _imagePath != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          File(_imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image, size: 50, color: Colors.grey[400]),
                                Text('Error loading image', style: TextStyle(fontSize: 10)),
                              ],
                            );
                          },
                        ),
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50, color: Colors.grey[400]),
                          SizedBox(height: 10),
                          Text('Add Image', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Tap to ${_imagePath != null ? 'change' : 'add'} image',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),

            // Form Section
            Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[700],
                      ),
                    ),
                    SizedBox(height: 20),

                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Product Name *',
                        prefixIcon: Icon(Icons.inventory_2),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[50],

                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter product name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity *',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (int.parse(value) < 0) {
                          return 'Quantity cannot be negative';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Price *',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid price';
                        }
                        if (double.parse(value) < 0) {
                          return 'Price cannot be negative';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                          widget.product == null ? 'Add Product' : 'Update Product',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
