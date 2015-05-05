#!/usr/bin/env ruby

require 'optparse'
require 'colorize'

$options = {}

OptionParser.new do |opts|
  opts.banner = "MTK ProjectConfig.mk diff tool\n" <<
                "Usage: mtk-diff-cfg.rb [options]"
  opts.separator "Options:"
  opts.on("-a", "--old ProjectConfig.mk", "Set A") { |t| $options[:a] = t }
  opts.on("-b", "--new ProjectConfig.mk", "Set B") { |t| $options[:b] = t }
end.parse!

unless $options[:a] && $options[:b]
  puts "Missing arguments"
  exit -1
end

begin
  file_a = File.read($options[:a])
  file_b = File.read($options[:b])
rescue => e
  puts "Cannot open one of the files!"
  exit -1
end

# remove comments and empty lines
file_a.gsub!(/#.*$/, "")
file_b.gsub!(/#.*$/, "")

hA = Hash.new
hB = Hash.new
# parse sections
file_a.scan(/^\s*(\w+)[ \t]*=[ \t]*(.*)$/) do |a, b|
    hA[a.strip] = b.strip.split(" ")
end
file_b.scan(/^\s*(\w+)[ \t]*=[ \t]*(.*)$/) do |a, b|
  hB[a.strip] = b.strip.split(" ")
end

hA.each do |k, v|
  puts "[-]".red << " #{k}\t#{v}" && next unless hB.has_key?(k)
  if hA[k].count == 1 && hB[k].count == 1
    puts "[*]".green << " #{k}\t#{v[0]} -> #{hB[k][0]}" if hA[k][0] != hB[k][0]
    next
  end
  added = hA[k] - hB[k]
  removed = hB[k] - hA[k]
  next if added.empty? && removed.empty?
  print "[*]".green << " #{k}\t"
  print added.to_s.green unless added.empty?
  print ", " << removed.to_s.red unless removed.empty?
  puts
end

hB.each do |k, v|
  puts "[+]".yellow << " #{k}\t#{v}" unless hA.has_key?(k)
end
