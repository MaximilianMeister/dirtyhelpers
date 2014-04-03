#!/usr/bin/env ruby

require 'ftools'

addremove = case ARGV[0]
when 'add' then true
when 'remove' then false
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
      diff_raw = addremove ? services-old : old-services
      diff = []
      diff_raw.each {|d| diff << Hash[*d.split]}
      puts "-------------------------------------"
      action = addremove ? "added" : "removed"
      puts "service(s) #{action}"
      puts "#####################################"
      diff.each do |d|
        print "#{d.keys} => "
        state = d.value?("on") ? "on" : "off"
        puts state
      end
      puts "#####################################"
      unless diff.empty?
        File.open(state_diff,"a") do |f|
          f.puts(Time.now)
          diff.each {|d| f.puts "#{d.keys} => #{d.values}"}
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
