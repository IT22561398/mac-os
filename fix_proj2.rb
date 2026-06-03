require 'xcodeproj'
project_path = 'CareBridge-macOS.xcodeproj'
project = Xcodeproj::Project.open(project_path)

target = project.targets.find { |t| t.name == 'CareBridge-macOS' }

# Delete EVERYTHING in main_group except Products and Frameworks
children_to_remove = []
project.main_group.children.each do |c|
  child_name = c.respond_to?(:name) ? c.name : nil
  child_path = c.respond_to?(:path) ? c.path : nil
  display = child_name || child_path
  if !['Products', 'Frameworks'].include?(display)
    children_to_remove << c
  end
end

children_to_remove.each { |c| c.remove_from_project }

main_group = project.main_group.new_group('CareBridge-macOS', 'CareBridge-macOS')

target.source_build_phase.files_references.each { |f| target.source_build_phase.remove_file_reference(f) }
target.resources_build_phase.files_references.each { |f| target.resources_build_phase.remove_file_reference(f) }

def add_files_to_group(project, target, dir_path, group)
  Dir.foreach(dir_path) do |file|
    next if file == '.' or file == '..' or file == '.DS_Store'
    full_path = File.join(dir_path, file)
    
    if File.directory?(full_path)
      if file.end_with?('.xcassets')
        file_ref = group.new_reference(file)
        target.resources_build_phase.add_file_reference(file_ref)
      else
        subgroup = group.new_group(file, file)
        add_files_to_group(project, target, full_path, subgroup)
      end
    else
      file_ref = group.new_reference(file)
      if file.end_with?('.swift')
        target.source_build_phase.add_file_reference(file_ref)
      elsif file.end_with?('.plist') || file.end_with?('.json') || file.end_with?('.entitlements')
        target.resources_build_phase.add_file_reference(file_ref)
      end
    end
  end
end

add_files_to_group(project, target, 'CareBridge-macOS', main_group)

# Update Entitlements setting
target.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'CareBridge-macOS/CareBridge.entitlements'
end

project.save
