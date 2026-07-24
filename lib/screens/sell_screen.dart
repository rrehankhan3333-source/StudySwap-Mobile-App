import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show File;
import 'package:file_picker/file_picker.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController(text: "10");

  String _condition = "Good";
  String _category = "Books";
  String _imageUrl = "assets/images/book_cover.jpg";
  String? _customImagePath;
  bool _isPublishing = false;

  final List<Map<String, String>> _mockPhotos = [
    {"label": "Books", "url": "assets/images/book_cover.jpg"},
    {"label": "Notes", "url": "assets/images/written_notes.jpg"},
    {"label": "Electronics", "url": "assets/images/electronics.jpg"},
    {"label": "Stationery", "url": "assets/images/stationery.jpg"},
    {"label": "Others", "url": "assets/images/others.jpg"},
  ];

  Future<void> _pickCustomImage() async {
    try {
      String? path;
      String? fileName;
      int? sizeInBytes;

      // Use FilePicker globally to avoid MissingPluginException from image_picker
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      );

      if (result != null) {
        fileName = result.files.single.name;
        sizeInBytes = result.files.single.size;

        if (kIsWeb) {
          final bytes = result.files.single.bytes;
          if (bytes != null) {
            final extension = fileName.split('.').last.toLowerCase();
            path = Uri.dataFromBytes(
              bytes,
              mimeType: 'image/$extension',
            ).toString();
          }
        } else {
          path = result.files.single.path;
        }
      }

      if (path != null && fileName != null) {
        // Format check
        final extension = fileName.split('.').last.toLowerCase();
        if (extension != 'jpg' &&
            extension != 'jpeg' &&
            extension != 'png' &&
            extension != 'webp') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Only JPG, JPEG, PNG, WEBP images can be selected.",
                ),
              ),
            );
          }
          return;
        }

        // Size check (Max 5MB)
        if (sizeInBytes != null) {
          final sizeInMb = sizeInBytes / (1024 * 1024);
          if (sizeInMb > 5) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Error: Image size cannot exceed 5 MB."),
                ),
              );
            }
            return;
          }
        }

        setState(() {
          _customImagePath = path;
          _imageUrl = path!;
        });
      }
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('permission') || errStr.contains('access')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Gallery permission is required to select images. Please enable it in Settings.",
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error picking image: $e")));
        }
      }
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
      labelStyle: TextStyle(
        color: AppTheme.textMedium,
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
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
        leading: Navigator.canPop(context)
            ? IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.textDark,
                ),
              )
            : null,
        title: Text(
          "List New Item",
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        shape: Border(
          bottom: BorderSide(color: AppTheme.borderMedium, width: 1.5),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Visual Asset",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Selecting mock photos
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _mockPhotos.length,
                      itemBuilder: (context, index) {
                        final photo = _mockPhotos[index];
                        final isSelected =
                            _imageUrl == photo["url"] &&
                            _customImagePath == null;

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
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.borderMedium,
                                width: isSelected ? 2.5 : 1.5,
                              ),
                              boxShadow: isSelected
                                  ? AppTheme.shadowSmall
                                  : null,
                              image: DecorationImage(
                                image: AppTheme.buildProductImageProvider(
                                  photo["url"]!,
                                ),
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
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
                          color: _customImagePath != null
                              ? AppTheme.primary
                              : AppTheme.borderMedium,
                          width: 1.5,
                        ),
                        boxShadow: _customImagePath != null
                            ? AppTheme.shadowSmall
                            : null,
                      ),
                      child: _customImagePath != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(19),
                                  child: kIsWeb
                                      ? Image.network(
                                          _customImagePath!,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (
                                                context,
                                                error,
                                                stackTrace,
                                              ) => Container(
                                                color: AppTheme.bgSurface,
                                                width: double.infinity,
                                                height: double.infinity,
                                                child: Icon(
                                                  Icons.broken_image_rounded,
                                                  color: AppTheme.textMedium,
                                                ),
                                              ),
                                        )
                                      : Image.file(
                                          File(
                                            _customImagePath!.startsWith(
                                                  'file://',
                                                )
                                                ? Uri.parse(
                                                    _customImagePath!,
                                                  ).toFilePath()
                                                : _customImagePath!,
                                          ),
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (
                                                context,
                                                error,
                                                stackTrace,
                                              ) => Container(
                                                color: AppTheme.bgSurface,
                                                width: double.infinity,
                                                height: double.infinity,
                                                child: Icon(
                                                  Icons.broken_image_rounded,
                                                  color: AppTheme.textMedium,
                                                ),
                                              ),
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
                                        color: Color(0xb3000000),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
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
                                  child: Icon(
                                    Icons.add_photo_alternate_rounded,
                                    color: AppTheme.primary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Upload Resource Image",
                                  style: TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Formats: JPG, PNG, WEBP (Max 5MB)",
                                  style: TextStyle(
                                    color: AppTheme.textLight,
                                    fontSize: 11,
                                  ),
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
                      prefixIcon: Icon(
                        Icons.title_rounded,
                        color: AppTheme.textMedium,
                        size: 20,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty)
                        return "Title is required";
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(color: AppTheme.textDark, fontSize: 14),
                    decoration: _buildInputDecoration(
                      labelText: "Price (\$)",
                      hintText: "e.g. 25.00",
                      prefixIcon: Icon(
                        Icons.attach_money_rounded,
                        color: AppTheme.textMedium,
                        size: 20,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return "Price is required";
                      if (double.tryParse(val) == null)
                        return "Enter a valid price";
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: AppTheme.textDark, fontSize: 14),
                    decoration: _buildInputDecoration(
                      labelText: "Stock Quantity",
                      hintText: "e.g. 10",
                      prefixIcon: Icon(
                        Icons.inventory_2_outlined,
                        color: AppTheme.textMedium,
                        size: 20,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "Stock quantity is required";
                      }
                      final n = int.tryParse(val);
                      if (n == null || n < 1) {
                        return "Enter a valid stock quantity (>= 1)";
                      }
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
                    children:
                        [
                          "Books",
                          "Notes",
                          "Electronics",
                          "Stationery",
                          "Lab Equipment",
                          "Others",
                        ].map((cat) {
                          final isSelected = _category == cat;
                          return ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _category = cat;
                                  if (_customImagePath == null) {
                                    if (cat == "Books") {
                                      _imageUrl =
                                          "assets/images/book_cover.jpg";
                                    } else if (cat == "Notes") {
                                      _imageUrl =
                                          "assets/images/written_notes.jpg";
                                    } else if (cat == "Electronics") {
                                      _imageUrl =
                                          "assets/images/electronics.jpg";
                                    } else if (cat == "Stationery") {
                                      _imageUrl =
                                          "assets/images/stationery.jpg";
                                    } else {
                                      _imageUrl = "assets/images/others.jpg";
                                    }
                                  }
                                });
                              }
                            },
                            selectedColor: AppTheme.primaryPastel,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.textMedium,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              fontSize: 12,
                            ),
                            backgroundColor: AppTheme.bgCard,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.borderMedium,
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
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.textMedium,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          fontSize: 12,
                        ),
                        backgroundColor: AppTheme.bgCard,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.borderMedium,
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
                      hintText:
                          "Describe the condition, usage, chapters covered etc.",
                      prefixIcon: Icon(
                        Icons.description_outlined,
                        color: AppTheme.textMedium,
                        size: 20,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty)
                        return "Description is required";
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isPublishing
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                final double priceValue = double.parse(
                                  _priceController.text,
                                );

                                final newProduct = Product(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                  title: _titleController.text.trim(),
                                  price: priceValue,
                                  stock: int.parse(_stockController.text.trim()),
                                  imageUrl: _imageUrl,
                                  sellerName: AppState.nameNotifier.value,
                                  rating: 5.0,
                                  reviewsCount: 1,
                                  description: _descriptionController.text
                                      .trim(),
                                  condition: _condition,
                                  category: _category,
                                  isFavorite: false,
                                  isSold: false,
                                );

                                setState(() {
                                  _isPublishing = true;
                                });

                                try {
                                  await AppState.addProduct(newProduct);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Listing created successfully!",
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );

                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    } else {
                                      // Switch active screen inside home context (reset form)
                                      _titleController.clear();
                                      _priceController.clear();
                                      _descriptionController.clear();
                                      _stockController.text = "10";
                                      setState(() {
                                        _customImagePath = null;
                                        _imageUrl = _mockPhotos[0]["url"]!;
                                      });
                                    }
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Failed to publish listing: $e",
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor:
                                            Colors.redAccent.shade700,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isPublishing = false;
                                    });
                                  }
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Publish Listing",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isPublishing)
            Container(
              color: Colors.black.withAlpha(90),
              child: Center(
                child: Card(
                  color: AppTheme.bgCard,
                  surfaceTintColor: Colors.transparent,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Uploading files & listing item...",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
