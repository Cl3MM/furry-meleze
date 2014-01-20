# encoding: UTF-8

namespace :mlz do
  desc "Update bordereau_id"
  task :update_bid => :environment do
    Ebsdd.skip_callback(:update, :before, :set_status)
    Ebsdd.all.each do | e |
      puts e.long_bid
      #e.write_attribute(:bid, long_bid)
    end
    Ebsdd.set_callback(:update, :before, :set_status)
  end
end
