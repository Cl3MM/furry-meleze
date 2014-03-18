module CollecteursHelper
  def date_limite_de_validite
    @company.limite_validite.strftime("%d-%m-%Y") unless @company.limite_validite.nil?
  end
end
