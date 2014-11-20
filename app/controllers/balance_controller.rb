# encoding: utf-8

class BalanceController < ApplicationController
  before_filter :authenticate_utilisateur!

  def save
    ebsdd = Ebsdd.find(params[:id])
    pesees = []
    if (params[:pesees].present?) && (params[:pesees].is_a? Hash)
      params[:pesees].values.each do | p |
        pesee = Pesee.new(p.symbolize_keys)
        unless ebsdd.pesees.find_by(dsd: pesee.dsd)
          pesees << pesee
          ebsdd.pesees << pesee
        end
      end
    end
    render json: pesees, status: :ok
  end
  def dsd
    begin
      return render json: Balance::Balance.new.cmd("I").run.poids.to_json
    rescue Errno::EHOSTUNREACH, Errno::ETIMEDOUT => bang
      err << "Connexion à la balance impossible"
    rescue Errno::ECONNREFUSED => bang
      err << "Connexion à la balance refusée"
    rescue Balance::BalanceChecksumError => bang
      err << bang
    end
    Rails.logger.debug err.join
    return render json: { error: err.join("<br/>") }, status: 500
  end
  def pese
    err = []
    begin
      return render json: Balance::Balance.new.cmd("A").run.poids.to_json
    rescue Errno::EHOSTUNREACH, Errno::ETIMEDOUT => bang
      err << "Connexion à la balance impossible"
    rescue Errno::ECONNREFUSED => bang
      err << "Connexion à la balance refusée"
    rescue Balance::BalanceChecksumError => bang
      err << bang
    end
    Rails.logger.debug err.join
    return render json: { error: err.join("<br/>") }, status: 500
  end
  def cmd
    return render(json: { error: "Veuillez spécifier une commande"}, status: 403) \
      unless (params[:cmd].present? and %W(T Z E).include? params[:cmd].upcase)
    begin
      Balance::Balance.new.cmd(params[:cmd].upcase).run
    rescue Errno::EHOSTUNREACH, Errno::ETIMEDOUT
      return render json: { error: "Connexion à la balance impossible"}, status: 500
    rescue Errno::ECONNREFUSED
      return render json: { error: "Connexion à la balance refusée"}, status: 500
    end
    render json: [], status: :ok
  end
end
