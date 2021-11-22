Pod::Spec.new do |s|
  s.name             = 'EGPieChart'
  s.version          = '0.1.3'
  s.summary          = 'A simple pie chart for iOS.'

  s.homepage         = 'https://github.com/GuanyiLL/EGPieChart'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ethan Guan' => 'yguanll@icloud.com' }
  s.source           = { :git => 'https://github.com/GuanyiLL/EGPieChart.git', :tag => s.version.to_s }
  s.swift_version = '5.3'
  s.ios.deployment_target = '9.0'
  s.source_files = 'Sources/EGPieChart/*.swift'
end
