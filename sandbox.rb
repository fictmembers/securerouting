class Edge
  attr_accessor :a, :b, :cost
  def initialize(from, to, cost)
    self.a = from.to_i - 1
    self.b = to.to_i - 1
    self.cost = cost.to_i
  end
end

module BellmanFord
  INF = Float::INFINITY

  # Bellman's - Ford's Algorithm path recover

  # It takes arguments
  # (
  #   d - array of costs for vertex v
  #   p - array of parrents
  #   v - start vertex,
  #   t - finish vertex
  # )

  def self.restore_path(d, p, _v, t)
    if d[t] == INF
      # print "No path from #{v + 1} to #{t}"
      return []
    else
      path = [] # Path
      cur = t - 1
      while cur != -1
        path << cur
        cur = p[cur]
      end
      return path.reverse
    end
  end

  def self.min(a, b)
    a < b ? a : b
  end

  # Bellman's - Ford's Algorithm

  # Simple processing unit that counts
  # costs to all points. If there is
  # no path to point it returns infinity.

  # It takes arguments
  # (
  #   n - number of vertexes,
  #   e - list of edges,
  #   v - start vertex,
  #   t - finish vertex
  # )

  def self.process(n, e, v, t)
    d = Array.new(n, INF)   # Costs
    p = Array.new(n, -1)    # Parents
    d[v - 1] = 0

    loop do
      any = false
      for j in 0..e.length - 1
        next unless d[e[j].a] < INF
        next unless d[e[j].b] > d[e[j].a] + e[j].cost
        d[e[j].b] = d[e[j].a] + e[j].cost
        p[e[j].b] = e[j].a
        any = true
      end
      break unless any
    end
    [d, BellmanFord.restore_path(d, p, v, t)]
  end
end

module PathFinder
  # Module for finding unique pathes in graph
  INF = Float::INFINITY

  # Edge eraser - kills used edges
  # (
  #   e - list of edges
  #   path - finded path
  # )
  def self.cut_edges(e, path)
    for i in 1..path.length - 3
      e.delete_if { |edge| (edge.a == path[i] && edge.b == path[i + 1]) }
      e.delete_if { |edge| (edge.a == path[i + 1] && edge.b == path[i]) }
    end
  end

  # Unique routes - Main function

  # This function finds all uniques ways
  # betwean to points (from v to t)
  # To solve problem only needs to
  # run this function!

  def self.unique_routes(n, e, v, t)
    set = [] # Set of unique pathes
    pathes_available = true     # Not really useful, but describes loop

    while pathes_available
      costs, path = BellmanFord.process(n, e, v, t)

      puts "Path is #{path.join('-')}, cost is #{costs[t - 1]}"

      if path.length <= 1
        pathes_available = false
        break
      else
        set << { cost: costs[t - 1], path: path }

        puts "SET IS #{set}"

        if path.length == 2     # If it's diectly connected
          puts 'Direct connection! (disable connection)'
          e.delete_if { |edge| (edge.a == v - 1 && edge.b == t - 1) }
          e.delete_if { |edge| (edge.b == v - 1 && edge.a == t - 1) }
        elsif path.length == 3 # If it's connected by one neighbour
          puts 'One neighbour connection! (closest way to destination)'
          e.delete_if { |edge| (edge.a == path[1] && edge.b == t - 1) }
          e.delete_if { |edge| (edge.b == v - 1 && edge.a == path[1]) }
        else
          PathFinder.cut_edges(e, path)
        end
      end
    end
    set
  end
end

module WaveAlgorithm
  # Count edges that started from start (s) point in array of edges (e)
  def self.count_edges_whith_starts_from(s, e, u, t)
    founded_edges = []
    e.each do |edge|
      founded_edges << edge.b if edge.a == s && !u.include?(edge.b)
    end

    # Check are there any daed ends in next hops

    # Final vertex IS NOT dead end, so skip it
    # New vertexes MUST have another connection.
    # No back connection to start vertex, and it's MUSTN't be used vertex



    founded_edges
  end

  # Get cost of edge where a -start and b - end
  def self.where_edge(a, b, e)
    e.each do |edge|
      return edge.cost if edge.a == a && edge.b == b
    end
  end

  # Get cost of edge where a -start and b - end
  def self.is_edge_exists(a, b, e)
    e.each do |edge|
      return true if edge.a == a && edge.b == b
    end
  end

  # Get cost of current path
  def self.paths_cost(path, e)
    cost = 0
    for i in 0..path.count - 2
      cost += WaveAlgorithm.where_edge(path[i], path[i + 1], e)
    end
    cost
  end

  # Look for a vertex with smallest number of outgoing connections
  def self.min_number_of_neighbours(available_connections)
    min = available_connections.first.count
    path_index = 0

    available_connections.each_with_index do |next_vertexes, index|
      if next_vertexes.count < min
        min = next_vertexes.count
        path_index = index
      end
    end
    return min, path_index
  end

  def self.search(n, m, e, v, t)
    v -= 1                                                                      # Normalize vertexes
    t -= 1                                                                      # Start from vertex №0

    pathes_available = true
    completed_pathes = []

    used_vertexes = [v]                                                         # Visited vertexes
    start_vertexes = WaveAlgorithm.count_edges_whith_starts_from(v, e, used_vertexes, t)  # Search neighbours to start vertex

    process_pathes = []
    start_vertexes.each do |neighbour|
      process_pathes << [v, neighbour]
      used_vertexes << neighbour
    end

    while pathes_available
      pathes = process_pathes.dup
      process_pathes.clear

      for i in 0..pathes.count - 1                                              # Iterate throw all first found pathes
        available_connections = []

        pathes.each do |path|                                                   # Search outgoing vertexes for each path
          available_connections << WaveAlgorithm.count_edges_whith_starts_from(path.last, e, used_vertexes, t)
        end

        puts "available_connections = #{available_connections}"
        a = gets

        min, path_index = WaveAlgorithm.min_number_of_neighbours(available_connections)

        puts "Calculate for path #{path_index} -  #{pathes[path_index]}. Number of outgoing edges is #{min}"

        if min == 0
          puts "Path #{pathes[path_index]} killed cause it had dead end!"
          pathes.delete_at(path_index)
          next
        else
          used_vertexes << pathes[path_index].last
          puts "Vertex (#{pathes[path_index].last}) is looking for a neighbour from #{available_connections[path_index]}"
          new_path_head = available_connections[path_index].first

          # What is going on:
          # => Find smallest path from founded vertexes

          available_connections[path_index].each do |candidate_vertex|
            puts "(#{pathes[path_index].last}) Candidate: (#{candidate_vertex}), Head: (#{new_path_head})"
            if self.where_edge(pathes[path_index].last, candidate_vertex, e) < self.where_edge(pathes[path_index].last, new_path_head, e)
              puts "Checked"
              new_path_head = candidate_vertex
            end
          end

          # => Add to path
          pathes[path_index] << new_path_head
          puts "New path is #{pathes[path_index]}"

          if new_path_head != t
            # => Mark as visited
            used_vertexes << new_path_head
            puts "Used vertexes are #{used_vertexes}"
            process_pathes << pathes[path_index] if min != 0
          else
            # => Check is this vertex is final
            completed_pathes << pathes[path_index]
            puts "Complete path found!"
          end

          pathes.delete_at(path_index)
        end

        pathes_available = false if process_pathes.count == 0
      end

      process_pathes.each do |path|
        puts "Cost of #{path} is: #{WaveAlgorithm.paths_cost(path, e)}"
      end
    end

    cost = []
    completed_pathes.each do |path|
      cost << WaveAlgorithm.paths_cost(path, e)
    end

    return cost, completed_pathes
  end
end

def read_file(file_name)
  edges = []
  collector = []

  File.readlines(file_name).each do |line|
    collector << line.chomp.split(/\s+/)
  end

  n = collector[0][0].to_i
  m = collector[0][1].to_i
  collector.shift

  collector.each do |edge|
    edges << Edge.new(edge[0], edge[1], edge[2])
    edges << Edge.new(edge[1], edge[0], edge[2])
  end

  puts "Number of edges #{edges.count}"
  edges.each do |edge|
    puts "Edge: #{edge.a + 1} - #{edge.b + 1}: #{edge.cost}"
  end

  return n, m, edges
end

v = 0 # Start point
t = 0 # Destination point
n = 0 # Edges
m = 0 # Points
e = [] # List of edges

loop do
  puts 'Input start end finish point '
  v, t = gets.split(/\s+/)

  n, m, e = read_file('input_simple.txt')

  costs, ways = WaveAlgorithm.search(n, m, e, v.to_i, t.to_i)

  costs.each_with_index do |cost, index|
    puts "Path #{index}: #{ways[index]}, cost: #{cost}"
  end
end
