import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/commune.dart';
import '../../../../core/services/database_service.dart';

class UpdatePdcDialog extends StatefulWidget {
  final Commune commune;

  const UpdatePdcDialog({super.key, required this.commune});

  @override
  State<UpdatePdcDialog> createState() => _UpdatePdcDialogState();
}

class _UpdatePdcDialogState extends State<UpdatePdcDialog> {
  late double _currentProgress;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.commune.tauxAvancementPdc;
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await DatabaseService.instance.updateCommunePdc(widget.commune.id!, _currentProgress);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Mise à jour PDC - ${widget.commune.nom}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Ajustez le taux d\'avancement du Plan de Développement Communal (PDC).',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.paddingL),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Avancement actuel',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${_currentProgress.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          Slider(
            value: _currentProgress,
            min: 0,
            max: 100,
            divisions: 100,
            label: '${_currentProgress.round()}%',
            onChanged: (value) => setState(() => _currentProgress = value),
            activeColor: _getColorForProgress(_currentProgress),
          ),
          const SizedBox(height: AppSizes.paddingL),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Enregistrer'),
        ),
      ],
    );
  }

  Color _getColorForProgress(double progress) {
    if (progress < 30) return Colors.red;
    if (progress < 70) return Colors.orange;
    return Colors.green;
  }
}
