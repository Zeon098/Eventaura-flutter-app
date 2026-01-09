import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/service_model.dart';
import '../../home/controllers/shell_controller.dart';
import '../controllers/service_controller.dart';
import '../components/form/section_title.dart';
import '../components/form/styled_text_field.dart';
import '../../../widgets/address_picker_field.dart';
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
  late final ServiceController _controller;
  final Set<String> _selectedCategories = {};
  final Map<String, TextEditingController> _categoryPriceControllers = {};
  final Map<String, String?> _categoryPricingTypes =
      {}; // Store pricing type per category
  final Map<String, String> _categoryLabels = {};
  final Set<String> _selectedVenueSubtypes = {};
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

  final List<String> _venueSubtypes = [
    'Outdoor Garden',
    'Indoor Hall',
    'Banquet Hall',
    'Rooftop',
    'Beach',
    'Farm House',
    'Hotel/Resort',
    'Convention Center',
  ];

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ServiceController>();
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
      _controller.latitude.value = _editingService!.latitude;
      _controller.longitude.value = _editingService!.longitude;
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
        _categoryPricingTypes[category.id] = category.pricingType;
      }
      _selectedVenueSubtypes
        ..clear()
        ..addAll(_editingService!.venueSubtypes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<ShellController>();

    if (!_isEditMode && _location.text.isEmpty) {
      _location.text =
          shell.user.value?.city ?? _controller.locationLabel.value;
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
                pricingTypes: _categoryPricingTypes,
                onPricingTypeChanged: (catId, type) {
                  setState(() {
                    _categoryPricingTypes[catId] = type;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Venue subtypes (only show if venue is selected)
              if (_selectedCategories.contains('venue')) ...[
                const SizedBox(height: 8),
                const Text(
                  'Venue Type',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _venueSubtypes.map((subtype) {
                    final isSelected = _selectedVenueSubtypes.contains(subtype);
                    return FilterChip(
                      label: Text(subtype),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedVenueSubtypes.add(subtype);
                          } else {
                            _selectedVenueSubtypes.remove(subtype);
                          }
                        });
                      },
                      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                      checkmarkColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondaryColor,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 24),
              const SectionTitle(title: '📍 Location'),
              const SizedBox(height: 16),
              AddressPickerField(
                label: 'Service Location',
                hint: 'Where you provide this service',
                controller: _location,
                initialLat: _controller.latitude.value,
                initialLng: _controller.longitude.value,
                onChanged: (addr, lat, lng) {
                  _controller.latitude.value = lat;
                  _controller.longitude.value = lng;
                },
              ),
              // const SizedBox(height: 12),
              // LocationHelper(locationController: _location),
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
                categoryPricingTypes: _categoryPricingTypes,
                categoryLabels: _categoryLabels,
                venueSubtypes: _selectedVenueSubtypes.toList(),
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
    required this.pricingTypes,
    required this.onPricingTypeChanged,
  });

  final Set<String> selectedCategories;
  final List<Map<String, dynamic>> categories;
  final Map<String, TextEditingController> controllers;
  final Map<String, String?> pricingTypes;
  final Function(String catId, String? type) onPricingTypeChanged;

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
          final isVenue = id == 'venue';
          final currentType =
              pricingTypes[id] ?? (isVenue ? 'per_100_persons' : 'base');

          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledTextField(
                  controller: controllers[id] ?? TextEditingController(),
                  label: '${c['label']} price (PKR)',
                  hint: 'e.g., 5000',
                  keyboardType: TextInputType.number,
                  validator: Validators.notEmpty,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: currentType,
                  decoration: InputDecoration(
                    labelText: 'Pricing Type',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    if (isVenue)
                      const DropdownMenuItem(
                        value: 'per_100_persons',
                        child: Text('Per 100 Persons'),
                      ),
                    if (!isVenue) ...[
                      const DropdownMenuItem(
                        value: 'base',
                        child: Text('Base Price'),
                      ),
                      const DropdownMenuItem(
                        value: 'per_head',
                        child: Text('Per Head/Person'),
                      ),
                    ],
                  ],
                  onChanged: (value) => onPricingTypeChanged(id, value),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
