# encoding: UTF-8

namespace :mlz do
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
end
