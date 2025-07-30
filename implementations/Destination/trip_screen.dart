// trip_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'trip_provider.dart';

class TripScreen extends StatelessWidget {
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos context.watch para 'ouvir' as mudanças no TripProvider.
    // Sempre que notifyListeners é chamado, este widget é reconstruído.
    final tripProvider = context.watch<TripProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planejador de Viagem'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo de Partida
              TextFormField(
                controller: tripProvider.startLocationController,
                decoration: const InputDecoration(
                  labelText: 'Local de Partida',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flight_takeoff),
                ),
              ),
              const SizedBox(height: 24),

              // Lista de Destinos
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tripProvider.destinations.length,
                itemBuilder: (context, index) {
                  final destination = tripProvider.destinations[index];
                  return DestinationCard(
                    destination: destination,
                    // Passamos o provider para evitar múltiplas buscas no contexto.
                    provider: tripProvider,
                  );
                },
              ),
              const SizedBox(height: 20),

              // Botão para Adicionar mais Destinos
              ElevatedButton.icon(
                onPressed: () {
                  // Usamos context.read aqui porque estamos apenas chamando um método.
                  // Não precisamos 'ouvir' por mudanças dentro de um callback de clique.
                  context.read<TripProvider>().addDestination();
                },
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Adicionar Destino'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget para exibir o card de cada destino, mantendo o código organizado.
class DestinationCard extends StatelessWidget {
  final Destination destination;
  final TripProvider provider;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.provider,
  });

  Future<void> _selectDate(BuildContext context, bool isArrival) async {
    final initialDate =
        (isArrival ? destination.arrivalDate : destination.departureDate) ??
        DateTime.now();
    final firstDate = DateTime(2020);
    final lastDate = DateTime(2100);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      if (isArrival) {
        provider.updateArrivalDate(destination.id, pickedDate);
      } else {
        provider.updateDepartureDate(destination.id, pickedDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Destino ${destination.id + 1}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: destination.nameController,
              decoration: const InputDecoration(
                labelText: 'Cidade de Destino',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: destination.descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição (o que fará aqui?)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            // Seleção de Datas
            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(
                    context: context,
                    label: 'Chegada',
                    date: destination.arrivalDate,
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDateSelector(
                    context: context,
                    label: 'Saída',
                    date: destination.departureDate,
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Exibição do Tempo de Permanência
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Text(
                    'Tempo na cidade: ${provider.calculateDuration(destination)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(provider.formatDate(date)),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}
