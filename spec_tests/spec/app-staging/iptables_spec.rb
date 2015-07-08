# declare desired iptables rules
# These rules should be present in prod and staging
# TODO: There are also hardcoded IP addresses in this section.
desired_iptables_rules = [
  '-P INPUT DROP',
  '-P FORWARD DROP',
  '-P OUTPUT DROP',
  '-N LOGNDROP',
  '-A INPUT -i eth0 -p tcp -m tcp --dport 8080 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT',
  '-A INPUT -i eth0 -p tcp -m tcp --dport 80 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT',
  '-A INPUT -i eth0 -p udp -m udp --sport 53 -m state --state RELATED,ESTABLISHED -j ACCEPT',
  '-A INPUT -i eth0 -p tcp -m tcp --dport 22 -m state --state NEW -m limit --limit 3/min --limit-burst 3 -j ACCEPT',
  '-A INPUT -i eth0 -p tcp -m tcp --dport 22 -m state --state NEW -j LOGNDROP',
  '-A INPUT -i eth0 -p tcp -m tcp --dport 22 -m state --state RELATED,ESTABLISHED -j ACCEPT',
  '-A INPUT -d 10.0.2.15/32 -i eth0 -p tcp -m state --state RELATED,ESTABLISHED -j ACCEPT',
  '-A INPUT -s 127.0.0.1/32 -d 127.0.0.1/32 -i lo -p tcp -m multiport --sports 22,80,8080 -m state --state RELATED,ESTABLISHED -j ACCEPT',
  '-A INPUT -s 127.0.0.1/32 -d 127.0.0.1/32 -i lo -p tcp -m tcp --dport 22 -m state --state NEW -m limit --limit 3/min --limit-burst 3 -j ACCEPT',
  '-A INPUT -p tcp -m tcp --dport 22 -m state --state NEW -j LOGNDROP',
  '-A INPUT -s 127.0.0.1/32 -d 127.0.0.1/32 -i lo -p tcp -m tcp --dport 22 -m state --state RELATED,ESTABLISHED -j ACCEPT',
  '-A INPUT -s 127.0.0.1/32 -d 127.0.0.1/32 -i lo -p tcp -m multiport --dports 80,8080 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT',
  '-A INPUT -s 127.0.0.1/32 -d 127.0.0.1/32 -i lo -p tcp -m tcp --sport 6379 -m state --state RELATED,ESTABLISHED -j ACCEPT',
  '-A INPUT -s 127.0.0.1/32 -d 127.0.0.1/32 -i lo -p tcp -m tcp --dport 6379 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT',
  "-A INPUT -s #{property['monitor_ip']}/32 -p udp -m udp --sport 1514 -m state --state RELATED,ESTABLISHED -j ACCEPT",
  "-A INPUT -s #{property['monitor_ip']}/32 -p udp -m udp --sport 1514 -m state --state RELATED,ESTABLISHED -j ACCEPT",
  '-A INPUT -s 8.8.8.8/32 -d 10.0.2.15/32 -i eth0 -p udp -m udp --sport 53 -m state --state RELATED,ESTABLISHED -j ACCEPT',
  '-A INPUT -d 10.0.2.15/32 -i eth0 -p udp -m udp --sport 123 --dport 123 -m state --state RELATED,ESTABLISHED -j ACCEPT',
  '-A INPUT -d 10.0.2.15/32 -i eth0 -p tcp -m multiport --sports 80,443 -m state --state RELATED,ESTABLISHED -j ACCEPT',
  '-A INPUT -p tcp -m state --state INVALID -j DROP',
  '-A INPUT -j LOGNDROP',
  "-A OUTPUT -o eth0 -p tcp -m tcp --sport 8080 -m state --state RELATED,ESTABLISHED -m owner --uid-owner #{property['apache_user_uid']} -j ACCEPT",
  '-A OUTPUT -o eth0 -p tcp -m tcp --sport 8080 -m state --state RELATED,ESTABLISHED -m owner --uid-owner 0 -j ACCEPT',
  "-A OUTPUT -o eth0 -p tcp -m tcp --sport 80 -m state --state RELATED,ESTABLISHED -m owner --uid-owner #{property['apache_user_uid']} -j ACCEPT",
  '-A OUTPUT -o eth0 -p tcp -m tcp --sport 80 -m state --state RELATED,ESTABLISHED -m owner --uid-owner 0 -j ACCEPT',
  '-A OUTPUT -o eth0 -p udp -m udp --dport 53 -m state --state NEW,RELATED,ESTABLISHED -m owner --uid-owner 0 -j ACCEPT',
  '-A OUTPUT -o eth0 -p tcp -m tcp --sport 22 -m state --state RELATED,ESTABLISHED -m owner --uid-owner 0 -j ACCEPT',
  "-A OUTPUT -s 10.0.2.15/32 -o eth0 -p tcp -m owner --uid-owner #{property['tor_user_uid']} -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT",
  "-A OUTPUT -s 127.0.0.1/32 -d 127.0.0.1/32 -o lo -p tcp -m multiport --dports 22,80,8080 -m owner --uid-owner #{property['tor_user_uid']} -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT",
  "-A OUTPUT -m owner --uid-owner #{property['tor_user_uid']} -j LOGNDROP",
  '-A OUTPUT -s 127.0.0.1/32 -d 127.0.0.1/32 -o lo -p tcp -m tcp --sport 22 -m owner --uid-owner 0 -m state --state RELATED,ESTABLISHED -j ACCEPT',
  "-A OUTPUT -m owner --gid-owner #{property['ssh_group_gid']} -j LOGNDROP",
  "-A OUTPUT -s 127.0.0.1/32 -d 127.0.0.1/32 -o lo -p tcp -m multiport --sports 80,8080 -m owner --uid-owner #{property['apache_user_uid']} -m state --state RELATED,ESTABLISHED -j ACCEPT",
  "-A OUTPUT -s 127.0.0.1/32 -d 127.0.0.1/32 -o lo -p tcp -m tcp --dport 6379 -m owner --uid-owner #{property['apache_user_uid']} -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT",
  "-A OUTPUT -s 127.0.0.1/32 -d 127.0.0.1/32 -o lo -p tcp -m tcp --sport 6379 -m owner --uid-owner #{property['redis_user_uid']} -m state --state RELATED,ESTABLISHED -j ACCEPT",
  "-A OUTPUT -m owner --uid-owner #{property['apache_user_uid']} -j LOGNDROP",
  "-A OUTPUT -d #{property['monitor_ip']}/32 -p udp -m udp --dport 1514 -m owner --uid-owner #{property['ossec_user_uid']} -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT",
  "-A OUTPUT -d #{property['monitor_ip']}/32 -p udp -m udp --dport 1514 -m owner --uid-owner #{property['ossec_user_uid']} -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT",
  "-A OUTPUT -m owner --uid-owner #{property['ossec_user_uid']} -j LOGNDROP",
  '-A OUTPUT -s 10.0.2.15/32 -d 8.8.8.8/32 -o eth0 -p udp -m udp --dport 53 -m owner --uid-owner 0 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT',
  '-A OUTPUT -s 10.0.2.15/32 -o eth0 -p udp -m udp --sport 123 --dport 123 -m owner --uid-owner 0 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT',
  '-A OUTPUT -s 10.0.2.15/32 -o eth0 -p tcp -m multiport --dports 80,443 -m owner --uid-owner 0 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT',
  '-A OUTPUT -m owner --uid-owner 0 -j LOGNDROP',
  '-A OUTPUT -j LOGNDROP',
  '-A LOGNDROP -p tcp -m limit --limit 5/min -j LOG --log-tcp-options --log-ip-options --log-uid',
  '-A LOGNDROP -m limit --limit 5/min -j LOG --log-ip-options --log-uid',
  '-A LOGNDROP -j DROP',
]

# declare unwanted iptables rules
# These rules should have been removed by the `remove_authd_exceptions` role
# TODO: The Vagrantfile virtualbox static IP was hardcoded into the two rules
# below. This will need to be fixed. Possibly with using something like
# https://github.com/volanja/ansible_spec Using the values for IP addresses
# from the ansible inventory should cover most use cases (except inventories
# with just the *.onion addresses).
unwanted_iptables_rules = [
  "-A OUTPUT -d #{property['monitor_ip']} -p tcp --dport 1515 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT",
  "-A INPUT -s #{property['monitor_ip']} -p tcp --sport 1515 -m state --state ESTABLISHED,RELATED -j ACCEPT",

  # These rules have the wrong interface for the vagrant mon-staging machine.
  # Adding them in here to make sure ansible config changes don't introduce regressions.
  '-A INPUT -s 10.0.2.15/32 -p udp -m udp --sport 1514 -m state --state RELATED,ESTABLISHED -j ACCEPT',
  '-A OUTPUT -d 10.0.2.15/32 -p udp -m udp --dport 1514 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT',
]

# check for wanted and unwanted iptables rules
describe iptables do
  unwanted_iptables_rules.each do |unwanted_iptables_rule|
    it { should_not have_rule(unwanted_iptables_rule) }
  end
  desired_iptables_rules.each do |desired_iptables_rule|
    it { should have_rule(desired_iptables_rule) }
  end
end
