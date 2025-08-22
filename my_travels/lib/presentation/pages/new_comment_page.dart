import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class NewCommentPage extends StatelessWidget {
  const NewCommentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar comentario'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Viagem para ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 16),
            Text('Participante a comentar:'),
            SizedBox(height: 8),
            DropdownButtonHideUnderline(
              child: DropdownButton2(items: [], onChanged: null),
            ),
            SizedBox(height: 16),
            Text('Local da viagem:'),
            SizedBox(height: 8),
            DropdownButtonHideUnderline(
              child: DropdownButton2(items: [], onChanged: null),
            ),
            SizedBox(height: 16),
            Text('Comentario'),
            SizedBox(height: 8),
            TextFormField(
              maxLines: 4,
              decoration: InputDecoration(border: const OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 2,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Fotos')],
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Selecione'),
                style: ButtonStyle(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
