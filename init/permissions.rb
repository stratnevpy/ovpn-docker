#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require 'pp'

def log(string)
  puts 'permissions.rb: ' + string
end

def parse_config_file(name)
  config_path = "permissions/#{name}"

  unless File.exist?(config_path)
    #puts "There is no specific configuration for #{name}."
    #p name
    #exit 0
    return
  end

  config_source = IO.read(config_path).split("\n")

  config = config_source.inject([]) do |result,line|
    ip, protocol, port = line.split(/\s+/)
    result << {
      ip: ip,
      protocol: protocol,
      port: port || '0'
    }
  end
end

def get_config(name)
  config = parse_config_file('default')
  user_config = parse_config_file(name)
  if user_config
    config = user_config
  end
  config
end

def apply_rule(rule)
  command = "/usr/sbin/iptables-legacy -w 20 #{rule}"
  log(command)
  system(command)
end

def remove_rule(number)
  command = "/usr/sbin/iptables-legacy -w 20 -D FORWARD #{number}"
  log(command)
  system(command)
end

def allow_target(source_ip, options)
  if options[:protocol] == 'all'
    apply_rule("-A FORWARD -s #{source_ip} -d #{options[:ip]} -p #{options[:protocol]} -j ACCEPT")
  elsif options[:protocol] == 'icmp'
    # Разрешить для клиента пинговать конкретный хост
    apply_rule("-A FORWARD -s #{source_ip} -d #{options[:ip]} -p icmp --icmp-type echo-request -j ACCEPT")
  elsif options[:port]
    # Разрешить для клиента доступ к конкретному порту (или портам) конкретного хоста.
    ports = options[:port].split(",")
    if ports.length() == 1
        apply_rule("-A FORWARD -s #{source_ip} -d #{options[:ip]} -p #{options[:protocol]} --dport #{options[:port]} -j ACCEPT")
        apply_rule("-A FORWARD -s #{source_ip} -d #{options[:ip]} -p icmp --icmp-type echo-request -j ACCEPT")
    elsif ports.length() > 1
        apply_rule("-A FORWARD -m multiport -s #{source_ip} -d #{options[:ip]} -p #{options[:protocol]} --dports #{options[:port]} -j ACCEPT")
        apply_rule("-A FORWARD -s #{source_ip} -d #{options[:ip]} -p icmp --icmp-type echo-request -j ACCEPT")
    end
  end
end

def clear_targets(source_ip)
  # Удалить все правила из таблицы FORWARD, содержащие source_ip.

  rules_exist = true

  while rules_exist

    table = `/usr/sbin/iptables-legacy -w 20 -n -L FORWARD --line-number`.split("\n")

    the_line = table.find do |line|
      fields = line.split(/\s+/)
      ip = fields[4]
      ip == source_ip
    end

    if the_line
      number = the_line.split(/\s+/)[0]
      remove_rule(number)
    else
      rules_exist = false
    end

  end

end

################################################################################

script_type = ENV['script_type']
log(script_type)

name      = ENV['common_name']
source_ip = ENV['ifconfig_pool_remote_ip']

case script_type
when 'client-connect'
  config = get_config(name)
  config.each{|target| allow_target(source_ip, target)}
when 'client-disconnect'
  clear_targets(source_ip)
else
  puts "Unknown script type #{script_type}."
end

