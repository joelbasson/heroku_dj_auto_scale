# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)  
require "heroku_dj_auto_scale/version"

Gem::Specification.new do |s|
  s.name        = "heroku_dj_auto_scale"
  s.version     = HerokuDjAutoScale::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Joel Basson"]
  s.email       = []
  s.homepage    = "http://rubygems.org/gems/heroku_dj_auto_scale"
  s.summary     = %q{Allows auto-scaling of delayed job workers in Heroku}
  s.description = %q{Allows auto-scaling of delayed job workers in Heroku}

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "heroku_dj_auto_scale"

  s.add_runtime_dependency      'heroku'
  
  s.add_development_dependency "bundler", ">= 1.0.0.rc.6"
  
  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
