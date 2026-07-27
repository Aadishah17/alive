require 'fileutils'
require 'xcodeproj'

workspace_root = '/Users/student/Desktop/alive'
project_path = File.join(workspace_root, 'alive.xcodeproj')
app_root = File.join(workspace_root, 'ALIVE')

FileUtils.rm_rf(project_path)

project = Xcodeproj::Project.new(project_path)

project.build_configurations.each do |config|
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
  config.build_settings['SWIFT_VERSION'] = '5.0'
end

def configure_app_target(target, bundle_identifier:, info_plist:, entitlements: nil)
  target.build_configurations.each do |config|
    config.build_settings['PRODUCT_NAME'] = target.name
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = bundle_identifier
    config.build_settings['SWIFT_VERSION'] = '5.0'
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
    config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
    config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
    config.build_settings['INFOPLIST_FILE'] = info_plist
    config.build_settings['CURRENT_PROJECT_VERSION'] = '1'
    config.build_settings['MARKETING_VERSION'] = '1.0'
    config.build_settings['CODE_SIGN_ENTITLEMENTS'] = entitlements if entitlements
  end
end

# `xcodeproj`'s convenience helper can bake its own "last known" SDK number
# into framework paths. SDKROOT-relative references keep this project portable
# across Xcode releases instead of pointing at an obsolete SDK directory.
def add_ios_system_framework(target, name)
  group = target.project.frameworks_group['iOS'] || target.project.frameworks_group.new_group('iOS')
  path = "System/Library/Frameworks/#{name}.framework"
  reference = group.find_file_by_path(path) || group.new_file(path, :sdk_root)
  target.frameworks_build_phase.add_file_reference(reference, true)
end

def normalize_ios_framework_references(project)
  project.objects.grep(Xcodeproj::Project::Object::PBXFileReference).each do |reference|
    next unless reference.source_tree == 'DEVELOPER_DIR'
    next unless reference.path&.include?('Platforms/iPhoneOS.platform/Developer/SDKs/')
    next unless reference.path&.include?('/System/Library/Frameworks/')

    reference.path = "System/Library/Frameworks/#{File.basename(reference.path)}"
    reference.source_tree = 'SDKROOT'
  end
end

app_target = project.new_target(:application, 'ALIVE', :ios, '17.0')
configure_app_target(
  app_target,
  bundle_identifier: 'com.alive.app',
  info_plist: 'ALIVE/Info.plist',
  entitlements: 'ALIVE/ALIVE.entitlements'
)
app_target.build_configurations.each do |config|
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
end
['ActivityKit', 'HealthKit', 'UserNotifications', 'WidgetKit'].each do |framework|
  add_ios_system_framework(app_target, framework)
end

app_sources = Dir.glob(File.join(app_root, '**', '*.swift')).reject do |path|
  path.include?('/Tests/') ||
    path.include?('/WatchApp/') ||
    path.include?('/Extension/') ||
    path.include?('/Extensions/')
end
app_sources.each do |path|
  app_target.add_file_references([project.main_group.new_file(path)])
end

assets_path = File.join(app_root, 'Assets.xcassets')
if File.exist?(assets_path)
  assets_ref = project.main_group.new_file(assets_path)
  app_target.resources_build_phase.add_file_reference(assets_ref)
end

widget_target = project.new_target(:app_extension, 'ALIVEWidgets', :ios, '17.0')
configure_app_target(
  widget_target,
  bundle_identifier: 'com.alive.app.widgets',
  info_plist: 'ALIVE/Extensions/ALIVEWidgets/Info.plist',
  entitlements: 'ALIVE/Extensions/ALIVEWidgets/ALIVEWidgets.entitlements'
)
widget_target.build_configurations.each do |config|
  config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
  config.build_settings['SKIP_INSTALL'] = 'YES'
end

widget_sources = Dir.glob(File.join(app_root, 'Extensions', 'ALIVEWidgets', '*.swift'))
shared_widget_sources = Dir.glob(File.join(app_root, 'Shared', '*.swift'))
widget_group = project.main_group.new_group('ALIVE Widgets')
(widget_sources + shared_widget_sources).each do |path|
  widget_target.add_file_references([widget_group.new_file(path)])
end
['ActivityKit', 'WidgetKit'].each do |framework|
  add_ios_system_framework(widget_target, framework)
end

app_target.add_dependency(widget_target)
embed_extensions_phase = app_target.new_copy_files_build_phase('Embed App Extensions')
embed_extensions_phase.symbol_dst_subfolder_spec = :plug_ins
embed_extensions_phase.add_file_reference(widget_target.product_reference, true)

test_target = project.new_target(:unit_test_bundle, 'ALIVETests', :ios, '17.0')
test_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.alive.app.tests'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  config.build_settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/ALIVE.app/ALIVE'
  config.build_settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
end
test_target.add_dependency(app_target)
Dir.glob(File.join(app_root, 'Tests', '*.swift')).each do |path|
  test_target.add_file_references([project.main_group.new_file(path)])
end

scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(app_target)
scheme.add_build_target(test_target, false)
scheme.add_test_target(test_target)
scheme.set_launch_target(app_target)
scheme.save_as(project_path, 'ALIVE', true)

normalize_ios_framework_references(project)
project.save

puts 'Successfully generated ALIVE iOS project with widgets, Live Activities, and unit tests.'
