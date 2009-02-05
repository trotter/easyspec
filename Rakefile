require 'rake'
require 'spec/rake/spectask'
require 'rake/rdoctask'

desc 'Default: run specs.'
task :default => :spec

desc 'Run the easyspec specs'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*.rb']
end

desc 'Generate documentation for the easyspec plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Easyspec'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
