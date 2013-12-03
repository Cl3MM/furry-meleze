# encoding: utf-8
class CodeDr

  def self.codes
    [
      ["D1", "Dépôt sur ou dans le sol (par exemple, mise en décharge, etc.)"],
      ["D2", "Traitement en milieu terrestre (par exemple, biodégradation de déchets liquides ou de boues dans les sols, etc.)"],
      ["D3", "Injection en profondeur (par exemple, injection des déchets pompables dans des puits, des dômes de sel ou des failles géologiques naturelles, etc.)"],
      ["D4", "Lagunage (par exemple, déversement de déchets liquides ou de boues dans des puits, des étangs ou des bassins, etc.)"],
      ["D5", "Mise en décharge spécialement aménagée (par exemple, placement dans des alvéoles étanches séparées, recouvertes et isolées les unes et les autres et de l'environnement etc.)"],
      ["D6", "Rejet dans le milieu aquatique sauf l'immersion"],
      ["D7", "Immersion, y compris enfouissement dans le sous-sol marin"],
      ["D8", "Traitement biologique non spécifié ailleurs dans la présente annexe, aboutissant à des composés ou à des mélanges qui sont éliminés selon l'un des procédés numérotés D 1 à D 12"],
      ["D9", "Traitement physico-chimique non spécifié ailleurs dans la présente annexe, aboutissant à des composés ou à des mélanges qui sont éliminés selon l'un des procédés numérotés D 1 à D 12 (par exemple, évaporation, séchage, calcination, etc.)"],
      ["D10", "Incinération à terre"],
      ["D11", "Incinération en mer"],
      ["D12", "Stockage permanent (par exemple, placement de conteneurs dans une mine, etc.)"],
      ["D13", "Regroupement préalablement à l'une des opérations numérotées D 1 à D 12"],
      ["D14", "Reconditionnement préalablement à l'une des opérations numérotées D 1 à D 13"],
      ["D15", "Stockage préalablement à l'une des opérations numérotées D 1 à D 14 (à l'exclusion du stockage temporaire, avant collecte, sur le site de production)."],
      ["R1", "Utilisation principale comme combustible ou autre moyen de produire de l'énergie"],
      ["R2", "Récupération ou régénération des solvants"],
      ["R3", "Recyclage ou récupération des substances organiques qui ne sont pas utilisées comme solvants (y compris les opérations de compostage et autres transformations biologiques)"],
      ["R4", "Recyclage ou récupération des métaux et des composés métalliques"],
      ["R5", "Recyclage ou récupération d'autres matières inorganiques"],
      ["R6", "Régénération des acides ou des bases"],
      ["R7", "Récupération des produits servant à capter les polluants"],
      ["R8", "Récupération des produits provenant des catalyseurs"],
      ["R9", "Régénération ou autres réemplois des huiles"],
      ["R10", "Epandage sur le sol au profit de l'agriculture ou de l'écologie"],
      ["R11", "Utilisation de déchets résiduels obtenus à partir de l'une des opérations numérotées R1 à R10"],
      ["R12", "Echange de déchets en vue de les soumettre à l'une des opérations numérotées R 1 à R 11"],
      ["R13", "Stockage de déchets préalablement à l'une des opérations numérotées R 1 à R 12 (à l'exclusion du stockage temporaire, avant collecte, sur le site de production)"],
    ]
  end
  def self.to_select
    CodeDr.codes.map do | line |
      ["#{line.first} / #{line.last}", line.first]
    end
  end
  def self.[] key
    key = key.to_s
    CodeDr.codes.map{|l| l.first.to_s}.include?(key) ? CodeDr.codes.select { |l| l.last if l.first.to_s == key }.flatten.last : nil
  end
end

