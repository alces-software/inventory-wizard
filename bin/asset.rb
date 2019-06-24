#!/usr/bin/env ruby

require 'yaml'
require 'highline/import'
require 'FileUtils'

$asset_template = 'etc/asset_template.yaml'

def create_asset_yaml(name)
  asset_hash = YAML.load(File.read($asset_template))
  asset_hash[name] = asset_hash.delete('asset')
  asset_hash[name]['name'] = name
  write_yaml(asset_hash,name)
end

def write_yaml(hash,name)
  File.open(name + ".yaml","w") do |f|
    f.write hash.to_yaml
  end
end

def add_asset_to_rack(asset_ru_add,asset_name_add,rack_name_add,rack_hash_add)
  rack_hash_add[rack_name_add]['mutable']['map'][asset_ru_add.to_i] = asset_name_add
  puts rack_hash_add.to_yaml
  write_yaml(rack_hash_add,rack_name_add)
end

def switch_updateports(asset_hash_update,asset_name_update)
  puts "How are the ports laid out? [DownRight, DownLeft, UpRight, UpLeft]"
  asset_hash_update[asset_name_update]['mutable']['map_pattern'] = gets.chomp.to_s
  puts "How many rows are there? [n]"
  rows = gets.chomp.to_i
  puts "How many columns are there? [n]"
  cols = gets.chomp.to_i
  asset_hash_update[asset_name_update]['mutable']['map_dimensions'] = rows.to_s + 'x' + cols.to_s
  size = rows * cols
  map_hash = {}
  (1..size).each do |i|
    map_hash[i] = ''
  end
  asset_hash_update[asset_name_update]['mutable']['map'] = map_hash
  write_yaml(asset_hash_update,asset_name_update)
end

def switch_mapports(asset_hash_map,asset_name_map)
  puts "What port is the device in?"
  loc = gets.chomp.to_i
  puts "What's the name of the asset in this port?"
  asset_hash_map[asset_name_map]['mutable']['map'][loc] = gets.chomp.to_s
end 

puts "Provide name of Asset to modify"
assetname = gets.chomp

if File.file?(assetname + ".yaml")
  asset_hash = YAML.load(File.read(assetname + '.yaml'))
else
  template_hash = YAML.load(File.read($asset_template))
  #Create new hash from template hash to be generated.
  asset_hash = template_hash
  #Rename key of asset and delete old template 'asset' key.
  asset_hash[assetname] = asset_hash.delete('asset')
  asset_hash[assetname]["name"] = assetname
  puts asset_hash.to_yaml
  write_yaml(asset_hash,assetname)
end


puts "What type of asset is this? [switch, node, chassis]"
asset_type = gets.chomp.to_s
case asset_type
  when 'switch'
    confirm = ask("Do you want to update the port layout?") { |yn| yn.limit = 1, yn.validate = /[yn]/i }
    switch_updateports(asset_hash,assetname) unless confirm.downcase == 'n'
    puts asset_hash.to_yaml
    confirm = ask("Do you want to map a device to a port?") { |yn| yn.limit = 1, yn.validate = /[yn]/i }
    switch_mapports(asset_hash,assetname) unless confirm.downcase == 'n'
    puts asset_hash.to_yaml
  when 'node'
    puts 'node time'
  when 'chassis'
    puts 'chassis time'
end


