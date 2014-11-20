#!/usr/bin/env ruby
# encoding: utf-8

require 'active_support'
require 'active_support/core_ext'
require 'socket'

module Balance
  class BalanceChecksumError < StandardError
  end
  class PoidsCfg
    attr_accessor :nom, :len, :val, :ar
    def initialize nom, len
      @nom = nom
      @len = len
      @ar = []
      @val = val
    end
    def val
      return 0 if @ar.empty?
      unless ['dsd', 'date', 'heure'].include? @nom
        @val = @ar.map(&:chr).join.to_i / 1000.0
      else
        @val = @ar.map(&:chr).join
      end
    end
    def ar= value
      @ar = value
      @val = val
      value
    end
    #def as_json
      #super(methods: :val)
    #end
    #def to_json
      #super(methods: :val)
    #end
  end
  class Poids
    attr_accessor :brut, :net, :tare, :dsd, :date, :heure
    def initialize
      @brut = PoidsCfg.new 'brut', 5
      @net = PoidsCfg.new 'net', 5
      @tare = PoidsCfg.new 'tare', 5
      @dsd = PoidsCfg.new 'dsd', 6
      @date = PoidsCfg.new 'date', 6
      @heure = PoidsCfg.new 'heure', 6
    end
    def to_date
      "#{@date.ar[0,2]}/#{@date.ar[2,2]}/20#{@date.ar[4,2]}"
    end
    def to_time
      "#{@heure.ar[0,2]}/#{@heure.ar[2,2]}/20#{@heure.ar[4,2]}"
    end
    def from_bytes bytes, brut_or_net = 'b'
      case bytes.size
      when 8
        @brut.ar = @net.ar = bytes[2,5]
      when 9
        if brut_or_net == 'b'
          @brut.ar = bytes[2,6]
        else
          @net.ar = bytes[2,6]
        end
      when 21
        @brut.ar = bytes[2,6]
        @tare.ar = bytes[8,6]
        @net.ar = bytes[14,6]
      when 39
        @brut.ar = bytes[2,6]
        @tare.ar = bytes[8,6]
        @net.ar = bytes[14,6]
        @dsd.ar = bytes[20,6]
        @date.ar = bytes[26,6]
        @heure.ar = bytes[32,6]
      end
    end
  end

  class BalanceCmd
    @@hostname = Settings.balance.host
    @@port = Settings.balance.port
    @@timeout = Settings.balance.timeout

    attr_accessor :cmd, :info, :total, :desc, :response, :bi_dir
    def initialize cmd, total, desc, bi_dir = true
      @cmd = cmd
      @info = total > 0 ? total - 3 : 0
      @total = total
      @desc = desc || "Pas de description"
      @response = nil
      @bi_dir = bi_dir || true
      @serv = nil
    end
    def checksum
      return false if @response.blank?
      information = bytes.slice(2, @info).reduce(:+)
      (127 & (etat + information)) == bytes[-1]
    end
    def bytes
      @response.bytes.to_a
    end
    def etat
      bytes[1]
    end
    def run
      serv.putc @cmd
      if @bi_dir
        @response = serv.read(@total)
        raise BalanceChecksumError, "Somme de contrôle invalide" unless checksum
      end
      serv.close
      self
    end
    def poids
      p = Poids.new
      p.from_bytes bytes.to_a
      p
    end
    def has_response?
      !@response.blank?
    end
    def open
      addr = Socket.getaddrinfo(@@hostname, nil)
      sock = Socket.new(Socket.const_get(addr[0][0]), Socket::SOCK_STREAM, 0)

      begin
        sock.connect_nonblock(Socket.pack_sockaddr_in(@@port, addr[0][3]))
      rescue Errno::EINPROGRESS
        resp = IO.select(nil, [sock], nil, @@timeout.to_i)
        if resp.nil?
          raise Errno::ECONNREFUSED
        end
        begin
          sock.connect_nonblock(Socket.pack_sockaddr_in(@@port, addr[0][3]))
        rescue Errno::EISCONN
        end
      end
      sock
    end
    def serv
      if @serv.nil? || (@serv.respond_to?(:closed?) && @serv.closed?)
        @serv = open
        #@serv = TCPSocket.open(@@hostname, @@port)
        #ready = IO.select([@serv], nil, nil, @@timeout)
        #raise Errno::ETIMEDOUT unless ready
      else
        @serv
      end
      @serv
    end
  end
  class Balance
    attr_accessor :commandes, :serv, :last_cmd
    def initialize
      @serv = nil
      @last_cmd = nil
      @commandes = [
        BalanceCmd.new("P", 8,  "Demande de poids"),
        BalanceCmd.new("B", 9,  "Demande de poids brut"),
        BalanceCmd.new("N", 9,  "Demande de poids net"),
        BalanceCmd.new("A", 21, "Demande des poids bruts tare net"),
        BalanceCmd.new("I", 39, "Demande de pesage"),
        BalanceCmd.new("Z", 0,  "Demande de mise à zéro", false),
        BalanceCmd.new("T", 0,  "Demande de tarage", false),
        BalanceCmd.new("E", 0,  "Demande d'effacement de la tare", false),
      ]
    end
    def cmd cmd
      @commandes.each { |c| @last_cmd = c if c.cmd == cmd }
      @last_cmd
    end
    def pese
      cmd("A").run.poids
    end
    def tare
      cmd("T").run
    end
    def etat
      return "Erreur" unless @last_cmd.has_response?
      case @last_cmd.etat
      when 73
        "Bascule immobile"
      when 32
        "Bascule non immobile"
      when 83
        "Bascule en surcharge"
      when 68
        "Bascule détarée"
      end
    end
  end

  #b = Balance.new
  #b.test
  #b.pese
  #binding.pry
end
