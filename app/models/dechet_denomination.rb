# encoding: utf-8
class DechetDenomination # < ActiveRecord::Base

  def self.denomination
    [
      [ 200127,	1, "Pâteux et Solides inflammables"],
      [ 150110,	2, "Emballages vides souillés (EVS)"],
      [ 160504,	3, "Aérosols"],
      [ 200113,	4, "Produits liquides (Solvants)"],
      [ 200119,	5, "Phytosanitaires et biocides"],
      [ 160107,	6, "Filtres à huile"],
      [ 200114,	7, "Acides"],
      [ 200115,	8, "Bases"],
      [ 160904,	9, "Comburants"],

      [ 200114 ,10,'ACIDE FLUORHYDRIQUE' ],
      [ 070104,11,'ANTIGEL' ],
      [ 160601,12,'BATTERIES' ],
      [ 110109 ,13,'BOUES  DE RECTIFICATION' ],
      [ 160501,14,'BOUTEILLE GAZ NON CONSIGNEES' ],
      [ 160501 ,15,'BOUTEILLES DE GAZ CONSIGNEES' ],
      [ 80317,16,'CARTOUCHES D\'ENCRE IMPRIMANTE' ],
      [ 150202 ,17,'CHIFFONS SOUILLES' ],
      [ 20108,18,'CHLORATE DE SOUDE' ],
      [ 20108,19,'CHLORE  liquide' ],
      [ 160904,20,'CHLORE galets' ],
      [ 160904,21,'CHLORURE DE MAGNESIUM' ],
      [ 150110 ,22,'EMBALLAGES SOUILLES' ],
      [ 160501 ,23,'EXTINCTEURS' ],
      [ 130202 ,24,'HUILE HYDRAULIQUE' ],
      [ 070103 ,25,'HUILE SOLUBLE' ],
      [ 130202 ,26,'HUILE MOTEUR USAGEES' ],
      [ 070101 ,27,'LIQUIDE AQUEUX 90%' ],
      [ 070101 ,28,'LIQUIDE DE REFROIDISSEMENT' ],
      [ 80121,29,'LIQUIDES INCINERABLES NON CHLORES' ],
      [ 200131,30,'MEDICAMENTS' ],
      [ 160506 ,31,'PEROXYDES' ],
      [ 200119,32,'PHYTOSANITAIRES' ],
      [ 160600 ,33,'PILES' ],
      [ 160506 ,34,'PRODUITS DE LABORATOIRE' ],
      [ 200117 ,35,'RADIOGRAPHIES' ],
      [ 200114 ,36,'TUBES FLUORESCENTS' ],
      [ 170605,37,'AMIANTE LIE CLASSE II' ],
      [ 150202,38,'EPI SOUILLES AMIANTE CLASSE I' ],
      [ 170601,39,'PRODUITS SOUILLES AMIANTE CLASSE I' ],

    ]
  end


  def self.reborn
    {
      1 => [ 200127,"200127",1,"Pâteux Et Solides Inflammables","R13","R1","TREDI",0,"UN 1263, Déchet, Matières apparentées aux peintures, 3, II ( E )","peinture, encres, colles et résines contenant des substances dangereuses" ],
      2 => [ 150110,"150110",2,"Emballages Vides Souillés (Evs)","R13","R1","TREDI",0,"UN 3175, Déchet, solides contenant du liquide inflammable, 4.1, II ( E )","emballages contenant des résidus de substances dangereuses ou contaminés par de tels résidus" ],
      3 => [ 160504,"160504",3,"Aérosols","R13","R4","SARPI",0,"UN 1950, Déchet, Aérosols, 2, ( E )","gaz en récipients à pression (y compris les halons) contenant des substances dangereuses" ],
      4 => [ 200113,"200113",4,"Produits Liquides (Solvants)","R13","R1","SARPI",1,"UN 1993, Déchet, liquide inflammable n.s.a., 3, II ( E )","solvants" ],
      5 => [ 200119,"200119",5,"Phytosanitaires Et Biocides","D13","D9","SARPI",1,"UN 2902, Déchet, Pesticide liquide toxique n.s.a., 6.1, II ( E )","pesticides" ],
      6 => [ 160127,"160127",6,"Filtres à Huile","R13","R4","CHIMIREC",0,"UN 3175, Déchet, Solide contenant du liquide inflammable n.s.a., 4.1, II ( E )","filtres à huile" ],
      7 => [ 200114,"200114",7,"Acides","D13","D9","SARPI",1,"UN 3264, Déchet, liquide inorganique corrosif acide n.s.a., 8, II ( E )","acides" ],
      8 => [ 200115,"200115",8,"Bases","D13","D9","SARPI",1,"UN 3266, Déchet, Liquide inorganique corrosif basique n.s.a., 8, II ( E )","déchets basiques" ],
      9 => [ 160904,"160904",9,"Comburants","D13","D9","SARPI",0,"UN 1479, Déchet, Solide comburant n.s.a., 5.1, II ( E )","substances oxydantes non spécifiées ailleurs" ],
      10 => [ 200114,"200114",10,"Acide Fluorhydrique","D13","D9","SARPI",1,"UN 1790, Déchet Acide Fluorhydrique, 8 (6.1), II ( E )","" ],
      11 => [ 070104,"070104",11,"Antigel","R13","R1","SARPI",1,"non soumis à l'ADR","" ],
      12 => [ 160601,"160601",12,"Batteries","R13","R4","VMA",0,"non soumis à l'ADR, DS 598","" ],
      13 => [ 110109,"110109",13,"Boues De Rectification","D13","D5","SECHE",0,"non soumis à l'ADR","" ],
      14 => [ 160501,"160501",14,"Bouteille Gaz Non Consignees","R13","R4","SARPI",0,"UN 1965, Déchet Hydrocabures gazeux en mélange liquéfié nsa, 2.1, B/D","" ],
      15 => [ 160501,"160501",15,"Bouteilles De Gaz Consignees","R13","R4","",0,"UN 1965, Déchet Hydrocabures gazeux en mélange liquéfié nsa, 2.1, B/D","" ],
      16 => [ 80317,"080317",16,"Cartouches D'encre Imprimante","R13","R4","SRDI",0,"non soumis à l'ADR","" ],
      17 => [ 150202,"150202",17,"Chiffons Souilles","R13","R1","TREDI",0,"Chiffons huileux non soumis / Labo service UN 3175, solide contenant du liquide inflammable …","" ],
      18 => [ 20108,"020108",18,"Chlorate De Soude","D13","D9","SARPI",0,"UN 1495, Déchet Chlorate de sodium, 5.1, II, ( E )","" ],
      19 => [ 20108,"020108",19,"Chlore Liquide","D13","D9","SARPI",1,"UN 1791, Déchet Hypochlorite en solution, 8, III ( E)","" ],
      20 => [ 160904,"160904",20,"Chlore Galets","D13","D9","SARPI",0,"UN 2468, Déchet Acide Trichloroisocyanurique sec, 5.1, II ( E)","" ],
      21 => [ 160904,"160904",21,"Chlorure De Magnesium","D13","D9","SARPI",0,"UN 1459, Déchet Chlorate et chlorure de magnésium en mélange, solide, 5.1, II ( E)","" ],
      22 => [ 150110,"150110",22,"Emballages Souilles","R13","R1","TREDI",0,"UN 3509 Emballages au rebut, vides non nettoyés (avec résidus de 3,4.1, 6.1, 8, 9), 9, III ( E) Transport autorisé suivant les conditions stipulées à la sectioin 1.5.1 de l'AD","" ],
      23 => [ 160501,"160501",23,"Extincteurs","R13","R4","SITA",0,"non soumis à l'ADR","" ],
      24 => [ 130202,"130202",24,"Huile Hydraulique","R13","R1","CHIMIREC",1,"UN 3082, Déchet, Matière dangereuse du point de vue de l'environnement, liquide, nsa, huile hydraulique, 9, III, ( E)","" ],
      25 => [ 070103,"070103",25,"Huile Soluble","R13","R1","CHIMIREC",1,"UN 3082, Déchet, Matière dangereuse du point de vue de l'environnement, liquide, nsa, huile soluble, 9, III, ( E)","" ],
      26 => [ 130202,"130202",26,"Huile Moteur Usagees","R13","R1","CHIMIREC",1,"UN 3082, Déchet, Matière dangereuse du point de vue de l'environnement, liquide, nsa, huile soluble, 9, III, ( E)","" ],
      27 => [ 070101,"070101",27,"Liquide Aqueux 90%","R13","R1","CHIMIREC",1,"UN 3082, Déchet, Matière dangereuse du point de vue de l'environnement, liquide, nsa, huile soluble, 9, III, ( E)","" ],
      28 => [ 070101,"070101",28,"Liquide De Refroidissement","R13","R1","CHIMIREC",1,"non soumis à l'ADR","" ],
      29 => [ 80121,"080121",29,"Liquides Incinerables Non Chlores","R13","R1","TREDI",1,"UN 1993, Déchet, liquide inflammable n.s.a., 3, II (D/E )","" ],
      30 => [ 200131,"200131",30,"Medicaments","R13","R1","TREDI",0,"non soumis à l'ADR","" ],
      31 => [ 160506,"160506",31,"Peroxydes","D13","D9","SARPI",1,"classement difficile voir 2.2.52 il faut connaitre le type","" ],
      32 => [ 200119,"200119",32,"Phytosanitaires","D13","D9","SARPI",0,"UN 2588, Déchet, Pesticide solide toxique n.s.a., 6.1, II ( D/E )","" ],
      33 => [ 160600,"160600",33,"Piles","R13","R4","SCRELEC",0,"UN 3090, Déchet, Piles au lithium métal, 9, II ( D/E )","" ],
      34 => [ 160506,"160506",34,"Produits De Laboratoire","D13","D9","SARPI",1,"UN 1992,Déchet, Liquide inflammable toxique, nsa, 3 (6.1), II (D/E)","" ],
      35 => [ 200117,"200117",35,"Radiographies","R13","R4","VMA",0,"non soumis à l'ADR","" ],
      36 => [ 200114,"200114",36,"Tubes Fluorescents","R13","R4","RECYLUM",0,"non soumis à l'ADR","" ],
      37 => [ 170605,"170605",37,"Amiante Lie Classe II","D13","D5","BARISIEN",0,"non soumis à l'ADR, DS 168","" ],
      38 => [ 150202,"150202",38,"EPI Souilles Amiante Classe I","D13","D5","SECHE",0,"UN 2590, Déchet Amiante Blanc, 9, III ( E )","" ],
      39 => [ 170601,"170601",39,"Produits Souilles Amiante Classe I","D13","D5","SECHE",0,"UN 2590, Déchet Amiante Blanc, 9, III ( E )","" ],
    }
  end
  def self.to_select_old
    DechetDenomination.denomination.map do | line |
      [line.last, line.first]
    end
  end
  def self.to_select
    DechetDenomination.reborn.reduce([]) do | ary, (k,v) |
      ary << [v[3], v[2]]
      ary
    end
  end
  def self.[] key
    key = key.to_s
    DechetDenomination.denomination.map{|l| l.first.to_s}.include?(key) ? DechetDenomination.denomination.select { |l| l.last if l.first.to_s == key }.flatten.last : nil
  end
  def self.ecodds key
    key = key.to_s
    if DechetDenomination.reborn.has_key?(key)
      x = DechetDenomination.reborn[key]
      "#{"%02d" % x[1]}-#{x[2]}"
    else
      nil
    end
  end
  def self.to_nomenclature
    reborn.values.map { |r| [ r[8], r[2] ] }
  end
  def self.to_data
    reborn.values.map { |r| {id: r[2], label: r[3], cr: r[1], dr11: r[4], dr12: r[5], dest: r[6], c6tnc: r[7], un: r[8] } }
  end
  #def self.ecodds key
  #key = key.to_s
  #if DechetDenomination.denomination.map{|l| l.first.to_s}.include?(key)
  #x = DechetDenomination.denomination.select { |l| l.last if l.first.to_s == key }.flatten
  #"#{"%02d" % x[1]}-#{x.last}"
  #else
  #nil
  #end
  #end
  def self.num_cap denom
    binding.pry
    h = DechetDenomination.denomination.reduce({}) { | h, (a,b,c) | h[a] = b ; h }
    case h[denom]
    when 1
      "PE"
    when 2
      "ES"
    when 3
      "AE"
    when 4
      "SO"
    when 5
      "PH"
    when 6
      "FH"
    when 7
      "AC"
    when 8
      "BA"
    when 9
      "CO"
    end
  end
  #PP : 01=PE, 02= ES, 03= AE, 04=SO, 05=PH, 06=FH, 07=AC, 08=BA, 09=CO
end
