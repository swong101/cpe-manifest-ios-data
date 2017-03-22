Pod::Spec.new do |s|

  s.name            = 'NextGenDataManager'
  s.version         = '3.0.0'
  s.summary         = 'Manifest.XML parser and full one-to-one mapping of the Manifest and Common Metadata specs to Swift objects'
  s.license         = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.homepage        = 'https://github.com/warnerbros/cpe-manifest-ios-data'
  s.author          = { 'Alec Ananian' => 'alec.ananian@warnerbros.com' }

  s.platform        = :ios, '8.0'
  
  s.source          = { :git => 'https://github.com/warnerbros/cpe-manifest-ios-data.git', :tag => s.version.to_s }
  s.source_files    = 'Source/**/*.swift', 'Source/*.swift'
  s.dependency        'SWXMLHash'

end
