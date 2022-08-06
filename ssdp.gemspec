Gem::Specification.new do |spec|
  spec.author                = 'Darcy Aumiller'
  spec.authors               = ['Darcy Aumiller']
  spec.files                 = ['lib/ssdp.rb', 'lib/ssdp/producer.rb', 'lib/ssdp/consumer.rb', 'LICENSE']
  spec.name                  = 'ssdp'
  spec.platform              = Gem::Platform::RUBY
  spec.require_paths         = ['lib']
  spec.version               = '1.2.0'
  spec.license               = 'BSD-2-Clause'
  spec.summary               = 'SSDP client/server library.'
  spec.description           = 'SSDP client/server library. Server notify/part/respond; client search/listen.'
  spec.email                 = 'darcy.aumiller@gmail.com'
  spec.homepage              = 'https://github.com/daumiller/ssdp'
  spec.required_ruby_version = '>= 1.9.0'
end
