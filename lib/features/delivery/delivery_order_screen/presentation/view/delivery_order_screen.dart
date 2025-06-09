import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeliveryOrdersScreen extends StatelessWidget {
  const DeliveryOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الطلبات'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'الجديدة'),
              Tab(text: 'قيد التوصيل'),
              Tab(text: 'المكتملة'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrdersList(status: 'new'),
            _buildOrdersList(status: 'delivering'),
            _buildOrdersList(status: 'completed'),
          ],
        ),
        bottomNavigationBar: _buildBottomNavBar(context, 1),
      ),
    );
  }

  Widget _buildOrdersList({required String status}) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      itemBuilder: (context, index) => Card(
        margin: EdgeInsets.only(bottom: 12.h),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'طلب #${1000 + index}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Chip(
                    backgroundColor: _getStatusColor(status).withOpacity(0.2),
                    label: Text(_getStatusText(status)),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              const Divider(),
              SizedBox(height: 8.h),
              _buildInfoRow(Icons.person, 'عميل ${index + 1}'),
              _buildInfoRow(Icons.location_on, 'عنوان العميل ${index + 1}'),
              _buildInfoRow(Icons.attach_money, '${30 + index * 5} ر.س'),
              SizedBox(height: 12.h),
              if (status != 'completed')
                Row(
                  children: [
                    if (status == 'new')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('قبول الطلب'),
                        ),
                      ),
                    if (status == 'delivering') ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('التفاصيل'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('تم التوصيل'),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'new':
        return Colors.blue;
      case 'delivering':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'new':
        return 'جديدة';
      case 'delivering':
        return 'قيد التوصيل';
      case 'completed':
        return 'مكتملة';
      default:
        return 'غير معروف';
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 20.w, color: Colors.grey),
          SizedBox(width: 8.w),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'الطلبات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'الحساب',
        ),
      ],
    );
  }
}
