#!/usr/bin/env ruby

require 'yaml'
require 'highline/import'
require 'FileUtils'


$rack_template = 'rack_template.yaml'
$asset_template = 'asset_template.yaml'

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

puts "Provide name of Rack"
rackname = gets.chomp

if File.file?(rackname + ".yaml")
  rack_hash = YAML.load(File.read(rackname + '.yaml'))
else
  template_hash = YAML.load(File.read($rack_template))
  #Create new hash from template hash to be generated.
  rack_hash = template_hash
  #puts rack_hash.to_yaml
  #Rename key of entire rack and delete old template 'rack' key.
  rack_hash[rackname] = rack_hash.delete('rack')
  rack_hash[rackname]["name"] = rackname

  #Get size of new rack to be created
  puts "What size is the rack in RU?"
  racksize = gets.chomp.to_i
  map_hash = {}
  (1..racksize).each do |i|
    map_hash[i] = ''
  end
  rack_hash[rackname]['mutable']['map'] = map_hash
  puts rack_hash.to_yaml
  write_yaml(rack_hash,rackname)
end

confirm = ask("Do you want to add some assets to the rack?") { |yn| yn.limit = 1, yn.validate = /[yn]/i }
exit unless confirm.downcase == 'y'

while confirm.downcase == 'y' do
  puts "Which RU do you want to place the asset in?"
  asset_ru = gets.chomp.to_i

  puts "What is the asset called?"
  asset_name = gets.chomp.to_s

  add_asset_to_rack(asset_ru,asset_name,rackname,rack_hash)

  confirm = ask("Do you want to create the asset yaml now?") { |yn| yn.limit = 1, yn.validate = /[yn]/i }
  create_asset_yaml(asset_name) unless confirm.downcase == 'n'

  confirm = ask("Do you want to add some more assets to " + rackname + "?") { |yn| yn.limit = 1, yn.validate = /[yn]/i }
  exit unless confirm.downcase == 'y'
end



