###                       UNIQUE PATHFINDER PROGRAM                           ##
# Developed to improve routing security in computers network.

# Finds unique routes in non-oriented graph.
# It uses tree different ways to find unique ways:
#  - Modified Bellman-Fords algorithm
#  - Ants algorithm
#  - Custom wave algorithm

# There are two variants of tasks:
# - to find as much way as we can without looking on their costs
# - to find set of unique paths whith have lowest cost
# First two algorithm solve first described task, and third algorith is
# trying to solve second problem.

=begin
module AntAlgorithm
  def self.get_neighbours( e, vertex )
    neighbours= []
    e.each do |edge|
      neighbours << edge if edge.a == vertex
    end
    return neighbours
  end

  def self.ant_algorithm( neighbours , current_vertex ,start, end)
    p = Array.new(neighbours.size)
    neighbours.each_with_index do |edge, i|
      current_sum += feromone[i]/edge.cost
    end
    # p = (feromone[current_vertex])/current_sum
    neighbours.each_with_index do |edge, i|
      p[edge.b] = feromone[i]/(edge.cost * current_sum )
    end

    chance = rand()
    current_posibility = 0
    founded_index = 0

    p.each_with_index do |posibility, i|
      current_posibility += posibility
      if chance <= current_posibility
        puts 'Chance'
      end
    end
  end
end
=end

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
  #   m - number of edges,
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
  # For solving problem only needs to
  # run this function!

  def PathFinder.unique_routes(n, e, v, t)
    set = Array.new             # Set of unique pathes
    path_costs = Array.new      # Path cost
    pathes_available = true     # Not really useful, but describes loop

    while pathes_available
      costs, path = BellmanFord.process(n, e, v, t)

      puts "Path is #{path.join('-')}, cost is #{costs[t - 1]}"

      if path.length <= 1
        pathes_available = false
        break
      else
        #set << {:cost => costs[t - 1], :path => path}
        set << path
        path_costs << costs[t - 1]
        puts "SET IS #{set}"

        if path.length == 2     # If it's diectly connected
          puts "Direct connection! (disable connection)"
          e.delete_if { |edge| (edge.a == v - 1 && edge.b == t - 1) }
          e.delete_if { |edge| (edge.b == v - 1 && edge.a == t - 1) }
        elsif path.length == 3     # If it's connected by one neighbour
          puts "One neighbour connection! (close way to destination)"
          e.delete_if { |edge| (edge.a == path[1] && edge.b == t - 1) }
          e.delete_if { |edge| (edge.b == v - 1 && edge.a == path[1]) }
        else
          PathFinder.cut_edges(e, path)
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

    cost = []
    completed_pathes.each do |path|
      cost << paths_cost(path, e)
    end

    return cost, completed_pathes
  end
end

class Edge

  # Class-wrapper for edge of graph

  # Description of attributes

  # a - Start point of edge
  # b - Finish point of edge
  # cost - Cost of current edge
  # line - Object of drawing

  attr_accessor :a, :b, :cost, :feromone, :line

  def initialize(from, to, cost, app)
    self.a = from.to_i - 1
    self.b = to.to_i - 1
    self.cost = cost.to_i
    self.feromone = 0

    @app = app
  end

  # Draw regular line on the map

  def draw(from, to)
    @app.stroke @app.black
    @line = @app.line from.y + 35, from.x + 16, to.y + 35, to.x + 16            # 35px - is half of image in width and 16px is half of image in height
    @weight = @app.para self.cost
    @weight.move (from.y + to.y + 70) / 2, (from.x + to.x + 32) / 2
  end

  # Highlight the edge

  def highlight(from, to, color)
    @app.stroke color
    @line = @app.line from.y + 35, from.x + 16, to.y + 35, to.x + 16
    @weight = @app.para cost
    @weight.move from.y/2 + to.y/2 + 35, from.x/2 + to.x/2 + 16
  end

  # Hide edge

  def hide
    @line.hide
    @weight.hide
  end

  # Show edge

  def apear
    @line.show
    @weight.show
  end
end

class Router
  attr_accessor :name, :number, :x, :y
  def initialize(name, number, x, y, app)
    self.name   = name
    self.number = number.to_i
    self.x = x.to_i
    self.y = y.to_i

    @app = app
  end

  def draw
    @image = @app.image 'move.gif', :top => self.x, :left => self.y
    @text  = @app.para name
    @text.move self.y, self.x + 40
  end

  def hide
    @image.hide
  end

  def apear
    @image.show
  end
end

class Information

  def initialize(app)
    @app = app
  end

  def draw_graph(connections, routers)
    connections.each do |connect|
      from, to = 0, 0
      routers.each do |router|
        if    router.number == connect.a + 1
          from = router
        elsif router.number == connect.b + 1
          to = router
        end
      end
      connect.draw(from, to)
    end

    routers.each { |router| router.draw }
  end

  def read_file
    file_name = @app.ask_open_file

    connections = Array.new
    routers     = Array.new
    collector   = Array.new

    File.readlines(file_name).each do |line|
      collector << line.chomp.split(/\s+/)
    end

    n, m = collector[0][0].to_i, collector[0][1].to_i
    collector.shift

    for i in 0..m - 1
       connections << Edge.new(collector[i][0], collector[i][1], collector[i][2], @app)
       connections << Edge.new(collector[i][1], collector[i][0], collector[i][2], @app)
    end

    collector.shift(m)

    collector.each do |router|
      routers << Router.new(router[0].to_s, router[1], router[3], router[2], @app)
    end

    draw_graph(connections, routers)

    return connections, routers, file_name
  end

  def draw_set(set_of_unique_routes, connections, routers)
    set_of_unique_routes.each do |path|
      color = rgb(Random.rand(255), Random.rand(255), Random.rand(255))
      for i in 0..path.size - 2
        connections.each do |connection|
          if connection.a == path[i] && connection.b == path[i + 1]
            connection.highlight(routers[path[i]], routers[path[i + 1]], color)
          end
        end
      end
    end
  end

end

Shoes.app do
  initials = Information.new(self)                                              # Initializing of support class
  background white                                                              # Set up main background

  @set_of_unique_routes = []                                                    # Initializing of array for storring unique ways

  # Main toolbox
  flow :width => 1.0 do

    # Open file button
    background rgb(221, 221, 221)
    stack :width => 0.5 do
      flow do
        @button_open_file = button "Open file"
        @opened_file = para " - "
      end
    end

    # Statistics
    stack :width => 0.5 do
      flow do
        para "General: "
        para "connections: "
        @number_of_connections = para "0"
        para "routers: "
        @number_of_routers     = para "0"
      end
    end
  end


  stack :width => 0.7 do
    @button_open_file.click do
      @connections, @routers, file_name = initials.read_file
      @number_of_connections.text = @connections.size
      @number_of_routers.text     = @routers.size
      @opened_file.text           = file_name
    end
  end

  stack :width => 0.3, margin: 10 do
    background white

    flow margin_top: 10 do
      background rgb(221, 221, 221)
      caption "Controls"
      flow do
        para "Start vertex: "
        @start_vertex = edit_line :width => 30
      end

      flow do
        para "Finish vertex: "
        @finish_vertex = edit_line :width => 30
      end

      flow do
        @process_button = button "Search"
        @restore_graph_button = button "Restore"

        # Restoring graph to its first state on the map

        @restore_graph_button.click do
          @connections.each { |connection| connection.hide }
          @result.clear
          initials.draw_graph(@connections, @routers)
        end
      end

      flow margin_top: 10 do
        para "Results"
        @result = stack { para "-" }
      end


      # This button starts proccess of finding unique routes
      @process_button.click do
        # Empty previous results
        @result.clear

        # Check users input
        if @start_vertex.text.to_s.empty? or @finish_vertex.text.to_s.empty?
          alert("Some value is wrong!")
        else
          # If at's ok, prepare map.

          @connections.each { |connection| connection.hide }  # Hide all exiting connections
          connections = @connections.clone                    # Create copy of all connections


          ### There should be a trigger for chosing algorithm


          @costs, @set_of_unique_routes = PathFinder.unique_routes(@routers.size,
                                                          connections,
                                                          @start_vertex.text.to_i,
                                                          @finish_vertex.text.to_i)

=begin
          @costs, @set_of_unique_routes = WaveAlgorithm.search(connections,
                                                          @start_vertex.text.to_i,
                                                          @finish_vertex.text.to_i)
=end

          # If there some solutions - show them
          if !@set_of_unique_routes.empty?
            # Draw solutions on the board
            initials.draw_set(@set_of_unique_routes, @connections, @routers)
            # Show solutions in text form
            @result.append {"Founded results"}
            @set_of_unique_routes.zip(@costs).each do |path, cost|
              @result.append do
                para "Path #{translated_path.join('-')} has cost: #{cost} "
              end
            end
          else
            alert("No paths found!")
          end

        end
      end
    end
  end
end
