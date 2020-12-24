# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
platform :ios, '10.0'
inhibit_all_warnings!

target 'cx_tool' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'AFNetworking', '~> 4.0.0'
  pod 'Alamofire', '5.2.0'
  pod 'WCDB.swift', :git => 'https://github.com/demonnboy/wcdb.git'
  pod 'YYModel'
  pod 'SnapKit'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 10.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
      end
    end
  end
end
