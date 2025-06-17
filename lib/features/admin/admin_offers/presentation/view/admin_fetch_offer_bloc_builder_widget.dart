import 'package:drivo_app/core/util/app_images.dart';
import 'package:drivo_app/features/admin/admin_offers/presentation/view_model/admin_fetch_offer_cubit/admin_fetch_offers_cubit.dart';
import 'package:drivo_app/features/service_provider/add_offer/presentation/view/widgets/offer_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';

class AdminFetchOfferBlocBuilderWidget extends StatefulWidget {
  const AdminFetchOfferBlocBuilderWidget({
    super.key,
  });

  @override
  State<AdminFetchOfferBlocBuilderWidget> createState() =>
      _AdminFetchOfferBlocBuilderWidgetState();
}

class _AdminFetchOfferBlocBuilderWidgetState
    extends State<AdminFetchOfferBlocBuilderWidget> {
  @override
  void initState() {
    BlocProvider.of<AdminFetchOffersCubit>(context).adminFetchOffers();
    BlocProvider.of<AdminFetchOffersCubit>(context).hasLoaded = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminFetchOffersCubit, AdminFetchOffersState>(
      builder: (context, state) {
        if (state is AdminFetchOffersLoading) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Center(child: Image.asset('assets/images/logo_waiting.gif')),
            ],
          );
        } else if (BlocProvider.of<AdminFetchOffersCubit>(context)
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
        return state is AdminFetchOffersFauiler
            ? Center(
                child: Text(
                state.errorMessage,
                style: const TextStyle(color: Colors.black),
              ))
            : Expanded(
                child: LiquidPullToRefresh(
                  onRefresh: () async {
                    BlocProvider.of<AdminFetchOffersCubit>(context).hasLoaded =
                        true;
                    await BlocProvider.of<AdminFetchOffersCubit>(context)
                        .adminFetchOffers();
                    if (!context.mounted) return;
                    BlocProvider.of<AdminFetchOffersCubit>(context).hasLoaded =
                        false;
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
                    itemCount: BlocProvider.of<AdminFetchOffersCubit>(context)
                        .offerModel
                        ?.length,
                    itemBuilder: (context, index) {
                      return OfferCard(
                        offer: BlocProvider.of<AdminFetchOffersCubit>(context)
                            .offerModel![index],
                        isAdmin: true,
                      );
                    },
                  ),
                ),
              );
      },
    );
  }
}
