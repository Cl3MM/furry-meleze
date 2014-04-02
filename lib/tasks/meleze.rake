# encoding: UTF-8

namespace :mlz do


  # Ajoute le champ bid si celui ci n'existe pas
  desc "Update bordereau_id"
  task :archive_all => :environment do
    Ebsdd.skip_before_update_callback
    Ebsdd.all.each do | e |
      status = e.status
      e.write_attribute(:archived, true)
      e.save(validate: false)
    end
    Ebsdd.set_before_update_callback
  end
  desc "archive all"
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


  #desc "Update Emitted and Collected"
  #task :uec => :environment do
    #Ebsdd.skip_callback(:update, :before, :set_status)
    #c = {}
    #e = {}
    #Ebsdd.all.each do | ebsdd |
      #unless ebsdd[:collectable_id].nil?
        #cid = ebsdd.collectable_id
        #c[cid] = Producteur.find_by(id: cid) unless c.has_key?(cid)
        #ebsdd.collected = c[cid]
      #end
      #unless ebsdd[:productable_id].nil?
        #eid = ebsdd.productable_id
        #e[eid] = Producteur.find_by(id: eid) unless c.has_key?(eid)
        #ebsdd.emitted = e[eid]
      #end
      #ebsdd.save(validate: false)
    #end
    #Ebsdd.set_callback(:update, :before, :set_status)
  #end

  #desc "Copy Productable to Producteurs and Collectable to Collecteur"
  #task :cptp => :environment do
    #c,t = 0, 0
    #Prout.delete_all
    #Collecteur.delete_all

    ## on copie le reste des producteurs
    #Producteur.each do | p |
      #pt = Prout.create!(siret: p.siret,
                   #nom: p.nom,
                   #responsable: p.responsable,
                   #adresse: p.adresse,
                   #cp: p.cp,
                   #ville: p.ville,
                   #tel: p.tel,
                   #fax: p.fax,
                   #email: p.email
                  #)
      #t += 1
      #if p.is_collecteur
        #cl = Collecteur.create!(siret: p.siret,
                     #nom: p.nom,
                     #responsable: p.responsable,
                     #adresse: p.adresse,
                     #cp: p.cp,
                     #ville: p.ville,
                     #tel: p.tel,
                     #fax: p.fax,
                     #email: p.email,
                     #recepisse: p.recepisse,
                     #mode_transport: p.mode_transport,
                     #limite_validite: p.limite_validite
                    #)
        #c += 1
      #end
    #end

    #Ebsdd.skip_callback(:update, :before, :set_status, :set_infos_from_emitted, :set_is_ecodds)
    #Ebsdd.each do | e |
      #if e.emitted?
        #p = e.emitted
        #pt = Prout.find_by(nom: p.nom, responsable: p.responsable, adresse: p.adresse, cp: p.cp, siret: p.siret)
        #e.prout = pt if pt
      #end

      #if e.collected?
        #c = e.collected
        #cl = Collecteur.find_by(nom: c.nom, responsable: c.responsable, adresse: c.adresse, cp: c.cp, siret: c.siret)
        #e.collecteur = cl if cl
      #end
      #e.save(validate: false)
    #end

    #Ebsdd.set_callback(:update, :before, :set_status, :set_infos_from_emitted, :set_is_ecodds)

    #puts "Producteurs copiés : #{t}"
    #puts "Collecteurs créés : #{c}"
  #end

  ## Ajoute le champ bid si celui ci n'existe pas
  #desc "Copy back Prout to Producteur"
  #task :prout2prod => :environment do

    #puts "Producteurs: #{Producteur.count}"
    #Producteur.delete_all
    #Ebsdd.skip_callback(:update, :before, :set_status, :set_infos_from_emitted, :set_is_ecodds)
    #Prout.each do | p |
      #pt = Producteur.create!(siret: p.siret,
                   #nom: p.nom,
                   #responsable: p.responsable,
                   #adresse: p.adresse,
                   #cp: p.cp,
                   #ville: p.ville,
                   #tel: p.tel,
                   #fax: p.fax,
                   #email: p.email
                  #)
    #end
    #Ebsdd.each do | e |
      #p = e.prout
      #pdct = Producteur.find_by(nom: p.nom, responsable: p.responsable, adresse: p.adresse, cp: p.cp, siret: p.siret)
      #if pdct
        #e.producteur = pdct
        #e.save(validate: false)
      #end
    #end
    #Ebsdd.set_callback(:update, :before, :set_status, :set_infos_from_emitted, :set_is_ecodds)
  #end

end
