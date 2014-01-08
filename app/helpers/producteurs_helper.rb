module ProducteursHelper
  def date_limite_de_validite
    @producteur.limite_validite.strftime("%d-%m-%Y") unless @producteur.limite_validite.nil?
  end
end
