Gem::Specification.new do |spec|
  spec.author                = 'Dillon Aumiller'
  spec.authors               = ['Dillon Aumiller']
  spec.files                 = ['lib/ssdp.rb', 'lib/ssdp/producer.rb', 'lib/ssdp/consumer.rb', 'LICENSE']
  spec.name                  = 'ssdp'
  spec.platform              = Gem::Platform::RUBY
  spec.require_paths         = ['lib']
  spec.version               = '1.1.7'
  spec.license               = 'BSD 2-Clause'
  spec.summary               = 'SSDP client/server library.'
  spec.description           = 'SSDP client/server library. Server notify/part/respond; client search/listen.'
  spec.email                 = 'dillonaumiller@gmail.com'
  spec.homepage              = 'https://github.com/daumiller/ssdp'
  spec.required_ruby_version = '>= 1.9.0'
end
