require './app'

map '/' do
  run DnsimpleHeroku::App
end
