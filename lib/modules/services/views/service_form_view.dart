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
  final _description = TextEditingController();
  final _location = TextEditingController();
  final Set<String> _selectedCategories = {};
  final Map<String, TextEditingController> _categoryPriceControllers = {};
  final Map<String, String> _categoryLabels = {};
  ServiceModel? _editingService;
  bool _isEditMode = false;

  final List<Map<String, dynamic>> _categories = [
    {'label': '🎨 Decoration', 'value': 'decoration'},
    {'label': '🏛️ Venue', 'value': 'venue'},
    {'label': '🍽️ Food', 'value': 'food'},
    {'label': '🍴 Catering', 'value': 'catering'},
    {'label': '🔒 Security', 'value': 'security'},
    {'label': '📸 Photography', 'value': 'photography'},
    {'label': '🎵 Music & DJ', 'value': 'music'},
    {'label': '📋 Event Planning', 'value': 'event_planning'},
  ];

  @override
  void initState() {
    super.initState();
    for (final cat in _categories) {
      _categoryLabels[cat['value'] as String] = cat['label'] as String;
    }
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
      _description.text = _editingService!.description;
      _location.text = _editingService!.location;
      _selectedCategories
        ..clear()
        ..addAll(
          _editingService!.categories
              .map((c) => c.id)
              .where((id) => id.isNotEmpty),
        );
      for (final category in _editingService!.categories) {
        _categoryPriceControllers[category.id] = TextEditingController(
          text: category.price.toString(),
        );
      }
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
                      _categoryPriceControllers.remove(value)?.dispose();
                    } else {
                      _selectedCategories.add(value);
                      _categoryPriceControllers[value] =
                          TextEditingController();
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              _CategoryPriceInputs(
                selectedCategories: _selectedCategories,
                categories: _categories,
                controllers: _categoryPriceControllers,
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
                descriptionController: _description,
                locationController: _location,
                selectedCategories: _selectedCategories.toList(),
                categoryPriceControllers: _categoryPriceControllers,
                categoryLabels: _categoryLabels,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryPriceInputs extends StatelessWidget {
  const _CategoryPriceInputs({
    required this.selectedCategories,
    required this.categories,
    required this.controllers,
  });

  final Set<String> selectedCategories;
  final List<Map<String, dynamic>> categories;
  final Map<String, TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    final selected = categories.where(
      (c) => selectedCategories.contains(c['value']),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selected.isNotEmpty)
          const Text(
            'Set price per category',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ...selected.map((c) {
          final id = c['value'] as String;
          controllers.putIfAbsent(id, () => TextEditingController());
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: StyledTextField(
              controller: controllers[id] ?? TextEditingController(),
              label: '${c['label']} price (PKR)',
              hint: 'e.g., 5000',
              keyboardType: TextInputType.number,
              validator: Validators.notEmpty,
            ),
          );
        }),
      ],
    );
  }
}
