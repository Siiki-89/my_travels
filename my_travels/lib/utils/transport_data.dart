import 'package:flutter/material.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/model/transport_model.dart';

/// Retorna a lista de todos os modelos de transporte disponíveis.
/// Esta função centraliza a lógica para que possa ser usada em várias telas.
List<TransportModel> getAvailableVehicles(BuildContext context) {
  final appLocalizations = AppLocalizations.of(context)!;
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  const String lottiePath = 'assets/images/lottie/typelocomotion/';

  return [
    TransportModel(
      label: appLocalizations.vehicleCar,
      lottieAsset: isDarkMode
          ? '${lottiePath}car_dark.json'
          : '${lottiePath}car.json',
    ),
    TransportModel(
      label: appLocalizations.vehicleMotorcycle,
      lottieAsset: '${lottiePath}motorcycle.json',
    ),
    TransportModel(
      label: appLocalizations.vehicleBus,
      lottieAsset: '${lottiePath}bus.json',
    ),
    TransportModel(
      label: appLocalizations.vehicleAirplane,
      lottieAsset: '${lottiePath}airplane.json',
    ),
    TransportModel(
      label: appLocalizations.vehicleCruise,
      lottieAsset: isDarkMode
          ? '${lottiePath}cruise_dark.json'
          : '${lottiePath}cruise.json',
    ),
  ];
}
