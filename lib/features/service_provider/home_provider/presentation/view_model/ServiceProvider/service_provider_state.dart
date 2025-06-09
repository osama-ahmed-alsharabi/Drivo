import 'package:drivo_app/features/service_provider/home_provider/presentation/views/service_provider_model.dart';

abstract class ServiceProviderState {}

class ServiceProviderInitial extends ServiceProviderState {}

class ServiceProviderLoading extends ServiceProviderState {}

class ServiceProviderLoaded extends ServiceProviderState {
  final ServiceProviderModel provider;

  ServiceProviderLoaded(this.provider);
}

class ServiceProviderError extends ServiceProviderState {
  final String message;

  ServiceProviderError(this.message);
}
