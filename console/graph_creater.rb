def connection_exists(c, s, d)
  c.each do |connection|
    return false if (
      connection[0] == s && connection[1] == d ||
      connection[0] == d && connection[1] == s ||
      c.empty?
    )
  end

  return true
end

puts "Graph generator V.1"
puts "Enter number of vertexes (V) and number of interrconnections (E)"
puts "Note! All connections will be two-way."

print "Number of vertexes (V) >> "; V = gets.to_i
print "Number of edges (E) >> "; E = gets.to_i
print "File to save >> "; file_name = gets

file = File.open(file_name, 'w')
file.write("#{V} #{E}\n")

history = Array.new

E.times do
  loop do
    source = rand(V) + 1
    destination = rand(V) + 1

    if source != destination && connection_exists(history, source, destination)
      file.write("#{source} #{destination} #{rand(100)}\n")
      history << [source, destination]
      break
    end
  end
end

for i in 1..V
  file.write("r_#{i} #{i} #{rand(1000)} #{rand(600) + 50}\n")
end
