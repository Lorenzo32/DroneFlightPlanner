import 'package:flutter/material.dart';

class PolygonEditorWidget extends StatefulWidget {
  final List<Map<String, double>> points;
  final Function(Map<String, double>) onPointAdded;
  final Function(int) onPointRemoved;
  final VoidCallback onFinished;

  const PolygonEditorWidget({
    required this.points,
    required this.onPointAdded,
    required this.onPointRemoved,
    required this.onFinished,
    Key? key,
  }) : super(key: key);

  @override
  State<PolygonEditorWidget> createState() => _PolygonEditorWidgetState();
}

class _PolygonEditorWidgetState extends State<PolygonEditorWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pontos do Polígono: ${widget.points.length}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: widget.points.length,
              itemBuilder: (context, index) {
                final point = widget.points[index];
                return ListTile(
                  title: Text(
                    'Ponto ${index + 1}',
                  ),
                  subtitle: Text(
                    'Lat: ${point["lat"]?.toStringAsFixed(6)}, Lng: ${point["lng"]?.toStringAsFixed(6)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => widget.onPointRemoved(index),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Cancelar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
              ElevatedButton.icon(
                onPressed: widget.points.length >= 3
                    ? widget.onFinished
                    : null,
                icon: const Icon(Icons.check),
                label: const Text('Concluir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
