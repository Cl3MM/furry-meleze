# encoding: utf-8
class DechetContenant

  def self.contenant
    [
      ["CA0609", "Caisse", "60 - 90 L"],
      ["OT1222", "Fût OT", "120 - 220 L"],
      ["AD6090", "Bac ADR", "600 - 900 L"],
      ["AD1000", "Bac ADR", "> 1000 L"],
      ["BA6090", "Bac", "600 - 900 L"],
      ["BA1000", "Bac", "> 1000 L"],
      ["xxxxxx", "Autre", "..."]
    ]
  end
  def self.to_select
    DechetContenant.contenant.map do | line |
      ["#{line[1]} #{line.last}", line.first]
    end
  end
  def self.[] key
    key = key.to_s
    DechetContenant.contenant.map{|l| l.first.to_s}.include?(key) ? DechetContenant.contenant.select { |l| "#{l[1]} #{l.last}" if l.first.to_s == key }.flatten.last : nil
  end
  def self.display(key)
    key = key.to_s
    DechetContenant.contenant.map{|l| l.first.to_s}.include?(key) ? DechetContenant.contenant.select { |l| l if l.first.to_s == key }.flatten.last(2).join(" ") : nil
  end
end
