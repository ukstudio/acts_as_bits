# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{acts_as_bits}
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["maiha"]
  s.date = %q{2009-10-19}
  s.description = %q{ActiveRecord plugin that maintains massive flags in one column}
  s.email = %q{maiha@wota.jp}
  s.extra_rdoc_files = ["README"]
  s.files = ["README", "Rakefile", "lib/acts_as_bits.rb", "test/database.yml", "test/fixtures", "test/fixtures/mixin.rb", "test/fixtures/mixins.yml", "test/schema.rb", "test/prefix_test.rb", "test/acts_as_bits_test.rb", "test/spec_helper.rb", "test/test_helper.rb", "test/dirty_spec.rb"]
  s.homepage = %q{http://github.com/maiha/acts_as_bits}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{ActiveRecord plugin that maintains massive flags in one column}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
