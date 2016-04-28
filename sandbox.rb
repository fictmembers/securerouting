class Edge
  attr_accessor :a, :b, :cost, :feromone
  def initialize(from, to, cost)
    self.a = from.to_i - 1
    self.b = to.to_i - 1
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
    v -= 1  # Normalize vertexes
    t -= 1  # Start from vertex №0

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

    costs = []
    completed_pathes.each do |path|
      costs << paths_cost(path, e)
    end

    return costs, completed_pathes
  end
end


module AntAlgorithm
  def self.get_neighbours( e, vertex , visited )
      neighbours= []
    e.each do |edge|
      neighbours << edge if edge.a == vertex && !visited[edge.b]
      # return edge.b if edge.b == end
    end
    return neighbours
  end

  def self.ant_algorithm(neighbours,visited)
    current_sum = 0
    next_vertex = 0
    probability = Hash.new
    neighbours.each_with_index do |edge|
      current_sum += edge.feromone/edge.cost
    end
    # p = (feromone[current_vertex])/current_sum
    neighbours.each_with_index do |edge|
      probability[edge.b] = edge.feromone/(edge.cost * current_sum )
    end

    chance = rand()
    current_posibility = 0


    probability.each do |key, value|
      current_posibility += value
   if chance <= current_posibility
      next_vertex = value
      break
    end
    end
    visited[next_vertex] = false
    neighbours.each do |vertex|
      return vertex if next_vertex = vertex.b
    end

  end

  def self.update_feromone(e, current_path, cost)
      delta_feromone = 1 + ((3*rand).to_i)/cost
      e.each do |edge|
        edge.feromone+=delta_feromone  if current_path.include?([edge.a,edge.b])
      end
  end

  def self.ant_path_search(number_of_vertex, e, start, end_path)
    puts "Routers: #{number_of_vertex}"
    path = Array.new
    cost = Array.new
    visited = Array.new(number_of_vertex , false)
    visited[start] = false
    current_cost = 0
    current_start = start
    # neighbours = get_neighbours(e, current_start, visited)
    # neighbours.each do |edge|
    #   puts "edge a: #{edge.a+1}, b: #{edge.b+1}"
    # end

    # current_edge = ant_algorithm(neighbours, visited)
    # puts "from: #{current_edge.a}, to: #{current_edge.b} "

    loop do
      neighbours = get_neighbours(e, current_start, visited)
      current_edge = ant_algorithm(neighbours, visited)
      path << [current_edge.a+1,current_edge.b+1]
      current_start = current_edge.b
      current_cost += current_edge.cost
      puts "a: #{current_edge.a}, b: #{current_edge.b}, end: #{end_path}"
      break if current_edge.b == end_path - 1
    end

    update_feromone(e, path, current_cost)


    return path, current_cost

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

  edges.each_with_index do |edge, index|
    puts "#{index + 1}, from (#{edge.a + 1}) to (#{edge.b + 1}) "
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

  costs, ways = WaveAlgorithm.search(e.dup, v.to_i, t.to_i)

  puts "Wave Algorithm"
  ways.each_with_index do |way, index|
    puts "Path #{index} #{way} has cost #{costs[index]}"
  end

  costs, ways = PathFinder.unique_routes(n, e.dup, v.to_i, t.to_i)

  puts "Bellman - Ford Algorithm"
  ways.each_with_index do |way, index|
    puts "Path #{index} #{way} has cost #{costs[index]}"
  end

  way, cost = AntAlgorithm.ant_path_search(m, e.dup, v.to_i - 1, t.to_i - 1)

  puts "ANT Algorithm"
  puts "Path #{way.inspect}, cost: #{cost}"
end
