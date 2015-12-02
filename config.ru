require 'sprockets'
require 'sprockets-sass'
require './web/app'
require 'dotenv'

Dotenv.load

CsvExportAddon.configure(:production) do
  Sprockets::Sass.options[:style] = :compressed
  Sprockets::Sass.options[:line_comments] = false
end

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'assets/stylesheets'
  run environment
end

map '/' do
  run CsvExportAddon
end
