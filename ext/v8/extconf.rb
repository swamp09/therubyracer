require 'mkmf'
cxx = RbConfig::MAKEFILE_CONFIG['CXX'] = ENV['CXX'] if ENV['CXX']

have_library('pthread')
have_library('objc') if RUBY_PLATFORM =~ /darwin/

$CPPFLAGS += " -Wall" unless $CPPFLAGS.split.include? "-Wall"
$CPPFLAGS += " -g" unless $CPPFLAGS.split.include? "-g"
$CPPFLAGS += " -rdynamic" unless $CPPFLAGS.split.include? "-rdynamic" unless RUBY_PLATFORM =~ /darwin/
$CPPFLAGS += " -fPIC" unless $CPPFLAGS.split.include? "-rdynamic" or RUBY_PLATFORM =~ /darwin/
$CPPFLAGS += " -std=c++11"


if cxx =~ /clang/
   $LDFLAGS += " -stdlib=libstdc++"
end

CONFIG['LDSHARED'] = '$(CXX) -shared' unless RUBY_PLATFORM =~ /darwin/
if CONFIG['warnflags']
  CONFIG['warnflags'].gsub!('-Wdeclaration-after-statement', '')
  CONFIG['warnflags'].gsub!('-Wimplicit-function-declaration', '')
end
if enable_config('debug')
  $CFLAGS += " -O0 -ggdb3"
end

LIBV8_COMPATIBILITY = '~> 4.5.95'

begin
  require 'rubygems'
  gem 'libv8', LIBV8_COMPATIBILITY
rescue Gem::LoadError
  warn "Warning! Unable to load libv8 #{LIBV8_COMPATIBILITY}."
rescue LoadError
  warn "Warning! Could not load rubygems. Please make sure you have libv8 #{LIBV8_COMPATIBILITY} installed."
ensure
  require 'libv8'
end

Libv8.configure_makefile

create_makefile('v8/init')
