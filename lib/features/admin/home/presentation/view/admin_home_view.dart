import 'package:drivo_app/core/widgets/custom_text_form_field_widget.dart';
import 'package:drivo_app/features/admin/home/presentation/view/widgets/admin_app_bar_widget.dart';
import 'package:drivo_app/features/admin/home/presentation/view/widgets/admin_grid_view_widget.dart';
import 'package:drivo_app/features/admin/home/presentation/view_model/cubit/delivery_fee_cubit.dart';
import 'package:drivo_app/features/admin/home/presentation/view_model/exchange_cubit/exchange_cubit.dart';
import 'package:drivo_app/features/client/profile/presentation/views/widgets/logout_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              ExchangeCubit(Supabase.instance.client)..loadExchangeRate(),
        ),
        BlocProvider(
          create: (context) =>
              DeliveryFeeCubit(Supabase.instance.client)..loadDeliveryFee(),
        ),
      ],
      child: Scaffold(
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: CustomScrollView(
            physics:
                const ClampingScrollPhysics(), // Important for smooth scrolling
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const AdminAppBarWidget(
                      text: "لوحة تحكم المشرف",
                    ),
                    const SizedBox(height: 30),
                    _buildExchangeRateSection(context),
                    _buildDeliveryFeeSection(context),
                    const AdminGridViewWidget(),
                    SizedBox(height: 20.h),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: LogoutButtonWidget(),
                    ),
                    SizedBox(height: 20.h), // Extra padding at bottom
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExchangeRateSection(BuildContext context) {
    return BlocBuilder<ExchangeCubit, ExchangeState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state is ExchangeLoaded)
                Text(
                  'سعر الصرف الحالي: 1 ريال سعودي = ${state.rate} ريال يمني',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              SizedBox(height: 8.h),
              CustomTextFormFieldWidget(
                hintText: "قم بأدخال سعر الصرف الجديد",
                prefixIcon: Icon(FontAwesomeIcons.cashRegister, size: 18.sp),
                keyboardType: TextInputType.number,
                onChanged: (value) {},
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty) {
                    final newRate = double.tryParse(value);
                    if (newRate != null && newRate > 0) {
                      context.read<ExchangeCubit>().updateExchangeRate(newRate);
                    }
                  }
                },
              ),
              if (state is ExchangeLoading)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: const LinearProgressIndicator(),
                ),
              if (state is ExchangeError)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeliveryFeeSection(BuildContext context) {
    return BlocBuilder<DeliveryFeeCubit, DeliveryFeeState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state is DeliveryFeeLoaded)
                Text(
                  'سعر التوصيل الحالي: ${state.feePerKm} ريال لكل كيلومتر',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              SizedBox(height: 8.h),
              CustomTextFormFieldWidget(
                hintText: "قم بأدخال سعر التوصيل الجديد لكل كيلومتر",
                prefixIcon: Icon(FontAwesomeIcons.truck, size: 18.sp),
                keyboardType: TextInputType.number,
                onChanged: (value) {},
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty) {
                    final newFee = double.tryParse(value);
                    if (newFee != null && newFee > 0) {
                      context
                          .read<DeliveryFeeCubit>()
                          .updateDeliveryFee(newFee);
                    }
                  }
                },
              ),
              if (state is DeliveryFeeLoading)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: const LinearProgressIndicator(),
                ),
              if (state is DeliveryFeeError)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
