#!/usr/bin/env ruby

old_state = "/tmp/service_old"
new_state = "/tmp/service_new"
state_diff = "/tmp/service_diff"

services = `chkconfig`.to_a

if File.exists?(old_state)
  old = File.open(old_state,"r").to_a
  unless old == services
    File.open(new_state,"w") do |n|
      services.each {|s| n.puts s}
    end
    # now diff
    diff = `diff #{new_state} #{old_state} | grep ">" | cut -d" " -f2`
    unless diff.empty?
      File.open(state_diff,"w") {|m| m.puts(diff)}
    end
  end
else
  File.open(old_state,"w") do |f|
    services.each {|s| f.puts s}
  end
end
