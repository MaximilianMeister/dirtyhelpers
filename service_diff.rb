#!/usr/bin/env ruby

old_state = "/tmp/service_old"
new_state = "/tmp/service_new"
state_diff = "/tmp/service_diff"

while true
  services = `chkconfig`.to_a
  if File.exists?(old_state)
    old = File.open(old_state,"r").to_a
    unless old == services
      puts "something changed..."
      puts "writing new chkconfig..."
      File.open(new_state,"w") do |n|
        services.each {|s| n.puts s}
      end
      # now diff
      puts "diffing..."
      diff = `diff #{new_state} #{old_state} | grep ">" | cut -d" " -f2`
      puts "service(s) #{diff} changed..." 
      unless diff.empty?
        File.open(state_diff,"w") {|m| m.puts(diff)}
      end
      File.open(old_state,"w") do |f|
        services.each {|s| f.puts s}
      end
    end
  else
    puts "writing initial chkconfig..."
    File.open(old_state,"w") do |f|
      services.each {|s| f.puts s}
    end
  end
  sleep(10)
end
