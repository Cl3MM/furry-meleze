require "prawn/measurement_extensions"

class EbsddPdf < Prawn::Document

  BLACK = "000000"
  WHITE = "FFFFFF"
  SUPER_PINK = "FF11FF"

  def initialize(ebsdd, status, bds = nil)
    @ebsdd = ebsdd
    @bds = bds
    @status = status
    path = File.join(Rails.root, "vendor", "assets", "cerfa2.jpg")
    super(page_size: "A4", margin: 0, info: metadata)
    here = cursor
    #stroke_axis
    self.font_size = 9
    if @ebsdd.nil? || @status == :bon_de_sortie
      producteur = Producteur.find_by(nom: /Valespace/i)
      collecteur = Collecteur.find_by(nom: /TRIALP/i)
      destinataire = Destinataire.find_by(nom: /Valespace/i)
      @ebsdd = Ebsdd.new(
        producteur_id: producteur.id,
        destinataire_id: destinataire.id,
        bordereau_poids: @bds.poids,
        collecteur_id: collecteur.id,
        destination_id: @bds.destination.id,
        emetteur_nom: producteur.nom,
        emetteur_siret: producteur.siret,
        emetteur_adresse: producteur.adresse,
        emetteur_tel: producteur.tel,
        bid: @bds.id,
        produit_id: @bds.produit.id,
        bordereau_date_transport: @bds.created_at,
        code_operation: @bds.codedr_cadre12,
        traitement_prevu: CodeDr[@bds.codedr_cadre12]
      )
      @ebsdd.status = :bidon
      path = File.join(Rails.root, "vendor", "assets", "cerfa2.jpg")
      image path, at: [0, here], width: 210.mm
      erase_all
      checkboxes
      page_num
      cadre0
      cadre1
      cadre2
      cadre3
      cadre4
      cadre5
      cadre6
      cadre8
      cadre9
      cadre10
      cadre11
      cadre12

      @bds.ebsdds.each_slice(5) do | annexe |
        annexe_en_tete
        annexe.each_with_index do | ebsdd, i |
          annexe_line_item ebsdd, i
        end
      end

    elsif @ebsdd.status == :nouveau || @status == :first_part
      image path, at: [0, here], width: 210.mm
      erase_all
      checkboxes
      page_num
      cadre0
      cadre1
      cadre2
      cadre3
      cadre4
      cadre6
      cadre8
      cadre9
      cadre10
      cadre11
      cadre12
    elsif @ebsdd.status == :en_attente || @status == :second_part
      cadre5
      #cadre10 poids
      my_text_box @ebsdd.poids_en_tonnes_pdf, [145, 181], width: 35, height: 20, align: :right
      cadre6
    else
      image path, at: [0, here], width: 210.mm
      erase_all
      checkboxes
      page_num
      cadre0
      cadre1
      cadre2
      cadre3
      cadre4
      cadre5
      cadre6
      cadre8
      cadre9
      cadre10
      cadre11
      cadre12
    end
    #cadre0
    #cadre1
    #cadre2
    #cadre3
    #cadre4
    #cadre5 unless @ebsdd.status == :nouveau
    #cadre6
    #cadre8
    #cadre9
    #cadre10 unless @ebsdd.status == :nouveau
    #cadre11
    #cadre12
  end

  def annexe_line_item ebsdd, position
    height = position * 104.5
    ###### Table 1
    # effacage
    erase 100, 595 - height, width: 150 #siret
    erase 370, 595 - height, width: 100, height: 22 #rubrique déchet
    erase 360, 530 - height, width: 50, height: 20 #Date de remise
    # Expediteur initial (num_cap)
    my_text_box ebsdd.num_cap, [150, 609 - height], width: 100, height: 15
    # Bordereau original
    my_text_box ebsdd.bordereau_id, [400, 609 - height], width: 150, height: 15

    prod = ebsdd.producteur
    # siret
    my_text_box prod.siret.try(:gsub, /-/, ""), [106, 596 - height], width: 150, height: 15
    # Nom
    my_text_box prod.nom, [85, 584 - height], width: 150, height: 15
    # Adresse
    my_text_box "#{prod.try(:adresse)}\n#{prod.try(:cp)} #{prod.try(:ville)}", [95, 570 - height], width: 150, height: 15

    # tel
    my_text_box prod.try(:tel), [78, 550 - height], width: 50, height: 15
    # fax
    my_text_box prod.try(:fax), [185, 550 - height], width: 50, height: 15
    # email
    my_text_box prod.try(:email), [78, 538 - height], width: 150, height: 15
    # Contact
    my_text_box prod.try(:responsable), [55, 517 - height], width: 230, height: 15

    # Rubrique dechet
    my_text_box "#{ebsdd.produit.code_rubrique.to_s.gsub(/(.{2})(?=.)/, '\1 \2')} *", [360, 584 - height], width: 80, height: 15
    # Denomination Usuelle
    my_text_box ebsdd.produit.nom, [283, 563 - height], width: 200, height: 15
    # Poids
    my_text_box ebsdd.poids_en_tonnes_pdf, [422, 550 - height], width: 40, height: 15, align: :center
    # Quantité réelle
    checkbox 323.7, 550 - height

    # Date de remise
    my_text_box ebsdd.bordereau_date_transport.strftime("%d/%m/%y"), [360, 527 - height], width: 50, height: 15, align: :center

  end

  def annexe_en_tete
    start_new_page
    path = File.join(Rails.root, "vendor", "assets", "cerfa-annexe2.jpg")
    image path, at: [0, cursor], width: 210.mm
    #stroke_axis at: [50, 30], :step_length => 20, :color => 'FF00'

    # bordereau de rattachement
    my_text_box @bds.id, [240, 691], width: 250, height: 15
    erase 100, 665, width: 150
    dest = @bds.ebsdds.first.destinataire
    # bds siret
    my_text_box dest.siret.gsub(/-/, ""), [106, 667], width: 150, height: 15
    # Nom
    my_text_box dest.nom, [85, 655], width: 150, height: 15
    # Adresse
    my_text_box "#{dest.adresse}\n#{dest.cp} #{dest.ville}", [95, 641], width: 150, height: 15
    # Contact
    my_text_box dest.responsable, [375, 667], width: 120, height: 15
    # tel
    my_text_box dest.tel, [310, 655], width: 50, height: 15
    # Fax
    my_text_box dest.fax, [400, 655], width: 50, height: 15
    # Email
    my_text_box dest.email, [310, 643], width: 150, height: 15
  end

  def log text
    my_text_box text, [200, 746.5], width: 150, height: 10
  end
  def page_num
    fs = self.font_size
    self.font_size = 10
    my_text_box "1", [530, 783.3], width: 10, height: 15
    my_text_box "1", [542, 783.3], width: 10, height: 15
    self.font_size = fs
  end
  def cadre12
    erase 85, 63, width: 160
    my_text_box @ebsdd.traitement_prevu, [155, 73], width: 350, height: 12
    my_text_box @ebsdd.destination.siret.gsub(/-/, ""), [90, 61], width: 200, height: 10
    my_text_box @ebsdd.destination.nom, [75, 50.5], width: 200, height: 10
    my_text_box "#{@ebsdd.destination.adresse}, #{@ebsdd.destination.cp} #{@ebsdd.destination.ville}", [80, 40], width: 200, height: 10
    my_text_box @ebsdd.destination.responsable, [380, 63], width: 200, height: 10
    my_text_box @ebsdd.destination.tel, [325, 52], width: 200, height: 10
    my_text_box @ebsdd.destination.fax, [445, 52], width: 200, height: 10
    my_text_box @ebsdd.destination.email, [325, 41], width: 200, height: 10
  end
  def cadre11
    my_text_box @ebsdd.code_operation, [342, 228], width: 150, height: 20, valign: :top
    my_text_box CodeDr[@ebsdd.code_operation], [296, 198], width: 230, height: 22, valign: :top
  end
  def cadre10
    erase 85, 227, width: 160
    my_text_box @ebsdd.destinataire.try(:siret).try(:gsub, /-/, ""), [90, 227], width: 200, height: 10
    my_text_box @ebsdd.destinataire.nom, [90, 217], width: 200, height: 10
    my_text_box "#{@ebsdd.destinataire.adresse}\n#{@ebsdd.destinataire.cp} #{@ebsdd.destinataire.ville}", [90, 207], width: 200, height: 20
    my_text_box @ebsdd.destinataire.responsable, [125, 191.5], width: 150, height: 20
    my_text_box @ebsdd.destinataire.responsable, [125, 191.5], width: 150, height: 20
    erase 128, 168, width: 50
    unless @ebsdd.bordereau_poids.nil?
      my_text_box @ebsdd.poids_en_tonnes_pdf, [145, 181], width: 35, height: 20, align: :right
    end
    erase 80, 106.5, width: 50
    my_text_box @ebsdd.bordereau_date_transport.strftime("%d/%m/%Y"), [125, 171], width: 50, height: 20
    my_text_box @ebsdd.bordereau_date_transport.strftime("%d/%m/%Y"), [80, 108], width: 50, height: 20
    #my_text_box @ebsdd.bordereau_date_reception.strftime("%d/%m/%Y"), [125, 171], width: 50, height: 20
    # Cadre 10 Lot accepté
    checkbox 114.5, 155.5
  end
  def cadre9
    erase 225, 265, width: 50
    my_text_box @ebsdd.emetteur_nom || "", [73, 261], width: 100, height: 10
    my_text_box @ebsdd.bordereau_date_transport.strftime("%d/%m/%Y"), [220, 261], width: 200, height: 10
  end
  def cadre8
    my_text_box @ebsdd.collecteur.siret.gsub(/-/, ""), [89, 375.5], width: 200, height: 10
    my_text_box @ebsdd.collecteur.nom, [89, 365], width: 200, height: 10
    my_text_box "#{@ebsdd.collecteur.adresse}\n#{@ebsdd.collecteur.cp} #{@ebsdd.collecteur.ville}", [89, 355], width: 200, height: 20
    my_text_box @ebsdd.collecteur.tel, [68, 334], width: 50, height: 10
    my_text_box @ebsdd.collecteur.fax, [180, 334], width: 50, height: 10
    my_text_box @ebsdd.collecteur.email, [68, 325], width: 200, height: 12
    my_text_box @ebsdd.collecteur.responsable, [127, 314], width: 200, height: 12
    my_text_box @ebsdd.collecteur.recepisse, [356, 387.5], width: 50, height: 12
    my_text_box @ebsdd.collecteur.cp[0..1], [486, 387.5], width: 50, height: 12
    my_text_box @ebsdd.collecteur.limite_validite.strftime("%d/%m/%Y"), [367, 377.5], width: 50, height: 12
    mt = case @ebsdd.collecteur.mode_transport
         when 1
           "ROUTE"
         when 2
           "AERIEN"
         when 3
           "FERROVIAIRE"
         when 4
           "FLUVIAL"
         when 5
           "MARITIME"
         end
    my_text_box mt, [372, 367.5], width: 50, height: 12
    erase 394, 357, width: 50
    my_text_box @ebsdd.bordereau_date_transport.strftime("%d/%m/%Y"), [394.5, 357.5], width: 50, height: 12
  end
  def cadre6
    #if(@ebsdd.new_record?)
    ## Estimée
    #checkbox 168.5, 472
    #else
    ## Réelle
    checkbox 111, 471.5
    #end
    my_text_box @ebsdd.poids_en_tonnes_pdf.to_s, [212.5, 472], width: 31, height: 10, align: :right unless @ebsdd.status == :nouveau
  end
  def cadre5
    # Cadre 5 : Conditionnement
    checkbox 322, 494
    my_text_box @ebsdd.dechet_nombre_colis.to_s, [510, 494], width: 30, height: 10
  end
  def cadre4
    #my_text_box DechetNomenclature[@ebsdd.dechet_denomination].upcase, [45, 515], width: 430, height: 20
    my_text_box @ebsdd.produit.mention.titleize, [45, 515], width: 430, height: 20
  end
  def cadre0
    my_text_box @ebsdd.bordereau_id.to_s, [118, 745.5], width: 150, height: 10
  end
  def cadre3
    # dénomination du déchet, on insère un espace tous les 2 caractères
    my_text_box "#{@ebsdd.produit.code_rubrique.to_s.gsub(/(.{2})(?=.)/, '\1 \2')} *", [175, 557], width: 150
    # Cadre 3 consistance
    case @ebsdd.produit.consistance
    when 0
      # Solide
      checkbox 366, 559
    when 1
      # Liquide
      checkbox 420, 559
    when 2
      # Gazeux
      checkbox 479.3, 559
    end
    # Dénomination usuelle
    #my_text_box DechetDenomination[@ebsdd.dechet_denomination].upcase, [175, 536], width: 300, height: 10
    my_text_box @ebsdd.produit.nom.titleize, [175, 536], width: 300, height: 10
  end
  def cadre1
    # siret
    draw_text @ebsdd.producteur.siret, at: [88, 632]
    # nom
    my_text_box @ebsdd.producteur.nom, [72, 630.5]
    # adresse
    my_text_box "#{@ebsdd.producteur.adresse}\n#{@ebsdd.producteur.cp} #{@ebsdd.producteur.ville}", [80, 620], height: 22
    # tel
    my_text_box @ebsdd.producteur.tel, [68, 599.5], width: 90
    # fax
    my_text_box @ebsdd.producteur.fax, [190, 599.5], width: 90
    # email
    my_text_box @ebsdd.producteur.email, [74, 588]
    # responsable
    my_text_box @ebsdd.producteur.responsable, [125, 579], width: 145
  end

  def cadre2
    # siret
    my_text_box @ebsdd.destinataire.siret, [345, 672], width: 183
    #draw_text "399 619 147 00040", at: [345, 663.5]
    # nom
    my_text_box @ebsdd.destinataire.nom, [345, 661], width: 183
    # adresse
    my_text_box "#{@ebsdd.destinataire.adresse}\n#{@ebsdd.destinataire.cp} #{@ebsdd.destinataire.ville}", [345, 648.5], height: 19
    # tel
    draw_text @ebsdd.destinataire.tel, at: [345, 622]
    # fax
    draw_text @ebsdd.destinataire.fax, at: [450, 622]
    # email
    draw_text @ebsdd.destinataire.email, at: [345, 612]
    # responsable
    draw_text @ebsdd.destinataire.responsable, at: [380, 601]
    draw_text @ebsdd.num_cap, at: [410, 581]
    draw_text "R13", at: [510, 570.5]
  end
  def my_text_box text, at, options = {}
    options.merge!({ width: 200, height: 12, overflow: :shrink_to_fit, valign: :center, align: :left, color: BLACK }) { |key, v1, v2| v1 }
    text = "" if text.nil?
    text_box text, at: at, height: options[:height], width: options[:width], overflow: options[:overflow], valign: options[:valign], align: options[:align], color: options[:color]
  end
  def erase_all
    [[85, 642, 140], [340, 672, 140], [170, 558.5, 100], [88, 376, 100]].each do | e |
      erase e[0], e[1], width: e[2]
    end
    ## cadre 1 : Siret
    #erase 85, 642, width: 140
    ## cadre 2 : Siret
    #erase 340, 672, width: 140
  end
  # Erase default content
  def erase i,j, options = {}
    options.merge!({ width: 50, height: 12, color: WHITE }) { |key, v1, v2| v1 }
    original_color = self.fill_color
    self.fill_color = options[:color]
    rectangle [i, j], options[:width], options[:height]
    fill
    self.fill_color = original_color
  end
  # Document Metadata
  #
  def metadata
    {
      Title: "Generated eBsdd",
      Author: "Valespace",
      Subject: "eBsdd",
      Keywords: "ebsdd, meleze",
      Creator: "Antidots",
      Producer: "Prawn",
      CreationDate: Time.now
    }
  end

  def checkboxes
    # Check box Cadre 1
    checkbox 51.3, 725.5
    # Check box Cadre 2
    checkbox 303.1, 692.2

    ## Cadre 3 consistance
    ## Solide
    #checkbox 366, 559
    ## Liquide
    #checkbox 420, 559
    ## Gazeux
    #checkbox 479.3, 559

    # Cadre 5 : Conditionnement
    #checkbox 322, 494

    ## Cadre 6 : Quantité
    ## Réelle
    #checkbox 111, 471.5
    ## Estimée
    #checkbox 168.5, 472

  end

  # Draw a cross
  def checkmark i, j, options = {}
    draw_text "i: #{i}, j: #{j}", at: [i,j]
    options.merge!({ width: 10, line: 5 }) { |key, v1, v2| v1 }
    old_line_width = self.line_width
    self.line_width = options[:line]
    line [i, j], [i+options[:width], j+options[:width]]
    line [i+options[:width], j], [i, j+options[:width]]
    stroke
    self.line_width = old_line_width
  end

  def checkbox i, j, options = {}
    options.merge!({ width: 10, line: 3 }) { |key, v1, v2| v1 }
    rectangle [i, j], options[:width], options[:width]
    fill
  end

  # Draws X and Y axis rulers beginning at the margin box origin. Used on
  # examples.
  #
  def stroke_axis(options={})
    super({:height => (cursor).to_i}.merge(options))
  end

  # Reset some of the Prawn settings including graphics and text to their
  # defaults.
  #
  # Used after rendering examples so that each new example starts with a clean
  # slate.
  #
  def reset_settings

    # Text settings
    font("Helvetica", :size => 12)
    default_leading 0
    self.text_direction = :ltr

    # Graphics settings
    self.line_width = 1
    self.cap_style  = :butt
    self.join_style = :miter
    undash
    fill_color   BLACK
    stroke_color BLACK
  end
end
