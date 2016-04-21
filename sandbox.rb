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

  def BellmanFord.restore_path(d, p, v, t)
    if d[t] == INF
      #print "No path from #{v + 1} to #{t}"
      return []
    else
      path = Array.new    # Path
      cur = t - 1
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
  #   e - list of edges,
  #   v - start vertex,
  #   t - finish vertex
  # )

  def BellmanFord.process(n, e, v, t)
    d = Array.new(n, INF)   # Costs
    p = Array.new(n, -1)    # Parents
    d[v - 1] = 0

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
end

module PathFinder
  # Module for finding unique pathes in graph
  INF = Float::INFINITY

  # Edge eraser - kills used edges
  # (
  #   e - list of edges
  #   path - finded path
  # )
  def PathFinder.cut_edges(e, path)
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

  def PathFinder.unique_routes(n, e, v, t)
    set = Array.new             # Set of unique pathes
    pathes_available = true     # Not really useful, but describes loop

    while pathes_available
      costs, path = BellmanFord.process(n, e, v, t)

      puts "Path is #{path.join('-')}, cost is #{costs[t - 1]}"

      if path.length <= 1
        pathes_available = false
        break
      else
        set << {:cost => costs[t - 1], :path => path}

        puts "SET IS #{set}"

        if path.length == 2     # If it's diectly connected
          puts "Direct connection! (disable connection)"
          e.delete_if { |edge| (edge.a == v - 1 && edge.b == t - 1) }
          e.delete_if { |edge| (edge.b == v - 1 && edge.a == t - 1) }
        elsif path.length == 3     # If it's connected by one neighbour
          puts "One neighbour connection! (closest way to destination)"
          e.delete_if { |edge| (edge.a == path[1] && edge.b == t - 1) }
          e.delete_if { |edge| (edge.b == v - 1 && edge.a == path[1]) }
        else
          PathFinder.cut_edges(e, path)
        end
      end
    end
    return set
  end
end

module WaveAlgorithm

  # Count edges that started from start (s) point in array of edges (e)
  def WaveAlgorithm.count_edges_with_start(s, e)
    counter = 0
    e.each do |edge|
      counter += 1 if edge.a == s
    end
    return counter
  end

  def WaveAlgorithm.search(n, e, v, t)
    v -= 1                                                                      # Normalize vertexes
    t -= 1                                                                      # Start from vertex №0
    for i in 0..n - 1
      puts "From #{i + 1} there is/are #{WaveAlgorithm.count_edges_with_start(i, e)}"
    end
  end
end

def read_file(file_name)
  edges = Array.new
  collector = Array.new

  File.readlines(file_name).each do |line|
    collector << line.chomp.split(/\s+/)
  end

  n, m = collector[0][0].to_i, collector[0][1].to_i
  collector.shift

  collector.each do |edge|
    edges << Edge.new(edge[0], edge[1], edge[2])
  end

  return n, m, edges
end

v = 0 # Start point
t = 0 # Destination point
n = 0 # Edges
m = 0 # Points
e = []  # List of edges


while true
  puts "Input start end finish point "
  v, t = gets.split(/\s+/)

  n, m, e = read_file('input.txt')

  WaveAlgorithm.search(n, e, v.to_i, t.to_i)

  set_of_unique_routes = PathFinder.unique_routes(n, e, v.to_i, t.to_i)

  set_of_unique_routes.each do |route|
    puts "PATH FOUND [#{route}]"
  end
end
