# encoding: utf-8

require "prawn/measurement_extensions"
require 'prawn/table'

class PeseePdf < Prawn::Document

  BLACK = "000000"
  WHITE = "FFFFFF"
  SUPER_PINK = "FF11FF"

  def initialize(ebsdd)
    @ebsdd = ebsdd
    #path = File.join(Rails.root, "vendor", "assets", "cerfa2.jpg")
    super(page_size: "A4", margin: 20, top_margin: 70, bottom_margin: 50, info: metadata)
    #here = cursor
    #stroke_axis
    #move_down 20
    title
    content
    footer
  end
  def title
    font_size(22) { text "eBsdd ##{@ebsdd.bid} - Justificatif de pesée" }
    self.line_width = 2
    stroke do
      horizontal_line 0, 550
    end
    move_down 20
    text "Producteur : #{@ebsdd.producteur.nom}"
    move_down 5
    text "Type de déchet : #{@ebsdd.produit.nom}"
    move_down 20
  end
  def footer
    repeat(:all) do
      draw_text "Justificatif de pesée - eBsdd #{@ebsdd.bid} - Poids total : #{@ebsdd.poids_pretty}", at: [bounds.left + 3, -4]
    end

    string = "Page <page> / <total>"
    # Green page numbers 1 to 7
    options = { at: [bounds.right - 155, 5],
                width: 150,
                align:  :right,
                :page_filter => (1..7),
                :start_count_at => 0,
                #:color => "007700"
    }
    self.number_pages string, options
  end
  def content
    data = @ebsdd.pesees_to_pdf
    table(data, header: true, position: :center, width: 550, cell_style: { overflow: :shrink_to_fit, min_font_size: 8, size: 11 }) do
      cells.padding = 8
      row(0).border_width = 2
      row(0).font_style = :bold
      row(0).columns(2..4).align = :left
      row(data.count-1).border_width = 2
      row(data.count-1).font_style = :bold
      row(data.count-1).borders = []
      columns(2..4).align = :center
      row(data.count-1).columns(2..4).borders = [:right]
      row(data.count-1).columns(1).align = :right
    end
  end
  def stroke_axis(options={})
    super({:height => (cursor).to_i}.merge(options))
  end
  def metadata
    {
      Title: "Generated eBsdd",
      Author: "Valespace",
      Subject: "Justificatif de pesée eBsdd ##{@ebsdd.bid}",
      Keywords: "ebsdd, meleze, pesee",
      Creator: "Antidots",
      Producer: "Prawn",
      CreationDate: Time.now
    }
  end
end
