def write_new_yaml
  # delete admin node from the list
  machines = %x(crowbar machines list).split
  machines.shift
  role_map = {}
  file = YAML.load_file("proposal_ha.yml")
  proposals = %w(pacemaker database keystone rabbitmq glance cinder neutron nova nova_dashboard ceilometer heat)
  proposals.each do |proposal|
    ref = file["proposals"].select {|m| m["barclamp"] == proposal}
    role = ref[0]["deployment"]["elements"].keys
    role_map[proposal] = []
    role.each do |r|
      role_map[proposal] << r
    end
  end
  file_new = file.clone

  role_map.each do |proposal,roles|
    roles.each do |role|
      file_new["proposals"].select {|m| m["barclamp"] == proposal}[0]["deployment"]["elements"][role] << "NODE"
    end
  end

  File.open("proposal_new.yml","w"){|f| f.puts file_new.to_yaml}
end
