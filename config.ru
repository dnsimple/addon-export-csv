require './web/app'
require 'dotenv'

Dotenv.load

map '/' do
  run CsvExportAddon
end
