import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_travels/presentation/provider/travel_provider.dart';
import 'package:provider/provider.dart';

// Importe seu provider

class SelectTransport extends StatelessWidget {
  const SelectTransport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TravelProvider>(
      builder: (context, provider, _) {
        provider.loadAvailableVehicles(context);

        return Container(
          // Ajustamos a altura para se adequar ao novo tamanho dos círculos
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.availableTransport.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final transport = provider.availableTransport[index];
              final bool isSelected = provider.isSelectedVehicle(transport);

              return GestureDetector(
                onTap: () => provider.selectVehicle(transport),

                // 2. O TEXTO FOI REMOVIDO
                // O Lottie agora é o filho direto, com um padding para respirar
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Lottie.asset(
                        transport.lottieAsset,
                        key: ValueKey(
                          isSelected,
                        ), // 1. A chave muda com a seleção
                        animate: isSelected,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transport.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.blue : Colors.transparent,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
