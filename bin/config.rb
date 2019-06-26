#!/usr/bin/env ruby

require 'yaml'
require 'FileUtils'

$config = 'etc/config.yaml'

config_hash = YAML.load(File.read($config))

def write_yaml(hash)
    File.open($config ,"w") do |f|
      f.write hash.to_yaml
    end
  end

def show_clusters(config_hash)
    sz = config_hash['config']['clusters'].size
    puts "These clusters are currently configured: "
    config_hash['config']['clusters'].select do |i|
      puts "- " +  i['name'] + " in " + i['location']
    end
end

def active_cluster(config_hash)
    cluster_name = config_hash['config']['clusters'].select {|i| i['in_use']}.first['name']
    location = config_hash['config']['clusters'].select {|i| i['in_use']}.first['location']
    puts "Active Cluster: " + cluster_name.to_s 
    puts 
    #puts "Writing to: " + location.to_s
end

def switch_active(config_hash)
    puts "Which cluster would you like to use?"
    switchto = gets.chomp.to_s
    config_hash['config']['clusters'].select {|i| i['in_use'] == true }[0]['in_use'] = false
    config_hash['config']['clusters'].select {|i| i['name'] == switchto }[0]['in_use'] = true
    write_yaml(config_hash)
end

active_cluster(config_hash)
show_clusters(config_hash)
switch_active(config_hash)
