require './web/app'

map '/' do
  run CsvExportAddon
end
