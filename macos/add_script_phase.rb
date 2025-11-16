#!/usr/bin/env ruby

require 'xcodeproj'

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)
runner_target = project.targets.find { |t| t.name == 'Runner' }

if runner_target
  # Find or create a run script build phase
  script_phase = runner_target.shell_script_build_phases.find do |phase|
    phase.shell_script&.include?('copy_firebase_config')
  end
  
  unless script_phase
    script_phase = runner_target.new_shell_script_build_phase("Copy Firebase Config")
    script_phase.shell_script = "${SOURCE_ROOT}/Runner/copy_firebase_config.sh"
    script_phase.show_env_vars_in_log = true
  end
  
  # Move to end (after Copy Bundle Resources)
  runner_target.build_phases.delete(script_phase)
  runner_target.build_phases << script_phase
  
  project.save
  puts "✅ Added copy_firebase_config.sh to build phases"
else
  puts "❌ Runner target not found"
end
