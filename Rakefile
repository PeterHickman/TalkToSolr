# -*- ruby -*-

require 'rubygems'
require 'rake/testtask'
require 'rake/gempackagetask'

$:.push 'lib'
require 'talktosolr'

PKG_NAME    = 'talktosolr'
PKG_VERSION = TalkToSolr::VERSION

spec = Gem::Specification.new do |s|
  s.name              = PKG_NAME
  s.version           = PKG_VERSION
  s.summary           = 'Talk to Solr search'

  s.files             = FileList['lib/**/*.rb']
  s.test_files        = FileList['test/*.rb']

  s.has_rdoc          = true
  s.rdoc_options     << '--title' << 'TalkToSolr' << '--charset' << 'utf-8'

  s.author            = 'Peter Hickman'
  s.email             = 'peterhi@ntlworld.com'

#  s.homepage          = 'http://thumbnailer.rubyforge.org'
#  s.rubyforge_project = 'thumbnailer'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

desc "Run all the tests"
Rake::TestTask.new("test") do |t|
  t.pattern = 'tests/*.rb'
  t.verbose = false
  t.warning = true
end