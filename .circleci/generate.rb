require "erb"

Dir.chdir("#{__dir__}/../")
projects = Dir.glob('*').select {|f| File.directory? f}

circleciConfigs = projects.map do |project|
    File.read("#{project}/.circleci/config.yml")
end

template = File.read("#{__dir__}/config.yml.erb")
result = ERB.new(template).result
result = "#\n# WARNING: THIS IS A GENERATED FILE, DO NOT CHANGE IT DIRECTLY\n#\n" + result

File.open("#{__dir__}/config.yml", 'w') { |file| file.write(result) }

puts "Done"