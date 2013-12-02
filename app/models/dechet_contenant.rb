# encoding: utf-8
class DechetContenant

  def self.contenant
    [
      ["CA0609", "Caisse", "60 - 90 L	1"],
      ["OT1222", "Fût OT", "120 - 220 L	2"],
      ["AD6090", "Bac ADR", "600 - 900 L	3"],
      ["AD1000", "Bac ADR", "> 1000 L	4"],
      ["BA6090", "Bac", "600 - 900 L	5"],
      ["BA1000", "Bac", "> 1000 L	6"]
    ]
  end
  def self.to_select
    DechetContenant.contenant.map do | line |
      ["#{line[1]} #{line.last}", line.first]
    end
  end
  def self.[] key
    key = key.to_s
    DechetContenant.contenant.map{|l| l.first.to_s}.include?(key) ? DechetContenant.contenant.select { |l| l.last if l.first.to_s == key }.flatten.last : nil
  end
end
