# encoding: UTF-8

namespace :mlz do

  # Mets à jour les poids des peséess
  desc "Update bordereau_poids"
  task :update_poids => :environment do
    ar = []
    Ebsdd.collection.find({ "pesees.0" => { "$exists" => true } }).each { |e| ar << e["bid"] }
    ar.each do |id|
      ebsdd = Ebsdd.find(id)
      ebsdd.set(:bordereau_poids, ebsdd.pesee_totale)
    end
  end


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

  task :create_produits => :environment do
    Produit.delete_all
    DechetDenomination.reborn.each_pair do | k,v |
      is_ecodds = k < 10 ? true : false
      puts "#{v[1]} is ecodds: #{is_ecodds}"
      Produit.create!(code_dr_reception: v[4], code_dr_expedition: v[5], consistance: v[7], is_ecodds: is_ecodds, 
                     nom: v[3], mention: v[8], references: [v[6]], brigitte: v[9], code_rubrique: v[1], seuil_alerte: 300)
    end
  end
  task :update_ebsdds_produits => :environment do
    Ebsdd.skip_before_update_callback
    Ebsdd.all.each do | e |
      next if e.status == :incomplet
      begin
      unless e.super_denomination.blank?
        sd = e.super_denomination.to_i
        p = Produit.find_by(index: sd)
        puts "#{e.super_denomination} == #{p.index}"
        e.produit = p
        e.set_is_ecodds
        e.save!(validate: false)
      else
        dd = e.dechet_denomination.to_i
        dd = dd == 160107 ? dd + 20 : dd
        p = Produit.find_by(code_rubrique: dd)
        puts "#{e.dechet_denomination} == #{p.code_rubrique}"
        e.produit = p
        e.set_is_ecodds
        e.save!(validate: false)
      end
      rescue
        binding.pry
      end
    end
    Ebsdd.set_before_update_callback
  end

  task :create_users => :environment do
    Utilisateur.create(email: "operateur@valespace.com", password: "operateur73", password_confirmation: "operateur73", role: "utilisateur")
    u = Utilisateur.create(email: "administrateur@valespace.com", password: "administrateur/73", password_confirmation: "administrateur/73", role: "administrateur")
    u.set(:role, "administrateur")
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
