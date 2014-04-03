#!/usr/bin/env ruby

require 'ftools'

addremove = case ARGV[0]
when 'add' then 1
when 'remove' then -1
else abort("add or remove argument required")
end 

old_state = "/tmp/service_old"
new_state = "/tmp/service_new"
state_diff = "/tmp/service_diff"

while true
  services = `chkconfig`.to_a
  if File.exists?(old_state)
    old = File.open(old_state,"r").to_a
    unless old == services
      File.open(new_state,"w") do |n|
        services.each {|s| n.puts s}
      end
      # now diff
      diff = case addremove
             when 1 then services - old
             when -1 then old - services
             end
      #diff = `diff #{new_state} #{old_state} | grep ">" | cut -d" " -f2`
      diff.each {|d| d.gsub!(/\s.+/, '')}
      puts "-------------------------------------"
      if addremove == -1
        puts "service(s) removed..."
      elsif addremove == 1
        puts "service(s) added..."
      end  
      puts "#####################################"
      puts diff
      puts "#####################################"
      unless diff.empty?
        File.open(state_diff,"a") do |m|
          m.puts(Time.now)
          m.puts(diff)
        end
      end
      File.copy(new_state, old_state)
    end
  else
    puts "-------------------------------------"
    puts "writing initial chkconfig..."
    File.open(old_state,"w") do |f|
      services.each {|s| f.puts s}
    end
  end
  sleep(10)
end
