import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class EditListingScreen extends StatefulWidget {
  final Product product;
  const EditListingScreen({super.key, required this.product});

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  late String _condition;
  late String _category;
  late String _imageUrl;
  String? _customImagePath;

  final List<Map<String, String>> _mockPhotos = [
    {
      "label": "Books",
      "url": "assets/images/book_cover.jpg"
    },
    {
      "label": "Notes",
      "url": "assets/images/written_notes.jpg"
    },
    {
      "label": "Electronics",
      "url": "assets/images/electronics.jpg"
    },
    {
      "label": "Stationery",
      "url": "assets/images/stationery.jpg"
    },
    {
      "label": "Others",
      "url": "assets/images/others.jpg"
    }
  ];

  Future<void> _pickCustomImage() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      );
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final file = File(path);
        
        // Format check
        final extension = path.split('.').last.toLowerCase();
        if (extension != 'jpg' && extension != 'jpeg' && extension != 'png' && extension != 'webp') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error: Only JPG, PNG, and WEBP formats are supported.")),
          );
          return;
        }

        final sizeInBytes = await file.length();
        final sizeInMb = sizeInBytes / (1024 * 1024);
        if (sizeInMb > 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error: Image size cannot exceed 5 MB.")),
          );
          return;
        }
        setState(() {
          _customImagePath = path;
          _imageUrl = path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product.title);
    _priceController = TextEditingController(text: widget.product.price.toStringAsFixed(2));
    _descriptionController = TextEditingController(text: widget.product.description);
    _condition = widget.product.condition;
    _category = widget.product.category;
    _imageUrl = widget.product.imageUrl;

    // Check if current image is a custom uploader file path
    final String currentUrl = widget.product.imageUrl;
    if (!currentUrl.startsWith('assets/') && !currentUrl.startsWith('http://') && !currentUrl.startsWith('https://')) {
      _customImagePath = currentUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required Widget prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: AppTheme.textMedium, fontSize: 13, fontWeight: FontWeight.bold),
      hintText: hintText,
      hintStyle: TextStyle(color: AppTheme.textLight, fontSize: 13),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppTheme.borderMedium, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppTheme.borderMedium, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppTheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: AppTheme.bgCard,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark),
        ),
        title: Text(
          "Edit Listing",
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        shape: Border(bottom: BorderSide(color: AppTheme.borderMedium, width: 1.5)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Change Visual Asset",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _mockPhotos.length,
                  itemBuilder: (context, index) {
                    final photo = _mockPhotos[index];
                    final isSelected = _imageUrl == photo["url"] && _customImagePath == null;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _customImagePath = null;
                          _imageUrl = photo["url"]!;
                        });
                      },
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : AppTheme.borderMedium,
                            width: isSelected ? 2.5 : 1.5,
                          ),
                          boxShadow: isSelected ? AppTheme.shadowSmall : null,
                          image: DecorationImage(
                            image: AppTheme.buildProductImageProvider(photo["url"]!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(13),
                              bottomRight: Radius.circular(13),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            photo["label"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Or Upload Live Photo",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: _pickCustomImage,
                child: Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard, 
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _customImagePath != null ? AppTheme.primary : AppTheme.borderMedium,
                      width: 1.5,
                    ),
                    boxShadow: _customImagePath != null ? AppTheme.shadowSmall : null,
                  ),
                  child: _customImagePath != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(19),
                              child: Image.file(
                                File(_customImagePath!),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _customImagePath = null;
                                    _imageUrl = _mockPhotos[0]["url"]!;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: const Color(0xb3000000),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryPastel,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add_photo_alternate_rounded, color: AppTheme.primary, size: 28),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Upload Resource Image",
                              style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Formats: JPG, PNG, WEBP (Max 5MB)",
                              style: TextStyle(color: AppTheme.textLight, fontSize: 11),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 28),

              TextFormField(
                controller: _titleController,
                style: TextStyle(color: AppTheme.textDark, fontSize: 14),
                decoration: _buildInputDecoration(
                  labelText: "Resource Title",
                  hintText: "e.g. Engineering Mathematics Textbook",
                  prefixIcon: Icon(Icons.title_rounded, color: AppTheme.textMedium, size: 20),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return "Title is required";
                  return null;
                },
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: AppTheme.textDark, fontSize: 14),
                decoration: _buildInputDecoration(
                  labelText: "Price (\$)",
                  hintText: "e.g. 25.00",
                  prefixIcon: Icon(Icons.attach_money_rounded, color: AppTheme.textMedium, size: 20),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Price is required";
                  if (double.tryParse(val) == null) return "Enter a valid price";
                  return null;
                },
              ),

              const SizedBox(height: 22),

              Text(
                "Category",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ["Books", "Notes", "Electronics", "Stationery", "Lab Equipment", "Others"].map((cat) {
                  final isSelected = _category == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _category = cat;
                        });
                      }
                    },
                    selectedColor: AppTheme.primaryPastel,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primary : AppTheme.textMedium,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 12,
                    ),
                    backgroundColor: AppTheme.bgCard,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primary : AppTheme.borderMedium,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    showCheckmark: false,
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              Text(
                "Condition",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ["New", "Like New", "Good", "Fair"].map((cond) {
                  final isSelected = _condition == cond;
                  return ChoiceChip(
                    label: Text(cond),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _condition = cond;
                        });
                      }
                    },
                    selectedColor: AppTheme.primaryPastel,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primary : AppTheme.textMedium,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 12,
                    ),
                    backgroundColor: AppTheme.bgCard,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primary : AppTheme.borderMedium,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    showCheckmark: false,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                style: TextStyle(color: AppTheme.textDark, fontSize: 14),
                decoration: _buildInputDecoration(
                  labelText: "Description",
                  hintText: "Describe the condition, usage, chapters covered etc.",
                  prefixIcon: Icon(Icons.description_outlined, color: AppTheme.textMedium, size: 20),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return "Description is required";
                  return null;
                },
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final double priceValue = double.parse(_priceController.text);
                      
                      final updatedProduct = Product(
                        id: widget.product.id,
                        title: _titleController.text.trim(),
                        price: priceValue,
                        imageUrl: _imageUrl,
                        sellerName: widget.product.sellerName,
                        rating: widget.product.rating,
                        reviewsCount: widget.product.reviewsCount,
                        description: _descriptionController.text.trim(),
                        condition: _condition,
                        category: _category,
                        isFavorite: widget.product.isFavorite,
                        isSold: widget.product.isSold,
                      );

                      AppState.editProduct(updatedProduct);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Listing updated successfully!"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );

                      Navigator.pop(context); // pop edit listing screen
                      
                      // Also pop the details screen to go back to the list and see updated content
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
