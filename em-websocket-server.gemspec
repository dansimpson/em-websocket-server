spec = Gem::Specification.new do |s|
	s.name = "em-websocket-server"
	s.version = "0.5"
	s.date = "2010-08-30"
	s.summary = "An evented ruby websocket server built on top of EventMachine"
	s.email = "dan.simpson@gmail.com"
	s.homepage = "http://github.com/dansimpson/em-websocket-server"
	s.description = "em-websocket-server allows the creation of efficient, evented, websocket services with ruby"
	s.has_rdoc = true
	
	s.authors = ["Dan Simpson"]
	s.add_dependency("eventmachine", ">= 0.12.10")

	s.files = [
    "README.markdown",
    "em-websocket-server.gemspec",
    "lib/em-websocket-server.rb",
    "lib/em-websocket-server/server.rb",
    "lib/em-websocket-server/request.rb",
    "lib/em-websocket-server/protocol/version76.rb"
	]
end
