/// Modèle pour une dépense ou un décaissement
class Depense {
  final int? id;
  final int projetId;
  final int budgetLigneId;
  final int? activiteId;
  final String typeOperation;
  final String numeroPiece;
  final DateTime dateOperation;
  final double montant;
  final String devise;
  final String? fournisseurPrestataire;
  final String? description;
  final ModePaiement modePaiement;
  final String? numeroFactureRecu;
  final StatutValidationDepense statutValidation;
  final int? demandeParId;
  final int? approuveTechniqueParId;
  final int? approuveFinancierParId;
  final int? payeParId;
  final DateTime? datePaiement;
  final DateTime createdAt;

  const Depense({
    this.id,
    required this.projetId,
    required this.budgetLigneId,
    this.activiteId,
    required this.typeOperation,
    required this.numeroPiece,
    required this.dateOperation,
    required this.montant,
    this.devise = 'FCFA',
    this.fournisseurPrestataire,
    this.description,
    this.modePaiement = ModePaiement.especes,
    this.numeroFactureRecu,
    this.statutValidation = StatutValidationDepense.enAttente,
    this.demandeParId,
    this.approuveTechniqueParId,
    this.approuveFinancierParId,
    this.payeParId,
    this.datePaiement,
    required this.createdAt,
  });

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'projet_id': projetId,
      'budget_ligne_id': budgetLigneId,
      'activite_id': activiteId,
      'type_operation': typeOperation,
      'numero_piece': numeroPiece,
      'date_operation': dateOperation.toIso8601String(),
      'montant': montant,
      'devise': devise,
      'fournisseur_prestataire': fournisseurPrestataire,
      'description': description,
      'mode_paiement': modePaiement.name,
      'numero_facture_recu': numeroFactureRecu,
      'statut_validation': statutValidation.name,
      'demande_par_id': demandeParId,
      'approuve_technique_par_id': approuveTechniqueParId,
      'approuve_financier_par_id': approuveFinancierParId,
      'paye_par_id': payeParId,
      'date_paiement': datePaiement?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Créer depuis Map de la base de données
  factory Depense.fromMap(Map<String, dynamic> map) {
    return Depense(
      id: map['id'] as int?,
      projetId: map['projet_id'] as int,
      budgetLigneId: map['budget_ligne_id'] as int,
      activiteId: map['activite_id'] as int?,
      typeOperation: map['type_operation'] as String,
      numeroPiece: map['numero_piece'] as String,
      dateOperation: DateTime.parse(map['date_operation'] as String),
      montant: (map['montant'] as num).toDouble(),
      devise: map['devise'] as String? ?? 'FCFA',
      fournisseurPrestataire: map['fournisseur_prestataire'] as String?,
      description: map['description'] as String?,
      modePaiement: ModePaiement.values.firstWhere(
        (e) => e.name == map['mode_paiement'],
        orElse: () => ModePaiement.especes,
      ),
      numeroFactureRecu: map['numero_facture_recu'] as String?,
      statutValidation: StatutValidationDepense.values.firstWhere(
        (e) => e.name == map['statut_validation'],
        orElse: () => StatutValidationDepense.enAttente,
      ),
      demandeParId: map['demande_par_id'] as int?,
      approuveTechniqueParId: map['approuve_technique_par_id'] as int?,
      approuveFinancierParId: map['approuve_financier_par_id'] as int?,
      payeParId: map['paye_par_id'] as int?,
      datePaiement: map['date_paiement'] != null
          ? DateTime.parse(map['date_paiement'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Créer une copie avec modifications
  Depense copyWith({
    int? id,
    int? projetId,
    int? budgetLigneId,
    int? activiteId,
    String? typeOperation,
    String? numeroPiece,
    DateTime? dateOperation,
    double? montant,
    String? devise,
    String? fournisseurPrestataire,
    String? description,
    ModePaiement? modePaiement,
    String? numeroFactureRecu,
    StatutValidationDepense? statutValidation,
    int? demandeParId,
    int? approuveTechniqueParId,
    int? approuveFinancierParId,
    int? payeParId,
    DateTime? datePaiement,
    DateTime? createdAt,
  }) {
    return Depense(
      id: id ?? this.id,
      projetId: projetId ?? this.projetId,
      budgetLigneId: budgetLigneId ?? this.budgetLigneId,
      activiteId: activiteId ?? this.activiteId,
      typeOperation: typeOperation ?? this.typeOperation,
      numeroPiece: numeroPiece ?? this.numeroPiece,
      dateOperation: dateOperation ?? this.dateOperation,
      montant: montant ?? this.montant,
      devise: devise ?? this.devise,
      fournisseurPrestataire:
          fournisseurPrestataire ?? this.fournisseurPrestataire,
      description: description ?? this.description,
      modePaiement: modePaiement ?? this.modePaiement,
      numeroFactureRecu: numeroFactureRecu ?? this.numeroFactureRecu,
      statutValidation: statutValidation ?? this.statutValidation,
      demandeParId: demandeParId ?? this.demandeParId,
      approuveTechniqueParId:
          approuveTechniqueParId ?? this.approuveTechniqueParId,
      approuveFinancierParId:
          approuveFinancierParId ?? this.approuveFinancierParId,
      payeParId: payeParId ?? this.payeParId,
      datePaiement: datePaiement ?? this.datePaiement,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Modes de paiement disponibles
enum ModePaiement {
  especes,
  virement,
  cheque,
  mobileMoney;

  String get label {
    switch (this) {
      case ModePaiement.especes:
        return 'Espèces';
      case ModePaiement.virement:
        return 'Virement';
      case ModePaiement.cheque:
        return 'Chèque';
      case ModePaiement.mobileMoney:
        return 'Mobile Money';
    }
  }
}

/// Statuts de validation d'une dépense
enum StatutValidationDepense {
  enAttente,
  approuveTechnique,
  approuveFinancier,
  rejete,
  paye;

  String get label {
    switch (this) {
      case StatutValidationDepense.enAttente:
        return 'En attente';
      case StatutValidationDepense.approuveTechnique:
        return 'Approuvé Technique';
      case StatutValidationDepense.approuveFinancier:
        return 'Approuvé Financier';
      case StatutValidationDepense.rejete:
        return 'Rejeté';
      case StatutValidationDepense.paye:
        return 'Payé';
    }
  }
}
