require 'xcodeproj'
require 'fileutils'

project_path = '/Users/student/Desktop/alive/alive.xcodeproj'

FileUtils.rm_rf(project_path)

project = Xcodeproj::Project.new(project_path)

# Configure project-level build settings for Simulator ONLY
project.build_configurations.each do |config|
  config.build_settings['SDKROOT'] = 'iphonesimulator'
  config.build_settings['SUPPORTED_PLATFORMS'] = 'iphonesimulator'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
end

# Create iOS App Target
app_target = project.new_target(:application, 'ALIVE', :ios, '17.0')

app_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_NAME'] = 'ALIVE'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.alive.app'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
  config.build_settings['SDKROOT'] = 'iphonesimulator'
  config.build_settings['SUPPORTED_PLATFORMS'] = 'iphonesimulator'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  config.build_settings['INFOPLIST_KEY_NSFaceIDUsageDescription'] = 'ALIVE uses Face ID to secure your hero profile and stats.'
  config.build_settings['INFOPLIST_KEY_UILaunchScreen_Generation'] = 'YES'
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  config.build_settings['CURRENT_PROJECT_VERSION'] = '1'
  config.build_settings['MARKETING_VERSION'] = '1.0'
end

# Collect source files for app
source_files = Dir.glob('/Users/student/Desktop/alive/ALIVE/**/*.swift').reject do |f|
  f.include?('/Tests/') || f.include?('/WatchApp/') || f.include?('/Extension/')
end

source_files.each do |file_path|
  file_ref = project.main_group.new_file(file_path)
  app_target.add_file_references([file_ref])
end

# Add Assets.xcassets if exists
assets_path = '/Users/student/Desktop/alive/ALIVE/Assets.xcassets'
if File.exist?(assets_path)
  assets_ref = project.main_group.new_file(assets_path)
  app_target.resources_build_phase.add_file_reference(assets_ref)
end

# Create scheme
scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(app_target)
scheme.save_as(project_path, 'ALIVE', true)

project.save

puts "Successfully generated simulator-only alive.xcodeproj"
