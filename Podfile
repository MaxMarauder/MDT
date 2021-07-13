# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

use_frameworks!

inhibit_all_warnings!

target 'MDT' do
  # Pods for MDT
  pod 'Reusable'
  pod 'AMScrollingNavbar'
  pod 'CryptoSwift'

  target 'MDTTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MDTUITests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Reusable'
    pod 'AMScrollingNavbar'
    pod 'CryptoSwift'
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
