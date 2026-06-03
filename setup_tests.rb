# setup_tests.rb
# Adds an XCTest target to the CareBridge-macOS project

require 'xcodeproj'
require 'fileutils'

project_path = 'CareBridge-macOS.xcodeproj'
project = Xcodeproj::Project.open(project_path)

test_target_name = 'CareBridgeTests'
test_folder = 'Tests'

# Create Tests directory if it doesn't exist
FileUtils.mkdir_p(test_folder)

# Find or create a group for tests
tests_group = project.main_group.find_subpath(test_folder, true)

# Get the main target
main_target = project.targets.find { |t| t.name == 'CareBridge-macOS' }

# Check if test target already exists
test_target = project.targets.find { |t| t.name == test_target_name }
if test_target.nil?
  # Create the test target (macOS unit test)
  test_target = project.new_target(:unit_test_bundle, test_target_name, :osx)
  
  # Add the main target as a dependency
  test_target.add_dependency(main_target)
  
  # Set up build settings
  test_target.build_configurations.each do |config|
    config.build_settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/CareBridge-macOS.app/Contents/MacOS/CareBridge-macOS'
    config.build_settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
    config.build_settings['SWIFT_VERSION'] = '5.0'
    config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '14.0'
  end
  puts "Created new test target: #{test_target_name}"
else
  puts "Test target #{test_target_name} already exists."
end

# Add test files to the target
Dir.foreach(test_folder) do |file|
  next if file == '.' or file == '..' or file == '.DS_Store'
  full_path = File.join(test_folder, file)
  
  if file.end_with?('.swift')
    # Check if reference already exists
    file_ref = tests_group.find_file_by_path(file)
    if file_ref.nil?
      file_ref = tests_group.new_reference(file)
    end
    
    # Add to build phase if not already there
    unless test_target.source_build_phase.files_references.include?(file_ref)
      test_target.source_build_phase.add_file_reference(file_ref)
      puts "Added #{file} to test target."
    end
  end
end

project.save
puts "Successfully configured XCTest target."
