spec = Gem::Specification.new do |s|
    s.name              = 'packetfu-spox'
    s.author            = %q(spox)
    s.email             = %q(spox@modspox.com)
    s.version           = '0.0.3'
    s.summary           = %q(Packet Inspector)
    s.platform          = Gem::Platform::RUBY
    s.has_rdoc          = true
    s.rdoc_options      = %w(--title PacketFu --main README --line-numbers)
    s.extra_rdoc_files  = %w(README)
    s.files             = Dir['**/*']
    s.require_paths     = %w(lib)
    description         = []
    File.open("README") do |file|
        file.each do |line|
            line.chomp!
            break if line.empty?
            description << "#{line.gsub(/\[\d\]/, '')}"
        end
    end
    s.description = description[1..-1].join(" ")
end