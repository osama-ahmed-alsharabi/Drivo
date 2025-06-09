import 'package:drivo_app/core/routes/app_routes.dart';
import 'package:drivo_app/core/service/local_database_service.dart';
import 'package:drivo_app/core/service/notification_services.dart';
import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:drivo_app/core/theme/light_theme.dart';
import 'package:drivo_app/features/auth/singup/presentation/view_model/signUp_cubit/singup_cubit.dart';
import 'package:drivo_app/features/client/address/presentation/view_model/cubit/address_cubit.dart';
import 'package:drivo_app/features/client/cart/presentation/view_model/cart_cubit/cart_cubit.dart';
import 'package:drivo_app/features/client/cart/presentation/view_model/order_cubit/order_cubit.dart';
import 'package:drivo_app/features/client/favorite/presentation/view_model/cubit/favorite_cubit.dart';
import 'package:drivo_app/features/client/home/presentation/view_model/category_cubit/category_cubit.dart';
import 'package:drivo_app/features/client/home/presentation/view_model/fetch_client_offers/fetch_client_offer_cubit.dart';
import 'package:drivo_app/features/client/home/presentation/view_model/fetch_client_products/fetch_client_products_cubit.dart';
import 'package:drivo_app/features/client/profile/data/user_order_repo.dart';
import 'package:drivo_app/features/client/profile/presentation/view_model/cubit/user_order_cubit.dart';
import 'package:drivo_app/features/client/restaurant_list/presentation/view_model/cubit/restaurant_list_cubit.dart';
import 'package:drivo_app/features/service_provider/add_offer/presentation/view_model/adding_offer_service_provider_cubit/adding_offer_service_provider_cubit.dart';
import 'package:drivo_app/features/service_provider/add_offer/presentation/view_model/fetch_offer_service_provider_cubit/fetch_offer_service_provider_cubit.dart';
import 'package:drivo_app/features/service_provider/edit_service_profile_screen/presentation/view_model/cubit/edit_service_provider_profile_cubit.dart';
import 'package:drivo_app/features/service_provider/first_page/presentation/view_model/cubit/facility_cubit.dart';
import 'package:drivo_app/features/service_provider/product/presetation/view_model/add_product/add_product_cubit.dart';
import 'package:drivo_app/features/service_provider/product/presetation/view_model/fetch_product_service_provider/fetch_product_service_provider_cubit.dart';
import 'package:drivo_app/features/service_provider/profile_provider/Presentation/view_model/cubit/service_provider_profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://birkgqtjhsfqtyaocjfu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJpcmtncXRqaHNmcXR5YW9jamZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc1OTE0MzIsImV4cCI6MjA2MzE2NzQzMn0.gYzn12TSrTPeZtg8UyJbqBvMsHJS9Eai8WDdG4h2H6k',
  );
  await NotificationServices().init();
  await SharedPreferencesService.init();
  final databaseService = DatabaseService();
  runApp(
    RepositoryProvider(
      create: (context) => databaseService,
      child: const Drivo(),
    ),
  );
}

class Drivo extends StatelessWidget {
  const Drivo({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => DatabaseService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => RestaurantListCubit(),
          ),
          BlocProvider(
            create: (context) => UserOrdersCubit(UserOrdersRepository()),
          ),
          BlocProvider(
            create: (context) => OrderCubit(),
          ),
          BlocProvider(
            create: (context) => AddressCubit(
              databaseService: context.read<DatabaseService>(),
            )..loadAddresses(),
          ),
          BlocProvider(
            create: (context) => CartCubit(),
          ),
          BlocProvider(
            create: (context) => SignupCubit(),
          ),
          BlocProvider(
            create: (context) => AddOfferCubit(),
          ),
          BlocProvider(
            create: (context) => AddProductCubit(),
          ),
          BlocProvider(
            create: (context) => FavoriteCubit(),
          ),
          BlocProvider(
            create: (context) =>
                FetchOfferServiceProviderCubit()..hasLoaded = true,
          ),
          BlocProvider(
            create: (context) =>
                FetchProductsServiceProviderCubit()..hasLoaded = true,
          ),
          BlocProvider(
            create: (context) => FacilityCubit()..hasLoaded = true,
          ),
          BlocProvider(
            create: (context) => ServiceProviderProfileCubit(
              supabaseClient: Supabase.instance.client,
            ),
          ),
          BlocProvider(create: (context) => EditServiceProviderProfileCubit()),
          BlocProvider(
              create: (context) => FetchClientOfferCubit()..hasLoaded = true),
          BlocProvider(create: (context) => CategoryCubit()..hasLoaded = true),
          BlocProvider(
              create: (context) =>
                  FetchClientProductsCubit()..hasLoaded = true),
        ],
        child: ScreenUtilInit(
          designSize: const Size(360, 690), // Your design size
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: light(),
              initialRoute: AppRoutes.splashRoute,
              routes: AppRoutes.routes,
            );
          },
        ),
      ),
    );
  }
}
