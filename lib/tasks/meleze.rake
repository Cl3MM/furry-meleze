# encoding: UTF-8

namespace :mlz do


  # Ajoute le champ bid si celui ci n'existe pas
  desc "Update bordereau_id"
  task :update_bid => :environment do
    Ebsdd.skip_callback(:update, :before, :set_status)
    Ebsdd.all.each do | e |
      #puts e.long_bid
      status = e.status
      e.write_attribute(:bid, e.long_bid)
      e.save(validate: false)
    end
    Ebsdd.set_callback(:update, :before, :set_status)
  end

  # Corrige le codeDR si le javascript n'a pas fonctionné
  desc "Set correct Code DR"
  task :update_code_dr => :environment do
    Ebsdd.skip_callback(:update, :before, :set_status)
    codes = {
      200114 => ["R12", "SARPI"],
      200115 => ["R12", "SARPI"],
      160904 => ["R12", "SARPI"],
      200119 => ["R12", "SARPI"],
      160504 => ["R12", "SARPI"],
      200113 => ["R12", "SARPI"],
      200127 => ["D10", "TREDI"],
      150110 => ["D10", "TREDI"],
      160107 => ["R13", "CHIMIREC"]
    }
    bad = []
    Ebsdd.where(status: :complet).each do | e |
      deno = e.dechet_denomination
      if codes.has_key? deno
        unless e.traitement_prevu == codes[deno].first
          puts "Changing: ebsdd: #{e.short_bid} | Ancien CO: #{e.traitement_prevu} | Nouveau: #{codes[deno].first}"
          e.update_attribute(:traitement_prevu, codes[deno].first)
          puts "Nouveau Code DR: #{e.traitement_prevu}"
          bad << e.short_bid
        end
      end

      #e.save(validate: false)
    end
    puts "Total: #{bad.count}"
    Ebsdd.set_callback(:update, :before, :set_status)
  end


  desc "Update Emitted and Collected"
  task :uec => :environment do
    Ebsdd.skip_callback(:update, :before, :set_status)
    c = {}
    e = {}
    Ebsdd.all.each do | ebsdd |
      unless ebsdd[:collectable_id].nil?
        cid = ebsdd.collectable_id
        c[cid] = Producteur.find_by(id: cid) unless c.has_key?(cid)
        ebsdd.collected = c[cid]
      end
      unless ebsdd[:productable_id].nil?
        eid = ebsdd.productable_id
        e[eid] = Producteur.find_by(id: eid) unless c.has_key?(eid)
        ebsdd.emitted = e[eid]
      end
      ebsdd.save(validate: false)
    end
    Ebsdd.set_callback(:update, :before, :set_status)
  end
end
