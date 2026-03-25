
class AppConfig {
  final int? id;
  final String republique; // e.g. "RÉPUBLIQUE TOGOLAISE"
  final String ministere;   // e.g. "MDDL"
  final String entite;      // e.g. "CPDSE-CT"
  final String direction;   // e.g. "Cellule de Programmation, de Développement..."
  final String sigle;       // e.g. "CPDSE-CT / MDDL"
  final String? logoPath;   // Local path to the logo image

  AppConfig({
    this.id,
    this.republique = 'RÉPUBLIQUE TOGOLAISE',
    this.ministere = 'MDDL',
    this.entite = 'CPDSE-CT',
    this.direction = 'Cellule de Programmation, de Développement et de Suivi Evaluation des Communes et Territoires',
    this.sigle = 'CPDSE-CT / MDDL',
    this.logoPath,
  });

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    return AppConfig(
      id: map['id'] as int?,
      republique: map['republique'] ?? 'RÉPUBLIQUE TOGOLAISE',
      ministere: map['ministere'] ?? 'MDDL',
      entite: map['entite'] ?? 'CPDSE-CT',
      direction: map['direction'] ?? '',
      sigle: map['sigle'] ?? '',
      logoPath: map['logo_path'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'republique': republique,
      'ministere': ministere,
      'entite': entite,
      'direction': direction,
      'sigle': sigle,
      'logo_path': logoPath,
    };
  }

  AppConfig copyWith({
    int? id,
    String? republique,
    String? ministere,
    String? entite,
    String? direction,
    String? sigle,
    String? logoPath,
  }) {
    return AppConfig(
      id: id ?? this.id,
      republique: republique ?? this.republique,
      ministere: ministere ?? this.ministere,
      entite: entite ?? this.entite,
      direction: direction ?? this.direction,
      sigle: sigle ?? this.sigle,
      logoPath: logoPath ?? this.logoPath,
    );
  }
}
