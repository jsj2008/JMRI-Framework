Pod::Spec.new do |spec|
  spec.name         = 'libJMRI'
  spec.version      = '0.1.0'
  spec.license      = { :type => 'BSD' }
  spec.homepage     = 'https://github.com/rhwood/JMRI-Framework'
  spec.authors      = { 'Randall Wood' => 'randall.h.wood@alexandriasoftware.com' }
  spec.summary      = 'A library for networking with JMRI software.'

# Source Info
  spec.platform     = :ios, '7.1'
  spec.source       = { :git => 'https://github.com/rhwood/JMRI-Framework.git' }
  spec.source_files = 'JMRI.h', 'Classes/*.{h,m}', 'Classes/**/*.{h,m}'
  spec.framework    = 'Foundation'

  spec.requires_arc = true
  
# Pod Dependencies
  spec.dependency   'SocketRocket', '~> 0.3.1-beta2'

end