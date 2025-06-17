import 'dart:io';
import 'package:drivo_app/core/helpers/custom_snackbar.dart';
import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:drivo_app/features/service_provider/first_page/presentation/view_model/cubit/facility_cubit.dart';
import 'package:drivo_app/features/service_provider/home_provider/presentation/views/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class FirstServiceProviderSettingsScreen extends StatefulWidget {
  final Map<String, dynamic> provider;
  const FirstServiceProviderSettingsScreen({super.key, required this.provider});

  @override
  State<FirstServiceProviderSettingsScreen> createState() =>
      _FirstServiceProviderSettingsScreenState();
}

class _FirstServiceProviderSettingsScreenState
    extends State<FirstServiceProviderSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _snapchatController = TextEditingController();

  File? _coverImageFile;
  File? _profileImageFile;
  LatLng? _selectedLocation;
  bool _isLoadingAddress = false;

  final Map<String, TimeOfDay> _businessHours = {
    'sundayToThursday': const TimeOfDay(hour: 10, minute: 0),
    'friday': const TimeOfDay(hour: 16, minute: 0),
    'saturday': const TimeOfDay(hour: 12, minute: 0),
  };

  final Map<String, TimeOfDay> _closingHours = {
    'sundayToThursday': const TimeOfDay(hour: 0, minute: 0),
    'friday': const TimeOfDay(hour: 1, minute: 0),
    'saturday': const TimeOfDay(hour: 0, minute: 0),
  };

  @override
  void initState() {
    super.initState();

    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<FacilityCubit, FacilityState>(
      listener: (context, state) {
        if (state is FacilitySaved) {
          CustomSnackbar(
            context: context,
            snackBarType: SnackBarType.success,
            label: "تم حفظ البيانات بنجاح",
          );
        } else if (state is FacilityError) {
          CustomSnackbar(
            context: context,
            snackBarType: SnackBarType.fail,
            label: state.message,
          );
        }
      },
      child: BlocBuilder<FacilityCubit, FacilityState>(
        builder: (context, state) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: theme.primaryColor,
                title: const Text("إكمال بيانات المطعم"),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _saveChanges,
                    child: const Text(
                      "حفظ",
                    ),
                  ),
                ],
              ),
              body: ModalProgressHUD(
                inAsyncCall: state is FacilitySaving,
                color: Theme.of(context).primaryColor,
                opacity: 1,
                progressIndicator: Center(
                  child: Image.asset('assets/images/logo_waiting.gif'),
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    child: Column(
                      children: [
                        // Cover Photo Section
                        Stack(
                          children: [
                            Container(
                              height: 180.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: theme.primaryColor,
                                  width: 1.w,
                                ),
                              ),
                              child: _coverImageFile != null
                                  ? Image.file(
                                      _coverImageFile!,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.add_photo_alternate,
                                      size: 50.w,
                                      color: theme.primaryColor,
                                    ),
                            ),
                            Positioned(
                              bottom: 10.h,
                              right: 10.w,
                              child: FloatingActionButton.small(
                                backgroundColor: theme.primaryColor,
                                onPressed: () => _pickImage(true),
                                child: const Icon(Icons.camera_alt,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 80.h),

                        // Profile Picture Section
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 120.w,
                                height: 120.w,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: theme.primaryColor,
                                    width: 3.w,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: _profileImageFile != null
                                      ? Image.file(
                                          _profileImageFile!,
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(
                                          Icons.restaurant,
                                          size: 50.w,
                                          color: theme.primaryColor,
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.camera_alt,
                                        color: Colors.white),
                                    onPressed: () => _pickImage(false),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Basic Information Section
                        _buildSectionHeader("المعلومات الأساسية"),
                        _buildEditableField(
                          controller: _nameController,
                          label: "اسم المطعم",
                          icon: Icons.restaurant,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال اسم المطعم';
                            }
                            return null;
                          },
                        ),
                        _buildEditableField(
                          controller: _descriptionController,
                          label: "وصف المطعم",
                          icon: Icons.description,
                          maxLines: 2,
                        ),
                        SizedBox(height: 24.h),

                        // Contact Information Section
                        _buildSectionHeader("معلومات التواصل"),
                        _buildEditableField(
                          controller: _addressController,
                          label: "العنوان",
                          icon: Icons.location_on,
                          readOnly: true,
                          onTap: () => _selectLocation(context),
                          suffix: _isLoadingAddress
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                )
                              : null,
                        ),
                        _buildEditableField(
                          controller: _phoneController,
                          label: "رقم الهاتف",
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال رقم الهاتف';
                            }
                            if (!RegExp(r'^(77|78|73|71)\d{7}$')
                                .hasMatch(value.trim())) {
                              return 'يجب أن يبدأ الرقم بـ 77 أو 78 أو 73 أو 71 ويتكون من 9 أرقام';
                            }
                            return null;
                          },
                        ),
                        _buildEditableField(
                          controller: _emailController,
                          label: "البريد الإلكتروني",
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !value.contains('@')) {
                              return 'الرجاء إدخال بريد إلكتروني صحيح';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24.h),

                        // Business Hours Section
                        _buildSectionHeader("أوقات العمل"),
                        _buildBusinessHoursRow(
                            "السبت - الأربعاء", 'sundayToThursday'),
                        _buildBusinessHoursRow("الخميس", 'saturday'),
                        _buildBusinessHoursRow("الجمعة", 'friday'),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines = 1,
    bool readOnly = false,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    Widget? suffix,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
      ),
    );
  }

  Widget _buildBusinessHoursRow(String day, String dayType) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              day,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => _selectTime(context, dayType, true),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    _businessHours[dayType]!.format(context),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: const Text("إلى"),
          ),
          Expanded(
            child: InkWell(
              onTap: () => _selectTime(context, dayType, false),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    _closingHours[dayType]!.format(context),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserData() async {
    final email = await SharedPreferencesService.getEmail();
    final phone = await SharedPreferencesService.getUserPhone();
    if (email != null) _emailController.text = email;
    if (phone != null) _phoneController.text = phone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _snapchatController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isCover) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isCover) {
          _coverImageFile = File(pickedFile.path);
        } else {
          _profileImageFile = File(pickedFile.path);
        }
      });
    }
  }

  // In your _selectTime function:
  Future<void> _selectTime(
      BuildContext context, String dayType, bool isOpening) async {
    final initialTime =
        isOpening ? _businessHours[dayType]! : _closingHours[dayType]!;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        if (isOpening) {
          _businessHours[dayType] = pickedTime;
        } else {
          _closingHours[dayType] = pickedTime;
        }
      });
    }
  }

  Future<void> _selectLocation(BuildContext context) async {
    try {
      // Check permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition();
      LatLng initialLocation = LatLng(position.latitude, position.longitude);

      // Open map picker
      if (!context.mounted) return;
      final LatLng? selectedLocation = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              LocationPickerScreen(initialLocation: initialLocation),
        ),
      );

      if (selectedLocation != null) {
        setState(() {
          _selectedLocation = selectedLocation;
          _isLoadingAddress = true;
        });

        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            selectedLocation.latitude,
            selectedLocation.longitude,
          );

          if (placemarks.isNotEmpty) {
            Placemark place = placemarks.first;
            String address =
                "${place.street}, ${place.locality}, ${place.country}";
            _addressController.text = address;
          } else {
            _addressController.text =
                "${selectedLocation.latitude.toStringAsFixed(4)}, ${selectedLocation.longitude.toStringAsFixed(4)}";
          }
        } catch (e) {
          _addressController.text =
              "${selectedLocation.latitude.toStringAsFixed(4)}, ${selectedLocation.longitude.toStringAsFixed(4)}";
        } finally {
          setState(() => _isLoadingAddress = false);
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      if (_profileImageFile == null) {
        CustomSnackbar(
          context: context,
          snackBarType: SnackBarType.alert,
          label: "الرجاء إضافة شعار المطعم",
        );
        return;
      }

      if (_selectedLocation == null) {
        CustomSnackbar(
          context: context,
          snackBarType: SnackBarType.alert,
          label: "الرجاء تحديد الموقع على الخريطة",
        );
        return;
      }

      final phone = _phoneController.text.trim();
      if (!RegExp(r'^(77|78|73|71)\d{7}$').hasMatch(phone)) {
        CustomSnackbar(
          context: context,
          snackBarType: SnackBarType.alert,
          label:
              "رقم الهاتف يجب أن يبدأ بـ 77 أو 78 أو 73 أو 71 ويتكون من 9 أرقام",
        );
        return;
      }

      final userId = await SharedPreferencesService.getUserId();
      if (!mounted) return;
      context
          .read<FacilityCubit>()
          .saveFacilityInfo(
            userName: widget.provider["user_name"],
            directorate: widget.provider['directorate'],
            facilityCategory: widget.provider["facility_category"],
            userId: userId!,
            facilityName: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            phoneNumber: phone,
            email: _emailController.text.trim(),
            address: _addressController.text.trim(),
            latitude: _selectedLocation!.latitude,
            longitude: _selectedLocation!.longitude,
            logoImage: _profileImageFile!,
            coverImage: _coverImageFile,
            businessHours: _businessHours,
            closingHours: _closingHours,
          )
          .then((_) {
        SharedPreferencesService.setProviderSetupComplete(true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeProviderView()),
        );
      });
    }
  }

  // ... (Rest of your existing UI code remains the same)
}

// ====== Updated LocationPickerScreen ======
class LocationPickerScreen extends StatefulWidget {
  final LatLng initialLocation;

  const LocationPickerScreen({super.key, required this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late GoogleMapController _mapController;
  LatLng? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حدد موقع المطعم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(
                  context, _selectedLocation ?? widget.initialLocation);
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialLocation,
          zoom: 15,
        ),
        onMapCreated: (controller) => _mapController = controller,
        onTap: (latLng) => setState(() => _selectedLocation = latLng),
        markers: _selectedLocation == null
            ? {}
            : {
                Marker(
                  markerId: const MarkerId('selectedLocation'),
                  position: _selectedLocation!,
                ),
              },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            Position position = await Geolocator.getCurrentPosition();
            LatLng currentLatLng =
                LatLng(position.latitude, position.longitude);
            _mapController.animateCamera(CameraUpdate.newLatLng(currentLatLng));
            setState(() => _selectedLocation = currentLatLng);
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: $e")),
            );
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
