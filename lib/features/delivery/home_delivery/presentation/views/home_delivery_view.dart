import 'dart:async';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:drivo_app/features/client/cart/data/model/order_model.dart';
import 'package:drivo_app/features/client/profile/presentation/views/widgets/logout_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeDeliveryView extends StatefulWidget {
  const HomeDeliveryView({super.key});

  @override
  HomeDeliveryViewState createState() => HomeDeliveryViewState();
}

class HomeDeliveryViewState extends State<HomeDeliveryView> {
  int _currentIndex = 2;
  Position? _currentPosition;
  late StreamSubscription<Position> _positionStream;
  double _exchangeRate = 1.0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _setupLocationUpdates();
    _fetchExchangeRate();
  }

  @override
  void dispose() {
    _positionStream.cancel();
    super.dispose();
  }

  Future<void> _fetchExchangeRate() async {
    try {
      final response = await Supabase.instance.client
          .from('exchange_rate')
          .select('rate')
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        setState(() {
          _exchangeRate = (response[0]['rate'] as num).toDouble();
        });
      }
    } catch (e) {
      debugPrint('خطأ في جلب سعر الصرف: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('خدمة الموقع غير مفعلة');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('تم رفض أذونات الموقع');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('أذونات الموقع مرفوضة بشكل دائم');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() => _currentPosition = position);
      }
      await _updateDeliveryLocation(position);
    } catch (e) {
      debugPrint('خطأ في الحصول على الموقع الحالي: $e');
    }
  }

  void _setupLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      if (mounted) {
        setState(() => _currentPosition = position);
      }
      _updateDeliveryLocation(position);
    });
  }

  Future<void> _updateDeliveryLocation(Position position) async {
    try {
      final userId = await SharedPreferencesService.getUserId();
      final userName = await SharedPreferencesService.getUserName();
      if (userId == null && userName == null) {
        debugPrint('لم يتم العثور على معرف المستخدم');
        return;
      }

      final response = await Supabase.instance.client.from('delivery').upsert({
        'id': userId,
        'user_name': userName,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'updated_at': DateTime.now().toIso8601String(),
      });

      debugPrint('تم تحديث موقع التوصيل بنجاح: ${position.toJson()}');
    } catch (e) {
      debugPrint('خطأ في تحديث موقع التوصيل: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ProfileScreen(exchangeRate: _exchangeRate),
          CompletedOrdersScreen(exchangeRate: _exchangeRate),
          NewOrdersScreen(exchangeRate: _exchangeRate),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.person, size: 30, color: Colors.black),
          Icon(Icons.check_circle, size: 30, color: Colors.black),
          Icon(Icons.list_alt, size: 30, color: Colors.black),
        ],
        color: Colors.white,
        buttonBackgroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// باقي الأكواد تبقى كما هي بدون تغيير (NewOrdersScreen, CompletedOrdersScreen, OrderCard, OrderDetailsScreen, ProfileScreen, etc.)
class NewOrdersScreen extends StatefulWidget {
  final double exchangeRate;

  const NewOrdersScreen({super.key, required this.exchangeRate});

  @override
  State<NewOrdersScreen> createState() => _NewOrdersScreenState();
}

class _NewOrdersScreenState extends State<NewOrdersScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  final GlobalKey<LiquidPullToRefreshState> _refreshKey =
      GlobalKey<LiquidPullToRefreshState>();
  @override
  void initState() {
    _fetchOrders();
    super.initState();
  }

  Future<void> _fetchOrders() async {
    try {
      String? userId = await SharedPreferencesService.getUserId();
      final response = await Supabase.instance.client
          .from('orders')
          .select()
          .eq("delivery_id", userId!)
          .eq('order_status', 'shipped')
          .order('created_at', ascending: false);

      setState(() {
        _orders =
            (response as List).map((json) => Order.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحميل الطلبات: $e')),
      );
    }
  }

  Future<void> _refresh() async {
    await _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('الطلبات الجديدة'),
        centerTitle: true,
      ),
      body: LiquidPullToRefresh(
        key: _refreshKey,
        onRefresh: _refresh,
        color: Theme.of(context).primaryColor,
        height: 150,
        animSpeedFactor: 2,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _orders.isEmpty
                ? ListView(children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.4,
                    ),
                    const Center(child: Text('لا توجد طلبات جديدة'))
                  ])
                : ListView.builder(
                    itemCount: _orders.length,
                    itemBuilder: (context, index) => OrderCard(
                      order: _orders[index],
                      exchangeRate: widget.exchangeRate,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsScreen(
                            order: _orders[index],
                            exchangeRate: widget.exchangeRate,
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}

class CompletedOrdersScreen extends StatefulWidget {
  final double exchangeRate;

  const CompletedOrdersScreen({super.key, required this.exchangeRate});

  @override
  State<CompletedOrdersScreen> createState() => _CompletedOrdersScreenState();
}

class _CompletedOrdersScreenState extends State<CompletedOrdersScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  final GlobalKey<LiquidPullToRefreshState> _refreshKey =
      GlobalKey<LiquidPullToRefreshState>();

  Future<void> _fetchOrders() async {
    try {
      String? userId = await SharedPreferencesService.getUserId();

      final response = await Supabase.instance.client
          .from('orders')
          .select()
          .eq('order_status', 'delivered')
          .eq("delivery_id", userId!)
          .order('created_at', ascending: false);

      setState(() {
        _orders =
            (response as List).map((json) => Order.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحميل الطلبات: $e')),
      );
    }
  }

  Future<void> _refresh() async {
    await _fetchOrders();
  }

  @override
  void initState() {
    _fetchOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('الطلبات المكتملة'),
        centerTitle: true,
      ),
      body: LiquidPullToRefresh(
        key: _refreshKey,
        onRefresh: _refresh,
        color: Theme.of(context).primaryColor,
        height: 150,
        animSpeedFactor: 2,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _orders.isEmpty
                ? ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.4,
                      ),
                      const Center(child: Text('لا توجد طلبات مكتملة')),
                    ],
                  )
                : ListView.builder(
                    itemCount: _orders.length,
                    itemBuilder: (context, index) => OrderCard(
                      order: _orders[index],
                      exchangeRate: widget.exchangeRate,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsScreen(
                            order: _orders[index],
                            isCompleted: true,
                            exchangeRate: widget.exchangeRate,
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final double exchangeRate;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.exchangeRate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderNumber,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Chip(
                    label: Text(order.status.displayText,
                        style: const TextStyle(color: Colors.white)),
                    backgroundColor: order.status.color,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('العنوان: ${order.deliveryAddress.address}',
                  style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    PriceConverter.displayConvertedPrice(
                      saudiPrice: order.totalAmount,
                      exchangeRate: exchangeRate,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${order.items.length} عنصر',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderDetailsScreen extends StatefulWidget {
  final Order order;
  final bool isCompleted;
  final double exchangeRate;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    this.isCompleted = false,
    required this.exchangeRate,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isLoading = true;
  Position? _currentPosition;
  List<Map<String, dynamic>> _restaurants = [];
  MarkerId? _selectedMarkerId;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchRestaurants();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _updateMapMarkers();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في الحصول على الموقع: $e')),
        );
      }
    }
  }

  Future<void> _fetchRestaurants() async {
    try {
      final restaurantIds =
          widget.order.items.map((item) => item.restaurantId).toSet().toList();

      if (restaurantIds.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _updateMapMarkers();
          });
        }
        return;
      }

      final response = await Supabase.instance.client
          .from('facilities')
          .select()
          .or(restaurantIds.map((id) => 'id.eq.$id').join(','));

      if (mounted) {
        setState(() {
          _restaurants = (response as List).cast<Map<String, dynamic>>();
          _isLoading = false;
          _updateMapMarkers();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في تحميل المطاعم: $e')),
        );
      }
    }
  }

  void _updateMapMarkers() {
    if (_currentPosition == null) return;

    final markers = <Marker>{};

    // Add current location marker
    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position:
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        infoWindow: const InfoWindow(title: 'موقعك الحالي'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        onTap: () => _onMarkerTapped(const MarkerId('current_location')),
      ),
    );

    // Add customer location marker
    markers.add(
      Marker(
        markerId: const MarkerId('customer_location'),
        position: LatLng(widget.order.deliveryAddress.latitude,
            widget.order.deliveryAddress.longitude),
        infoWindow: InfoWindow(
            title: 'موقع العميل',
            snippet: widget.order.deliveryAddress.address),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onTap: () => _onMarkerTapped(const MarkerId('customer_location')),
      ),
    );

    // Add restaurant markers
    for (final restaurant in _restaurants) {
      final lat = restaurant['latitude'] as double?;
      final lng = restaurant['longitude'] as double?;
      if (lat == null || lng == null) continue;

      final markerId = MarkerId('restaurant_${restaurant['id']}');
      markers.add(
        Marker(
          markerId: markerId,
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: restaurant['name'] as String? ?? 'مطعم',
            snippet: restaurant['address'] as String?,
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          onTap: () => _onMarkerTapped(markerId),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers.clear();
        _markers.addAll(markers);
      });
    }

    _updateCameraPosition();
  }

  void _onMarkerTapped(MarkerId markerId) {
    setState(() {
      _selectedMarkerId = markerId;
      _updatePolylines();
    });
  }

  void _updatePolylines() {
    if (_currentPosition == null || _selectedMarkerId == null) return;

    final polylines = <Polyline>{};
    final selectedMarker =
        _markers.firstWhere((marker) => marker.markerId == _selectedMarkerId);

    polylines.add(
      Polyline(
        polylineId: PolylineId('route_to_${_selectedMarkerId!.value}'),
        points: [
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          selectedMarker.position,
        ],
        color: Colors.blue,
        width: 4,
      ),
    );

    setState(() {
      _polylines.clear();
      _polylines.addAll(polylines);
    });

    _updateCameraPosition();
  }

  void _updateCameraPosition() {
    if (_mapController == null || _markers.isEmpty) return;

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(_boundsFromMarkers(_markers), 50.0),
    );
  }

  LatLngBounds _boundsFromMarkers(Set<Marker> markers) {
    double? minLat, maxLat, minLng, maxLng;
    for (final marker in markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;

      minLat = minLat == null ? lat : (lat < minLat ? lat : minLat);
      maxLat = maxLat == null ? lat : (lat > maxLat ? lat : maxLat);
      minLng = minLng == null ? lng : (lng < minLng ? lng : minLng);
      maxLng = maxLng == null ? lng : (lng > maxLng ? lng : maxLng);
    }

    return LatLngBounds(
      northeast: LatLng(maxLat!, maxLng!),
      southwest: LatLng(minLat!, minLng!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(widget.order.orderNumber),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderSummary(),
                  _buildMapSection(),
                  _buildItemsList(),
                  _buildDeliveryAddress(),
                  // if (!widget.isCompleted) _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.order.orderNumber,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Chip(
                  label: Text(widget.order.status.displayText,
                      style: const TextStyle(color: Colors.white)),
                  backgroundColor: widget.order.status.color,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('طريقة الدفع: ${widget.order.paymentMethod.displayText}'),
                Text('التاريخ: ${_formatDate(widget.order.createdAt)}'),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('المجموع الفرعي:'),
                Text(PriceConverter.displayConvertedPrice(
                  saudiPrice: widget.order.subtotal,
                  exchangeRate: widget.exchangeRate,
                )),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('رسوم التوصيل:'),
                Text(PriceConverter.displayConvertedPrice(
                  saudiPrice: widget.order.deliveryFee,
                  exchangeRate: widget.exchangeRate,
                )),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الخصم:'),
                Text(PriceConverter.displayConvertedPrice(
                  saudiPrice: widget.order.discount,
                  exchangeRate: widget.exchangeRate,
                )),
              ],
            ),
            const SizedBox(height: 4),
            const Divider(),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('المجموع الكلي:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  PriceConverter.displayConvertedPrice(
                    saudiPrice: widget.order.totalAmount,
                    exchangeRate: widget.exchangeRate,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Card(
      margin: const EdgeInsets.all(10),
      child: SizedBox(
        height: 300,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.order.deliveryAddress.latitude,
                  widget.order.deliveryAddress.longitude,
                ),
                zoom: 14,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: true,
              onMapCreated: (controller) {
                setState(() => _mapController = controller);
                _updateMapMarkers();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('الطلبات',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ...widget.order.items.map((item) => ListTile(
                leading: const Icon(Icons.fastfood),
                title: Text(item.productName),
                subtitle: Text(
                    '${item.quantity} × ${PriceConverter.displayConvertedPrice(
                  saudiPrice: item.unitPrice,
                  exchangeRate: widget.exchangeRate,
                )}'),
                trailing: Text(
                  PriceConverter.displayConvertedPrice(
                    saudiPrice: item.quantity * item.unitPrice,
                    exchangeRate: widget.exchangeRate,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('عنوان التوصيل',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(widget.order.deliveryAddress.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.order.deliveryAddress.address),
            if (widget.order.customerNotes != null) ...[
              const SizedBox(height: 8),
              const Text('ملاحظات العميل:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(widget.order.customerNotes!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          if (widget.order.status == OrderStatus.pending)
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _completeDelivery,
                child: const Text(
                  'تم استلام الطلب',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
              ),
            ),
          if (widget.order.status == OrderStatus.readyForDelivery)
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _startDelivery,
                child: const Text('بدء التوصيل'),
              ),
            ),
          if (widget.order.status == OrderStatus.shipped)
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _completeDelivery,
                child: const Text('تم التوصيل'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _acceptOrder() async {
    try {
      await Supabase.instance.client.from('orders').update({
        'delivery_status': 'accepted',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', widget.order.id);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم قبول الطلب بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في قبول الطلب: $e')),
      );
    }
  }

  Future<void> _startDelivery() async {
    try {
      await Supabase.instance.client.from('orders').update({
        'delivery_status': 'shipped',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', widget.order.id);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم بدء التوصيل بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في بدء التوصيل: $e')),
      );
    }
  }

  Future<void> _completeDelivery() async {
    try {
      await Supabase.instance.client.from('orders').update({
        'delivery_status': 'delivered',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', widget.order.id);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تأكيد التوصيل بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تأكيد التوصيل: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}

class ProfileScreen extends StatefulWidget {
  final double exchangeRate;

  const ProfileScreen({super.key, required this.exchangeRate});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _deliveryInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDeliveryInfo();
  }

  Future<void> _fetchDeliveryInfo() async {
    try {
      final userId = await SharedPreferencesService.getUserId();
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('delivery')
          .select('user_name, phone_number, directorate')
          .eq('id', userId)
          .eq("is_active", true)
          .single();

      setState(() {
        _deliveryInfo = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error fetching delivery info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('الملف الشخصي'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    _deliveryInfo?['user_name'] ?? 'اسم الموصل',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildProfileItem(
                            Icons.phone,
                            'الجوال',
                            _deliveryInfo?['phone_number'] ?? 'غير متوفر',
                            context,
                          ),
                          const Divider(),
                          _buildProfileItem(
                            Icons.location_city,
                            'المديرية',
                            _deliveryInfo?['directorate'] ?? 'غير متوفر',
                            context,
                          ),
                          const Divider(),
                          _buildProfileItem(
                            Icons.currency_exchange,
                            'سعر الصرف الحالي',
                            '${widget.exchangeRate} ريال يمني / ريال سعودي',
                            context,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const LogoutButtonWidget(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileItem(
      IconData icon, String title, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 5),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class PriceConverter {
  static final _formatter = NumberFormat('#,###.##');

  static double convertToYemeni({
    required double saudiPrice,
    required double exchangeRate,
  }) {
    return saudiPrice * exchangeRate;
  }

  static String displayConvertedPrice({
    required double saudiPrice,
    required double exchangeRate,
    bool showBoth = false,
  }) {
    final yemeniPrice = convertToYemeni(
      saudiPrice: saudiPrice,
      exchangeRate: exchangeRate,
    );

    if (showBoth) {
      return '${_formatter.format(saudiPrice)} ر.س (≈ ${_formatter.format(yemeniPrice)} ريال يمني)';
    } else {
      return '${_formatter.format(yemeniPrice)} ريال يمني';
    }
  }

  static String formatNumberWithCommas(double number) {
    return _formatter.format(number);
  }
}
