import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/service_model.dart';
import '../../home/controllers/shell_controller.dart';
import '../controllers/service_controller.dart';
import '../components/form/section_title.dart';
import '../components/form/styled_text_field.dart';
import '../components/form/category_dropdown.dart';
import '../components/form/location_helper.dart';
import '../components/form/media_section.dart';
import '../components/form/publish_button.dart';

class ServiceFormView extends StatefulWidget {
  const ServiceFormView({super.key});

  @override
  State<ServiceFormView> createState() => _ServiceFormViewState();
}

class _ServiceFormViewState extends State<ServiceFormView> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  final Set<String> _selectedCategories = {};
  ServiceModel? _editingService;
  bool _isEditMode = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'label': '🎨 Decoration',
      'value': 'decoration',
      'icon': Icons.auto_awesome,
    },
    {'label': '🏛️ Venue', 'value': 'venue', 'icon': Icons.location_city},
    {'label': '🍽️ Food', 'value': 'food', 'icon': Icons.restaurant},
    {
      'label': '🍴 Catering',
      'value': 'catering',
      'icon': Icons.restaurant_menu,
    },
    {'label': '🔒 Security', 'value': 'security', 'icon': Icons.security},
    {
      'label': '🚗 Transport',
      'value': 'transport',
      'icon': Icons.directions_car,
    },
    {
      'label': '📸 Photography',
      'value': 'photography',
      'icon': Icons.camera_alt,
    },
    {'label': '🎵 Music & DJ', 'value': 'music', 'icon': Icons.music_note},
    {'label': '💐 Flowers', 'value': 'flowers', 'icon': Icons.local_florist},
    {'label': '🎂 Bakery', 'value': 'bakery', 'icon': Icons.cake},
  ];

  @override
  void initState() {
    super.initState();
    // Check if we're editing an existing service
    if (Get.arguments != null && Get.arguments is ServiceModel) {
      _editingService = Get.arguments as ServiceModel;
      _isEditMode = true;
      _populateFields();
    }
  }

  void _populateFields() {
    if (_editingService != null) {
      _title.text = _editingService!.title;
      _price.text = _editingService!.price.toString();
      _description.text = _editingService!.description;
      _location.text = _editingService!.location;
      _selectedCategories
        ..clear()
        ..addAll(
          _editingService!.categories.isNotEmpty
              ? _editingService!.categories
              : [_editingService!.category],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceController>();
    final shell = Get.find<ShellController>();

    if (!_isEditMode && _location.text.isEmpty) {
      _location.text = shell.user.value?.city ?? controller.locationLabel.value;
    }

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode ? '✏️ Edit Service' : '✨ Create Service',
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(title: '📝 Service Details'),
              const SizedBox(height: 16),
              StyledTextField(
                controller: _title,
                label: 'Service Title',
                hint: 'e.g., Premium Wedding Photography',
                validator: Validators.notEmpty,
              ),
              const SizedBox(height: 16),
              CategoryMultiSelect(
                selectedCategories: _selectedCategories,
                categories: _categories,
                onToggle: (value) {
                  setState(() {
                    if (_selectedCategories.contains(value)) {
                      _selectedCategories.remove(value);
                    } else {
                      _selectedCategories.add(value);
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              StyledTextField(
                controller: _price,
                label: 'Price (PKR)',
                hint: 'Enter your service price',
                keyboardType: TextInputType.number,
                validator: Validators.notEmpty,
              ),
              const SizedBox(height: 24),
              const SectionTitle(title: '📍 Location'),
              const SizedBox(height: 16),
              StyledTextField(
                controller: _location,
                label: 'Service Location',
                hint: 'Where you provide this service',
                validator: Validators.notEmpty,
              ),
              const SizedBox(height: 12),
              LocationHelper(locationController: _location),
              const SizedBox(height: 24),
              const SectionTitle(title: '📄 Description'),
              const SizedBox(height: 16),
              StyledTextField(
                controller: _description,
                label: 'Service Description',
                hint: 'Tell customers about your service...',
                maxLines: 5,
                validator: (v) =>
                    Validators.minLength(v, 10, label: 'Description'),
              ),
              const SizedBox(height: 24),
              const SectionTitle(title: '🖼️ Media'),
              const SizedBox(height: 16),
              MediaSection(
                coverImageUrl: _editingService?.coverImage,
                galleryImageUrls: _editingService?.galleryImages ?? [],
              ),
              const SizedBox(height: 32),
              PublishButton(
                formKey: _formKey,
                isEditMode: _isEditMode,
                editingService: _editingService,
                titleController: _title,
                priceController: _price,
                descriptionController: _description,
                locationController: _location,
                selectedCategories: _selectedCategories.toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
