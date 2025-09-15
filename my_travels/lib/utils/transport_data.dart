import 'package:flutter/material.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/model/transport_model.dart';

/// Returns a list of all available transport models.
///
/// This function centralizes the logic so it can be used on multiple screens,
/// providing translated labels and theme-aware Lottie assets.
List<TransportModel> getAvailableVehicles(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  const String lottiePath = 'assets/images/lottie/typelocomotion/';

  return [
    TransportModel(
      label: l10n.vehicleCar,
      lottieAsset: isDarkMode
          ? '${lottiePath}car_dark.json'
          : '${lottiePath}car.json',
    ),
    TransportModel(
      label: l10n.vehicleMotorcycle,
      lottieAsset: '${lottiePath}motorcycle.json',
    ),
    TransportModel(
      label: l10n.vehicleBus,
      lottieAsset: '${lottiePath}bus.json',
    ),
    TransportModel(
      label: l10n.vehicleAirplane,
      lottieAsset: '${lottiePath}airplane.json',
    ),
    TransportModel(
      label: l10n.vehicleCruise,
      lottieAsset: isDarkMode
          ? '${lottiePath}cruise_dark.json'
          : '${lottiePath}cruise.json',
    ),
  ];
}
