# encoding: utf-8
class DechetNomenclature

  def self.nomenclature
    [
      [200114, "acides", "UN 3264, Déchet, liquide inorganique corrosif acide n.s.a., 8, II ( E )"],
      [200115, "déchets basiques", "UN 3266, Déchet, Liquide inorganique corrosif basique n.s.a., 8, II ( E )"],
      [160904, "substances oxydantes non spécifiées ailleurs", "UN 1479, Déchet, Solide comburant n.s.a., 5.1, II ( E )"],
      [160107, "filtres à huile", "UN 3175, Déchet, Solide contenant du liquide inflammable n.s.a., 4.1, II ( E )"],
      [200119, "pesticides", "UN 2902, Déchet, Pesticide liquide toxique n.s.a., 6.1, II ( E )"],
      [200113, "solvants", "UN 1993, Déchet, liquide inflammable n.s.a., 3, II ( E )"],
      [200127, "peinture, encres, colles et résines contenant des substances dangereuses", "UN 1263, Déchet, Matières apparentées aux peintures, 3, II ( E )"],
      [150110, "emballages contenant des résidus de substances dangereuses ou contaminés par de tels résidus	UN 3175, Déchet, solides contenant du liquide inflammable, 4.1, II ( E )"],
      [160504, "gaz en récipients à pression (y compris les halons) contenant des substances dangereuses", "UN 1950, Déchet, Aérosols, 2, ( E )"]
    ]
  end
  def self.to_select
    DechetNomenclature.nomenclature.map do | line |
      [line.last, line.first]
    end
  end
  def self.[] key
    key = key.to_s
    DechetNomenclature.nomenclature.map{|l| l.first.to_s}.include?(key) ? DechetNomenclature.nomenclature.select { |l| l.last if l.first.to_s == key }.flatten.last : nil
  end
end
