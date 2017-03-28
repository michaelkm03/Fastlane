require 'Spaceship'

Spaceship::Tunes.login("ios-admin@getvictorious.com", "5H8fWxYm3OBxSv3xZ6X4ePVK")

# Get app by Apple ID, assign to to 'app'.  Then assign live version build to 'v'
app = Spaceship::Tunes::Application.find(1170276627)
v = app.live_version

puts '########## APP METADATA ##############'
puts "App Status:    %s" % v.app_status        # => "Waiting for Review"
puts "LIVE Version:  %s" % v.version           # => "0.9.14"
puts "Keywords:      %s" % v.keywords
puts "Description:   %s" % v.description
puts "App Status:    %s" % v.app_status
