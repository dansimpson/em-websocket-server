spec = Gem::Specification.new do |s|
  s.name = 'em-websocket-server'
  s.version = '0.15'
  s.date = '2010-08-30'
  s.summary = 'An evented ruby websocket server built on top of EventMachine'
  s.email = "dan.simpson@gmail.com"
  s.homepage = "http://github.com/dansimpson/em-websocket-server"
  s.description = "An evented ruby websocket server built on top of EventMachine"

  s.authors = ["Dan Simpson"]
  s.add_dependency('eventmachine', '>= 0.12.10')


  s.files = [
    "README.markdown",
    "em-websocket-server.gemspec",
    "lib/em-websocket-server.rb",
    "lib/em-websocket-server/server.rb",
    "lib/em-websocket-server/request.rb",
    "lib/em-websocket-server/protocol/version76.rb"
  ]
end
