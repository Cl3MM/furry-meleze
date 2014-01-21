# encoding: utf-8
class DechetDenomination # < ActiveRecord::Base

  def self.denomination
    [
      [ 200127,	1, "01-Pâteux et Solides inflammables"],
      [ 150110,	2,	"02-Emballages vides souillés (EVS)"],
      [ 160504,	3,	"03-Aérosols"],
      [ 200113,	4,	"04-Produits liquides (Solvants)"],
      [ 200119,	5,	"05-Phytosanitaires et biocides"],
      [ 160107,	6,	"06-Filtres à huile"],
      [ 200114,	7,	"07-Acides"],
      [ 200115,	8,	"08-Bases"],
      [ 160904,	9,	"09-Comburants"]
    ]
  end
  def self.to_select
    DechetDenomination.denomination.map do | line |
      [line.last, line.first]
    end
  end
  def self.[] key
    key = key.to_s
    DechetDenomination.denomination.map{|l| l.first.to_s}.include?(key) ? DechetDenomination.denomination.select { |l| l.last if l.first.to_s == key }.flatten.last : nil
  end

  def self.num_cap denom
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
