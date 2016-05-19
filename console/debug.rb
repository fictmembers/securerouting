class Edge
  attr_accessor :a, :b, :cost, :feromone
  def initialize(from, to, cost)
    self.a = from.to_i
    self.b = to.to_i
    self.cost = cost.to_i
    self.feromone = (3*rand+1).to_i
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

  def BellmanFord.restore_path(d, p, v, t)
    if d[t] == INF
      #print "No path from #{v + 1} to #{t}"
      return []
    else
      path = Array.new    # Path
      cur = t
      while cur != -1
        path << cur
        cur = p[cur]
      end
      return path.reverse
    end
  end

  def BellmanFord.min(a, b)
    a < b ? a : b
  end

  # Bellman's - Ford's Algorithm

  # Simple processing unit that counts
  # costs to all points. If there is
  # no path to point it returns infinity.

  # It takes arguments
  # (
  #   n - number of vertexes,
  #   m - number of edges,
  #   e - list of edges,
  #   v - start vertex,
  #   t - finish vertex
  # )

  def BellmanFord.process(n, e, v, t)
    d = Array.new(n + 1, INF)   # Costs
    p = Array.new(n + 1, -1)    # Parents
    d[v] = 0

    while 1
      any = false
      for j in 0..e.length - 1
        if d[e[j].a] < INF
          if d[e[j].b] > d[e[j].a] + e[j].cost
            d[e[j].b] = d[e[j].a] + e[j].cost
            p[e[j].b] = e[j].a
            any = true
          end
        end
      end
      break if !any
    end
    return d, BellmanFord.restore_path(d, p, v, t)
  end

  def BellmanFord.cut_edges(e, path)
    path.shift
    path.pop

    path.each do |vertex|
      e.delete_if { |edge| (edge.a == vertex || edge.b == vertex) }
    end
  end

  def BellmanFord.search(n, e, v, t)
    set = Array.new             # Set of unique pathes
    path_costs = Array.new      # Path cost
    pathes_available = true     # Not really useful, but describes loop

    while pathes_available
      costs, path = BellmanFord.process(n, e, v, t)

      if path.length <= 1
        pathes_available = false
        break
      else
        set << path
        path_costs << costs[t]

        if path.length == 2     # If it's diectly connected
          e.delete_if { |edge| (edge.a == v && edge.b == t) }
          e.delete_if { |edge| (edge.b == v && edge.a == t) }
        else
          BellmanFord.cut_edges(e, path.dup)
        end
      end
    end
    return path_costs, set
  end
end

module WaveAlgorithm

  # Modified Wave Algorithm

  # Greedy algorithm that tries to
  # finf all pathes in graph and
  # it is doing in the same time

  # Count edges that started from start (s) point in array of edges (e)
  def self.count_edges_whith_starts_from(s, e, u, t)
    founded_edges = []
    e.each do |edge|
      founded_edges << edge.b if edge.a == s && !u.include?(edge.b)
    end
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

  def self.search(e, v, t)
#    v -= 1  # Normalize vertexes
#    t -= 1  # Start from vertex №0

    pathes_available = true # Trigger to exit searching

    completed_pathes = []   # Full pathes from source to destination
    process_pathes = []     # Array of cumulative pathes

    used_vertexes = [v]     # Visited vertexes
    start_vertexes = count_edges_whith_starts_from(v, e, used_vertexes, t)  # Search neighbours to start vertex

    # Start waving from first vertex (v)
    start_vertexes.each do |neighbour|
      # Complete path if there is direct connection
      if neighbour == t
        completed_pathes << [v, neighbour]
      else
        process_pathes << [v, neighbour]
        used_vertexes << neighbour
      end
    end

    while pathes_available
      pathes_available = false if process_pathes.count == 0   # Try to escape
      pathes = process_pathes.dup             # Clone already found pathes to proceed
      process_pathes.clear                    # Clear pathes

      for i in 0..pathes.count - 1            # Iterate throw all first found pathes
                                                # Number of pathes cannot be more than neaighbours of start vertex

        available_connections = []            # Array of arrays with next vertexes for waving
        pathes.each do |path|                   # Search outgoing vertexes for each path
          available_connections << count_edges_whith_starts_from(
                                                path.last, e, used_vertexes, t)
        end

        min, path_index = min_number_of_neighbours(available_connections) # Search for a vertex with less connections

        if min == 0  # If value of connections is 0 - it's the Dead End
          pathes.delete_at(path_index)  # Don't maintain it anymore!
          next
        else
          used_vertexes << pathes[path_index].last # Add current point to control
          new_path_head = available_connections[path_index].first # Get all available sons for current node

          available_connections[path_index].each do |candidate_vertex|
            # Check is next vertex final
            if candidate_vertex == t
              # If yes - override and stop looking at other!
              new_path_head = candidate_vertex
              break
            end

            # Look for the best candiadte
            if (where_edge(pathes[path_index].last, candidate_vertex, e) <
                          where_edge(pathes[path_index].last, new_path_head, e))
              new_path_head = candidate_vertex
            end
          end

          pathes[path_index] << new_path_head # Add founded head to path

          if new_path_head != t
            used_vertexes << new_path_head
            process_pathes << pathes[path_index]
          else
            completed_pathes << pathes[path_index]
          end

          pathes.delete_at(path_index)
        end
      end
    end

    cost = []
    completed_pathes.each do |path|
      cost << paths_cost(path, e)
    end

    completed_pathes.each do |path|
      path.each do |vertex|
        vertex = vertex + 1
      end
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

  return n, m, edges
end

v = 0 # Start point
t = 0 # Destination point
n = 0 # Edges
m = 0 # Points
e = [] # List of edges

puts "==================================="
puts "Finding unique pathes in graph"
puts "-----------------------------------"
puts "Algorithms: Wave alg., Bellman-Ford"
puts "-----------------------------------"
puts "Authors: R. Kaporin | A. Kogulko"
puts "==================================="

loop do
  print "Enter path to file >> "; file_path = gets.chomp!
  n, m, e = read_file(file_path)

  print "Input start end finish point >> "
  v, t = gets.split(/\s+/)

  puts "Routers #{n}, Edges #{m}"
  e.each do |edge|
    puts "Edge (#{edge.a}) -> (#{edge.b})  = cost #{edge.cost}"
  end

  puts "\n=========================================================\n"
  puts "Wave Algorithm"
  costs, ways = WaveAlgorithm.search(e.dup, v.to_i, t.to_i)
  ways.each_with_index do |way, index|
    puts "Path #{index} #{way} has cost #{costs[index]}"
  end
  puts "=========================================================\n"

  puts "\n=========================================================\n"
  puts "Bellman - Ford Algorithm"
  costs, ways = BellmanFord.search(n, e.dup, v.to_i, t.to_i)

  ways.each_with_index do |way, index|
    puts "Path #{index} #{way} has cost #{costs[index]}"
  end
  puts "=========================================================\n"
end