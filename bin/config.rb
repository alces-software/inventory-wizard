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
  puts
  sz = config_hash['config']['clusters'].size
  puts "These clusters are currently configured: "
  @cluster_hash = config_hash['config']['clusters'].each_with_index.map do |cluster,index|
    puts "#{index + 1}) #{cluster['name']} writing to #{cluster['location']}"
    [index + 1,cluster]
    #puts "- " +  i['name'] + " in " + i['location']
  end.to_h
  puts
end

def active_cluster(config_hash)
  cluster_name = config_hash['config']['clusters'].select {|i| i['in_use']}.first['name']
  location = config_hash['config']['clusters'].select {|i| i['in_use']}.first['location']
  puts
  puts "Active Cluster: " + cluster_name.to_s 
  puts 
  #puts "Writing to: " + location.to_s
end

def switch_active(config_hash)
  puts
  puts "Which cluster would you like to use?"
  show_clusters(config_hash)
  print " > "
  switchto = gets.chomp.to_i
  @cluster_hash[switchto]
  config_hash['config']['clusters'].select {|i| i['in_use'] == true }[0]['in_use'] = false
  @cluster_hash[switchto]['in_use'] = true 
  write_yaml(config_hash)
  puts
end

def new_cluster(config_hash)
  puts
  puts "New cluster name?"
  print " > "
  newname = gets.chomp.to_s
  puts
  puts "Path to write to?"
  print " > "
  newpath = gets.chomp.to_s
  newhash = {"name"=>newname, "location"=>newpath, "in_use"=>false}
  config_hash['config']['clusters'].push(newhash)
  puts
  write_yaml(config_hash)
end

#active_cluster(config_hash)
#show_clusters(config_hash)
#switch_active(config_hash)

menu = "Choose Option: 
   1) Show active cluster
   2) Show cluster paths
   3) Change active cluster
   4) New cluster
   5) Exit

 > "

loop do
  print menu
  opt = gets.chomp.to_i
  case opt
  when 1
    active_cluster(config_hash)
  when 2
    show_clusters(config_hash)
  when 3
    switch_active(config_hash)
  when 4
    new_cluster(config_hash)
  when 5
   break
  end
end
