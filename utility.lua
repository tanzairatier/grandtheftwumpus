-- -- -- -- -- -- -- -- -- --
-- Utility Type Functions
-- -- -- -- -- -- -- -- -- --

function remove_if(t, criteria_fn)
   --start from empty and add those that do not meet criteria
   local t2= {};
   for i,v in ipairs(t) do if not (criteria_fn(v)) then table.insert(t2,v) end end
   return t2;
end

function lisp_mapc(func, list)
   --the mapc function from lisp coded up in lua
   for i,v in ipairs(list) do func(v); end
end

function is_empty(list)
   return (list == nil) or (#list == 0);
end

function count(list, item)
   --Count number of matching items in this list
   local cnt = 0;
   for k = 1, #list do
      if (list[k] == item) then cnt = cnt + 1; end
   end
   return cnt;
end

function set_difference(set_A, set_B)
   --get the "set difference" between two lists of items
   --reports items in A that aren't in B

   local function is_not_in_set_B(item)
      for i,v in ipairs(set_B) do
	     if (v == item) then return false end;
	  end
      return true;
   end

   local difference = {};
   for i,v in ipairs(set_A) do
      if is_not_in_set_B(v) then table.insert(difference, v); end
   end
   return difference;
end

--tail returns lisp-style tail of a list
function tail(t) table.remove(t, 1); return t; end

function edge_count(list, edge)
   --count function for edges
   local cnt = 0;
   for i,v in ipairs(list) do
      if ((v[1] == edge[1][1]) and (v[2] == edge[2][1])) then cnt = cnt + 1; end
   end
   return cnt;
end

function remove_double_edges(edge_list)
   --remove doubly occuring edges
   local new_list = {};
   for i,v in ipairs(edge_list) do
      local first = v[1];
	  local second = v[2];
	  if ((edge_count(new_list, edge_pair(first,second)) < 1) and
           edge_count(new_list, edge_pair(second,first)) < 1) then table.insert(new_list, v); end
   end

   return new_list;
end

function find_index_alist_node(alist, node)
   --return the index containing this node in alist
   for i,v in ipairs(alist) do
      if (v[1] == node) then return i; end
   end
   return nil; --not found
end

function find_index_adj_node(alist, node, alist_node_index)
   --return the index of node adjacenct to this alist_node
   for i,v in ipairs(alist[alist_node_index]) do
	  if (i > 1 and v[1] == node) then return i; end
   end
end

function remove_duplicates(list)
   local new_list = {};

   for i,v in ipairs(list) do
      if (count(new_list, v) < 1) then table.insert(new_list, v); end
   end

   return new_list;
end
function within_one(alist, alist_node, query)

   --find the index of this alist_node
   alist_node_index = find_index_alist_node(alist, alist_node);

   --checks
   for i,v in ipairs(alist[alist_node_index]) do
      if (i > 1) then
	     for i2,v2 in ipairs(v) do
		    if (v2 == query) then return true; end
	     end
	  end
   end

   return false;
end

function incident_edges(node, edge_list)
   --find all edges incident on this node
   local function criteria(x) return not(x[1] == node); end

   local inc_edges = {};
   inc_edges = remove_if(edge_list, criteria);
   return inc_edges;
end

function get_connected_component(node, edge_list)
   --return the connected component containing this node
   --returns a list of nodes in that connected component
   local visited = {};

   local function traverse(node)
      --criteria function for remove_if
      local function already_visited(n) return (count(visited, n) > 0); end

      local inc_edges = {};
	  local neighbor_nodes = {};

      --check neighbors of node
      inc_edges = incident_edges(node, edge_list);

	  --strip out the end node in each neighboring edge
	  for i,v in ipairs (inc_edges) do neighbor_nodes[i] = v[2]; end

      --remove already visited neigbors
      neighbor_nodes = remove_if(neighbor_nodes, already_visited);

      --add this node to visited
      if not already_visited(node) then table.insert(visited, node); end

	  --traverse neighbors
      lisp_mapc(traverse, neighbor_nodes);
   end

   --traverse
   traverse(node);

   --return
   return visited;
end

function find_islands(nodes, edge_list)
   --finds disconnected components in edge_list

   local islands = {};

   local function find_island(nodes)
      --investigates these nodes and reports any islands
	  connected = get_connected_component(nodes[1], edge_list);
	  unconnected = set_difference(nodes, connected);

	  --push the connected portion into list
	  table.insert(islands, connected);

	  --recurse using unconnected stuff
	  if not is_empty(unconnected) then find_island(unconnected);	end
   end

   --find islands
   find_island(nodes);

   --return list of islands
   return islands;
end

function build_bridges(islands)
   --return a list of needed bridges to connect all islands (components)

   local bridges = {};

   local function make_bridges(islands)
      if (#islands > 1) then
         table.insert(bridges, edge_pair(islands[1][#islands[1]], islands[2][1]));
	     make_bridges(tail(islands));
      end
   end

   --make bridges
   make_bridges(islands);

   --return bridges
   return bridges;

end

function connect_all_islands(nodes, edge_list)
   --use bridges to connect islands and add them to the edge_list

   --find islands
   islands = find_islands(nodes, edge_list);

   --build bridges
   bridges = build_bridges(islands);

   --add bridges to city
   for i,v in ipairs(bridges) do
      table.insert(edge_list, v[1]); table.insert(edge_list, v[2]);
   end

   return edge_list;
end

function get_number_of_adjacent_nodes(alist, node)
   return (#alist[find_index_alist_node(alist, node)] - 1);
end
-- -- -- -- -- -- -- --
