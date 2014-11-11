-- -- -- --  -- -- -- --  -- -- -- --  -- -- -- --
-- GRAND THEFT WUMPUS
-- -- -- --  -- -- -- --  -- -- -- --  -- -- -- --

function love.load()

   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- A few globals that can be changed
   -- -- -- -- -- -- -- -- -- -- -- -- --
   iNUM_NODES 		= 20;		--starting number of nodes
   iNUM_EDGES 		= 30;		--starting number of edges
   iNUM_GLOW_WORMS 	= 3;		--starting number of glow worms
   fCOP_ODDS 		= 0.05;		--(percent) odds of cops along an edge

   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Shake the dice
   -- -- -- -- -- -- -- -- -- -- -- -- --
   math.randomseed(os.time());

   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Load External Files
   -- -- -- -- -- -- -- -- -- -- -- -- --
   require 'utility'
   require 'knowledge'
   require 'graphics'
   love.graphics.setFont(11)

   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Let's begin a new game off the bat
   -- -- -- -- -- -- -- -- -- -- -- -- --
   new_game();
end

function new_game()
   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Build Congestion City
   -- -- -- -- -- -- -- -- -- -- -- -- --
   BUILD_CITY(alCITY);

   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Boolean Flags for Graphics
   -- -- -- -- -- -- -- -- -- -- -- -- --
   bGAME_OVER = false;
   bWUMPUS = false;
   bCOPS = false;
   bGLOW_WORMS = false;
   bWUMPUS_SHOT_MISSED = false;
   bWUMPUS_SHOT_HIT = false;
   bGOD_MODE = false;

   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Selector for Graphics
   -- -- -- -- -- -- -- -- -- -- -- -- --
   iPATH_SELECTOR = 1;

   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Initialize Your Location
   -- -- -- -- -- -- -- -- -- -- -- -- --
   iYOU = find_empty_node();
   aVISITED = {iYOU};

   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Initialize Where You Were
   -- -- -- -- -- -- -- -- -- -- -- -- --
   aPREVIOUS = {"nil", "nil", "nil"};
end

function random_node()
   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Return a random node number
   -- -- -- -- -- -- -- -- -- -- -- -- --
   return math.random(1, iNUM_NODES);
end

function edge_pair(a,b)
   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Generate and return an edge between random nodes
   -- -- -- -- -- -- -- -- -- -- -- -- --
   if not (a == b) then return { {a,b}, {b,a} }; else return edge_pair(random_node(), random_node()); end
end

function make_edge_list()
   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Generate and return a list of edges
   -- -- -- -- -- -- -- -- -- -- -- -- --
   local tbl = {};
   for i=1, iNUM_EDGES do
      local edge = edge_pair(random_node(), random_node());
      for j=1,2 do table.insert(tbl, edge[j]); end
   end
   return tbl;
end

function make_city_edges()
   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Build Adjacency list of city edges
   -- -- -- -- -- -- -- -- -- -- -- -- --
   local alist = {};
   local nodes = {};
   local edge_list = {};

   --city nodes
   for i = 1, iNUM_NODES do nodes[i] = i; end

   --build the city
   edge_list = connect_all_islands(nodes, make_edge_list());

   --convert list to alist and add the cops
   alist = edges_to_alist(edge_list);

   --the regular edge list
   elCITY = edge_list;

   return alist;
end

function edges_to_alist(edge_list)
   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Convert from edge list to adjacency list
   -- -- -- -- -- -- -- -- -- -- -- -- --
   local nodes = {};
   local alist = {};

   --strip nodes from edge_list
   for i,v in ipairs (edge_list) do table.insert(nodes, v[1]); end

   --remove duplicates
   nodes = remove_duplicates(nodes);

   --for each unique node, investigate the direct edges of it
   for i,v in ipairs(nodes) do
      --investigate direct edges of this node
      local edge_neighbors = incident_edges(v, edge_list);

	  --build nested alist of the neighboring nodes
	  local sub_alist = {};
	  table.insert(sub_alist, v);
	  for i2,v2 in ipairs(edge_neighbors) do
	     table.insert(sub_alist, v2[2]);
	  end

	  --add nested sub_alist to the alist
	  table.insert(alist, sub_alist);
   end

   return alist;
end

function generate_unused_name()
   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Naming stuff
   -- -- -- -- -- -- -- -- -- -- -- -- --
   local r = 0;
   repeat
      r = math.random(#NODE_NAMES_DICTIONARY);
   until (count(NODE_NAMES, NODE_NAMES_DICTIONARY[r]) == 0);

   return NODE_NAMES_DICTIONARY[r];
end

function BUILD_CITY(edges_alist)

   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Generate Adjacency List (and Edge List) of City
   -- -- -- -- -- -- -- -- -- -- -- -- --
   alCITY = make_city_edges();

   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Colors and Name stuff
   -- -- -- -- -- -- -- -- -- -- -- -- --
   NODE_NAMES = {};
   NODE_COLORS = {};

   for i=1,iNUM_NODES do
      --if (i <= #NODE_NAMES_DICTIONARY) then
	     NODE_NAMES[i] = generate_unused_name();
		 NODE_COLORS[i] = {math.random(255), math.random(255), math.random(255), 255};
	  --end
   end

   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Generate and Install Cops
   -- -- -- -- -- -- -- -- -- -- -- -- --
   local function cop_criteria(x) return not (math.random(100) < (fCOP_ODDS*100)); end
   elCOPS = remove_if(elCITY, cop_criteria);
   elCOPS = remove_double_edges(elCOPS);

   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Install Sirens
   -- -- -- -- -- -- -- -- -- -- -- -- --
   aSIRENS = {};

   --loop over the cop edges
   for i,v in ipairs(elCOPS) do
	  table.insert(aSIRENS, v[1]);
	  table.insert(aSIRENS, v[2]);
   end

   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Install Glow Worms
   -- -- -- -- -- -- -- -- -- -- -- -- --
   aGLOW_WORMS = {};
   for i=1,iNUM_GLOW_WORMS do
      table.insert(aGLOW_WORMS, random_node());
   end

   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Install Glow Worm Lights
   -- -- -- -- -- -- -- -- -- -- -- -- --
   aLIGHTS = {};
   for i,v in ipairs(aGLOW_WORMS) do
      for i2,v2 in ipairs(alCITY[find_index_alist_node(alCITY, v)]) do
	     if (i2 > 1) then table.insert(aLIGHTS, v2); end
	  end
   end

   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Install the Wumpus
   -- -- -- -- -- -- -- -- -- -- -- -- --
   repeat
      iWUMPUS = random_node();
   until (count(aGLOW_WORMS, iWUMPUS) == 0)

   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Install Blood
   -- -- -- -- -- -- -- -- -- -- -- -- --
   aBLOOD = {};
   for i,v in ipairs(alCITY[find_index_alist_node(alCITY, iWUMPUS)]) do
	     if (i > 1) then
		    table.insert(aBLOOD, v);
			for i2,v2 in ipairs(alCITY[find_index_alist_node(alCITY, v)]) do
			   if (i2 > 1) then table.insert(aBLOOD, v2); end
			end
		 end
   end

end

function find_empty_node()
   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Find a random node with nothing on it
   -- -- -- -- -- -- -- -- -- -- -- -- --
   local x;
   repeat
      x = random_node();
   until (iWUMPUS ~= x) and (count(aGLOW_WORMS, x) == 0)
   return x;
end


-- -- -- -- -- -- -- -- -- -- -- -- --
-- Variety of Testers
-- -- -- -- -- -- -- -- -- -- -- -- --
function wumpus_here(node)
   return (iWUMPUS == node);
end

function glow_worms_here(node)
   return (count(aGLOW_WORMS, node) > 0);
end

function cops_between(node1, node2)
   return (edge_count(elCOPS, edge_pair(node1, node2)) > 0) or
           (edge_count(elCOPS, edge_pair(node2, node1)) > 0);
end

function blood_here(node)
   return (count(aBLOOD, node) > 0);
end

function lights_here(node)
   return (count(aLIGHTS, node) > 0);
end

function sirens_here(node)
   return (count(aSIRENS, node) > 0);
end
-- -- -- -- -- -- -- -- -- -- -- -- --

function handle_new_place()
   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Handle going to a new place
   -- -- -- -- -- -- -- -- -- -- -- -- --

   --bad news if run into the wumpus
   if wumpus_here(iYOU) then
	  bWUMPUS = true;
	  bGAME_OVER = true;
   end

   --wake up in strange area if caught by glow worms
   if glow_worms_here(iYOU) then
	  bGLOW_WORMS = true;
	  iYOU = find_empty_node();
   end

   --bad news if you run into cops
   if not(iYOU == aPREVIOUS[1]) and cops_between(iYOU, aPREVIOUS[1]) then
	  bCOPS = true;
	  bGAME_OVER = true;
   end
end

function get_selected_node()
   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Get the node by selector
   -- -- -- -- -- -- -- -- -- -- -- -- --
   return alCITY[find_index_alist_node(alCITY, iYOU)][iPATH_SELECTOR+1];
end

function charge()
   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Shoot your gun!
   -- -- -- -- -- -- -- -- -- -- -- -- --

   --get the node you chose to shoot in
   local selected = get_selected_node();

   --compare: did you hit the wumpus?
   if (selected == iWUMPUS) then
	  bWUMPUS_SHOT_HIT = true;
   else
	  bWUMPUS_SHOT_MISSED = true;
   end

   return true;
end

function move()
   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Move in direction of selector
   -- -- -- -- -- -- -- -- -- -- -- -- --

   --unset flag if you moved
   bGLOW_WORMS = false;

   --add to previous list
   table.insert(aPREVIOUS, 1, iYOU);

   --change your location to new place
   iYOU = get_selected_node();

   --add new place to visited list
   table.insert(aVISITED, 1, iYOU);

   --reset path selector
   iPATH_SELECTOR = 1;

   --handle the new place (check for stuff)
   handle_new_place();
end

function increment_path_selector()
   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Change where you want to go
   -- -- -- -- -- -- -- -- -- -- -- -- --
   iPATH_SELECTOR = iPATH_SELECTOR + 1;
   if (iPATH_SELECTOR > get_number_of_adjacent_nodes(alCITY, iYOU)) then
		iPATH_SELECTOR = 1;
   end
end

function decrement_path_selector()
   -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Change where you want to go
   -- -- -- -- -- -- -- -- -- -- -- -- --
   iPATH_SELECTOR = iPATH_SELECTOR - 1;
   if (iPATH_SELECTOR < 1) then
      iPATH_SELECTOR = get_number_of_adjacent_nodes(alCITY, iYOU);
   end
end

function love.keypressed(key, unicode)

   if not (bGAME_OVER) then

	  --moving the selector
      if key == 'left' or key == 'up' then
         decrement_path_selector();
      end

	  --moving the selector
      if key == 'right' or key == 'down' then
         increment_path_selector();
      end

	  --go in selected direction
      if key =='return' then
		 move();
      end

	  --shoot your gun
      if key == 's' or key == 'S' then
         bGAME_OVER = charge();
      end
   end

   --begin a new game
   if key == 'p' or key == 'P' then
      new_game();
   end

   --(easter egg) take a mulligan, restart location in same city
   if key == 'm' or key == 'M' then
      iPATH_SELECTOR = 1;
      iYOU = find_empty_node();
	  bGAME_OVER = false;
      bWUMPUS = false;
      bCOPS = false;
      bGLOW_WORMS = false;
      bWUMPUS_SHOT_HIT = false;
      bWUMPUS_SHOT_MISSED = false;
   end

   --quit and exit
   if key == 'q' or key == 'Q' then
      os.exit();
   end

   if key == 'g' or key == 'G' then
      bGOD_MODE = not(bGOD_MODE);
   end
end



-- Agent Activities!
--
--
-- -- -- changing where to go (picking neighbors)
-- increment_path_selector()
-- decrement_path_selector()
--
-- -- -- move in direction of selector
-- move()
-- handle_new_place()
--
-- -- -- shooting in direction of selector
-- charge()
--
-- -- -- testing nodes for stuff
-- cops_between(a, b)
-- wumpus_here(a)
-- glow_worms_here(a)
-- blood_here(a)
-- sirens_here(a)
-- lights_here(a)
--
-- -- --

