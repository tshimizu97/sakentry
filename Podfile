# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'Sakentry (iOS)' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'FirebaseUI/Auth'
  pod 'FirebaseUI/Google'
  # Pods for Sakentry (iOS)
  # add the Firebase pod for Google Analytics
  pod 'Firebase/Analytics'
  # add pods for any other desired Firebase products
  # https://firebase.google.com/docs/ios/setup#available-pods'

  pod 'Firebase/Firestore'
  # Optionally, include the Swift extensions if you're using Swift.
  pod 'FirebaseFirestoreSwift'

  pod 'Firebase/Storage'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
  end

  pod 'Cosmos', '~> 23.0'

end

target 'Sakentry (macOS)' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Sakentry (macOS)

end