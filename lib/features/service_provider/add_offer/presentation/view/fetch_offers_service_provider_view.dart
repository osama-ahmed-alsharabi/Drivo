import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:drivo_app/core/util/app_images.dart';
import 'package:drivo_app/features/service_provider/add_offer/presentation/view/widgets/add_offer_page.dart';
import 'package:drivo_app/features/service_provider/add_offer/presentation/view/widgets/offer_card_widget.dart';
import 'package:drivo_app/features/service_provider/add_offer/presentation/view_model/fetch_offer_service_provider_cubit/fetch_offer_service_provider_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FetchOffersServiceProviderView extends StatefulWidget {
  const FetchOffersServiceProviderView({super.key});

  @override
  State<FetchOffersServiceProviderView> createState() =>
      _FetchOffersServiceProviderViewState();
}

class _FetchOffersServiceProviderViewState
    extends State<FetchOffersServiceProviderView> {
  @override
  void initState() {
    BlocProvider.of<FetchOfferServiceProviderCubit>(context)
        .fetchOfferServiceProvider();
    BlocProvider.of<FetchOfferServiceProviderCubit>(context).hasLoaded = false;
    super.initState();
  }

  Future<bool> _checkFacilityLocation() async {
    final userId = await SharedPreferencesService.getUserId();
    if (userId == null) return false;

    final response = await Supabase.instance.client
        .from('facilities')
        .select('latitude, longitude, address')
        .eq('id', userId)
        .single();

    return response['latitude'] != null &&
        response['longitude'] != null &&
        response['address'] != null;
  }

  void _showNotActiveSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('حسابك غير مفعل'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<bool> _checkFacilityActive() async {
    final userId = await SharedPreferencesService.getUserId();
    if (userId == null) return false;

    final response = await Supabase.instance.client
        .from('facilities')
        .select('is_active')
        .eq('id', userId)
        .single();

    return response['is_active'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('العروض'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final isActive = await _checkFacilityActive();
              if (!isActive) {
                _showNotActiveSnackBar(context);
                return;
              }

              final hasLocation = await _checkFacilityLocation();
              if (!hasLocation) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('قم بإضافة منطقة من الإعدادات أولاً'),
                  ),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddOfferServiceProviderPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<FetchOfferServiceProviderCubit,
          FetchOfferServiceProviderState>(
        builder: (context, state) {
          if (state is FetchOfferServiceProviderLoading) {
            return Center(child: Image.asset('assets/images/logo_waiting.gif'));
          } else if (BlocProvider.of<FetchOfferServiceProviderCubit>(context)
                  .offerModel
                  ?.isEmpty ??
              false) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Lottie.asset(AppImages.offerLottie),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "لاتوجد عروض بعد قم بإضافة عرض",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                )
              ],
            );
          }
          return state is FetchOfferServiceProviderFaulid
              ? LiquidPullToRefresh(
                  onRefresh: () async {
                    BlocProvider.of<FetchOfferServiceProviderCubit>(context)
                        .hasLoaded = true;
                    await BlocProvider.of<FetchOfferServiceProviderCubit>(
                            context)
                        .fetchOfferServiceProvider();
                    BlocProvider.of<FetchOfferServiceProviderCubit>(context)
                        .hasLoaded = false;
                  },
                  child: ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.4,
                      ),
                      Center(
                          child: Text(
                        state.errorMessage,
                        style: const TextStyle(color: Colors.black),
                      )),
                    ],
                  ),
                )
              : LiquidPullToRefresh(
                  onRefresh: () async {
                    BlocProvider.of<FetchOfferServiceProviderCubit>(context)
                        .hasLoaded = true;
                    await BlocProvider.of<FetchOfferServiceProviderCubit>(
                            context)
                        .fetchOfferServiceProvider();
                    BlocProvider.of<FetchOfferServiceProviderCubit>(context)
                        .hasLoaded = false;
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount:
                        BlocProvider.of<FetchOfferServiceProviderCubit>(context)
                            .offerModel
                            ?.length,
                    itemBuilder: (context, index) {
                      return OfferCard(
                        offer: BlocProvider.of<FetchOfferServiceProviderCubit>(
                                context)
                            .offerModel![index],
                      );
                    },
                  ),
                );
        },
      ),
    );
  }
}
