# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'SmartHeadGear' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks! :linkage => :static
  # add pods for desired Firebase products
  # https://firebase.google.com/docs/ios/setup#available-pods

  # Pods for SmartHeadGear
  pod "MetaWear", :subspecs => ['UI', 'AsyncUtils', 'Mocks', 'DFU']
  pod 'Firebase/Auth'
  pod 'FirebaseUI/Google'
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift'

  
  target 'SmartHeadGearTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SmartHeadGearUITests' do
    # Pods for testing
  end

end
