import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:drivo_app/features/client/address/presentation/view_model/cubit/address_cubit.dart';
import 'package:drivo_app/features/client/address/presentation/view_model/cubit/address_state.dart';

class AddAddressMapScreen extends StatefulWidget {
  final Map<String, dynamic>? initialAddress;
  const AddAddressMapScreen({super.key, this.initialAddress});

  @override
  State<AddAddressMapScreen> createState() => _AddAddressMapScreenState();
}

class _AddAddressMapScreenState extends State<AddAddressMapScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  bool _isSaving = false;
  bool _isLoadingLocation = true;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.initialAddress?['title'] ?? '');
    _notesController = TextEditingController(
        text: widget.initialAddress?['additionalInfo'] ?? '');

    // Initialize with existing data if editing
    if (widget.initialAddress != null) {
      _currentAddress = widget.initialAddress!['address'];
      _selectedPosition = LatLng(
        widget.initialAddress!['latitude'],
        widget.initialAddress!['longitude'],
      );
      _isLoadingLocation = false;
    }

    _initializePosition();
  }

  void _initializePosition() async {
    if (widget.initialAddress == null) {
      // Only fetch current location for new addresses
      try {
        final position =
            await context.read<AddressCubit>().getCurrentLocation();
        if (position != null && mounted) {
          setState(() {
            _selectedPosition = position;
            _isLoadingLocation = false;
          });
          _moveCamera(position);

          // Get address for current location
          final state = context.read<AddressCubit>().state;
          if (state is LocationSelected && mounted) {
            setState(() {
              _currentAddress = state.address;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoadingLocation = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل الحصول على الموقع: ${e.toString()}')),
          );
        }
      }
    } else if (mounted) {
      // For editing, just move camera to existing position
      _moveCamera(_selectedPosition!);
    }
  }

  Future<void> _moveCamera(LatLng position) async {
    try {
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(position, 16),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ في تحريك الخريطة')),
        );
      }
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate we have required data
    if (_selectedPosition == null || _currentAddress == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء التأكد من تحديد موقع صحيح')),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      final cubit = context.read<AddressCubit>();
      if (widget.initialAddress != null) {
        // Editing existing address
        await cubit.updateAddress({
          'id': widget.initialAddress!['id'],
          'title': _titleController.text,
          'address': _currentAddress!,
          'latitude': _selectedPosition!.latitude,
          'longitude': _selectedPosition!.longitude,
          'additionalInfo': _notesController.text,
          'isDefault': widget.initialAddress!['isDefault'] == 1,
        });
      } else {
        // Adding new address
        await cubit.saveAddress(
          title: _titleController.text,
          address: _currentAddress!,
          position: _selectedPosition!,
          additionalInfo: _notesController.text,
        );
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ في حفظ العنوان: ${e.toString()}')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(widget.initialAddress != null
            ? 'تعديل العنوان'
            : 'إضافة عنوان جديد'),
        actions: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          if (!_isLoadingLocation && _selectedPosition != null)
            GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
                if (widget.initialAddress != null) {
                  _moveCamera(_selectedPosition!);
                }
              },
              initialCameraPosition: CameraPosition(
                target: _selectedPosition ?? const LatLng(0, 0),
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('selected_location'),
                  position: _selectedPosition!,
                  draggable: widget.initialAddress == null,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                  onDragEnd: widget.initialAddress == null
                      ? (newPosition) async {
                          setState(() => _selectedPosition = newPosition);
                          try {
                            await context
                                .read<AddressCubit>()
                                .getAddressFromPosition(newPosition);
                            if (!context.mounted) return;
                            final state = context.read<AddressCubit>().state;
                            if (state is LocationSelected && mounted) {
                              setState(() {
                                _currentAddress = state.address;
                              });
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('فشل تحديث العنوان')),
                              );
                            }
                          }
                        }
                      : null,
                ),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              onTap: widget.initialAddress == null
                  ? (position) async {
                      setState(() => _selectedPosition = position);
                      try {
                        await context
                            .read<AddressCubit>()
                            .getAddressFromPosition(position);
                        if (!context.mounted) return;
                        final state = context.read<AddressCubit>().state;
                        if (state is LocationSelected && mounted) {
                          setState(() {
                            _currentAddress = state.address;
                          });
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('فشل تحديث العنوان')),
                        );
                      }
                    }
                  : null,
            ),
          if (_isLoadingLocation)
            const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildAddressForm(),
          ),
        ],
      ),
      floatingActionButton: widget.initialAddress == null
          ? FloatingActionButton(
              onPressed: () async {
                setState(() => _isLoadingLocation = true);
                try {
                  final position =
                      await context.read<AddressCubit>().getCurrentLocation();
                  if (position != null && mounted) {
                    setState(() {
                      _selectedPosition = position;
                      _isLoadingLocation = false;
                    });
                    _moveCamera(position);
                    if (!context.mounted) return;
                    final state = context.read<AddressCubit>().state;
                    if (state is LocationSelected && mounted) {
                      setState(() {
                        _currentAddress = state.address;
                      });
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() => _isLoadingLocation = false);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('فشل الحصول على الموقع: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Icon(Icons.my_location),
            )
          : null,
    );
  }

  Widget _buildAddressForm() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'اسم العنوان',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  readOnly: true,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'العنوان',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  controller:
                      TextEditingController(text: _currentAddress ?? ''),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'ملاحظات إضافية (اختياري)',
                    prefixIcon: const Icon(Icons.notes),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'حفظ العنوان',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('إلغاء'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
