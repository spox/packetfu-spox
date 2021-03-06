#!/usr/bin/env ruby

# A simple local network fingerprinter. Uses the OUI list.

$oui_prefixes = {}
$arp_results = []
def build_oui_list
	if ARGV[0].nil?
		require 'open-uri'
		puts "Fetching the oui.txt from IEEE, it'll be a second. Avoid this with #{$0} <filename>."
	oui_file = open("http://standards.ieee.org/regauth/oui/oui.txt")
	else
	oui_file =	File.open(ARGV[0])
	end
	oui_file.each do |oui_line|
		maybe_oui = oui_line.scan(/^[0-9a-f]{2}\-[0-9a-f]{2}\-[0-9a-f]{2}/i)[0]
		unless maybe_oui.nil?
			oui_value = maybe_oui
			oui_vendor = oui_line.split(/\(hex\)\s*/)[1] || "PRIVATE"
			$oui_prefixes[oui_value] = oui_vendor.chomp
		end
	end
end

build_oui_list

$root_ok = true if Process.euid.zero?

def arp_everyone
	require 'packetfu'
	my_net = PacketFu::Config.new(PacketFu::Utils.whoami?(:iface => 'wlan0'))
	threads = []
	network = "192.168.1"
	puts "Arping around..."
	253.times do |i|
		threads[i] = Thread.new do
			this_host = network + ".#{i+1}"
			colon_mac = PacketFu::Utils.arp(this_host,my_net.config)
			unless colon_mac.nil?
				hyphen_mac = colon_mac.tr(':','-').upcase[0,8]
			else
				hyphen_mac = colon_mac = "NOTHERE"
			end
				$arp_results <<  "%s : %s / %s" % [this_host,colon_mac,$oui_prefixes[hyphen_mac]]
		end
		threads.join
	end
end

if $root_ok
	arp_everyone
	puts "\n"
	sleep 3
	$arp_results.sort.each {|a| puts a unless a =~ /NOTHERE/}
end

