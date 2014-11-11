function love.draw()

   local iNODE_WIDTH = 20;
   local iNODE_HEIGHT = 20;
   local iCIRCLE_RADIUS = 250;

   local positions = {};

   --center of the circle
   local center = {x = (love.graphics.getWidth())*0.50, y = (love.graphics.getHeight())*0.50};

   local function connect(n1, n2)
      love.graphics.line(positions[n1][1]+(iNODE_WIDTH*0.50), positions[n1][2]+(iNODE_HEIGHT*0.50), positions[n2][1]+(iNODE_WIDTH*0.50), positions[n2][2]+(iNODE_HEIGHT*0.50));
   end

   -- -- -- -- -- -- -- -- -- --
   -- Draw The Entire Map - in a Circle
   -- -- -- -- -- -- -- -- -- --
   local degrees = -90;


   for i=1,#alCITY do
      --draw at degrees-along circle
	  local rad = (degrees*math.pi)/180;
	  local x = center.x + iCIRCLE_RADIUS*math.cos(rad) - iNODE_WIDTH*0.50;
	  local y = center.y + iCIRCLE_RADIUS*math.sin(rad) - iNODE_HEIGHT*0.50;

	  --store its position for later
	  table.insert(positions, {x, y});

	  --draw the node
	  love.graphics.setColor(255, 255, 255, 255);
	  love.graphics.rectangle('fill', x, y, iNODE_WIDTH, iNODE_HEIGHT);
	  love.graphics.setColor(unpack(NODE_COLORS[alCITY[i][1]]));
	  love.graphics.setLineWidth(2);
	  love.graphics.rectangle('line', x, y, iNODE_WIDTH, iNODE_HEIGHT);
	  love.graphics.setLineWidth(1);

	  --draw node number
	  love.graphics.setColor(0, 0, 0, 255);
	  love.graphics.print(alCITY[i][1], x, y);

	  --increment degrees
	  degrees = degrees + (360/#alCITY);
   end

   --draw the edges between nodes
   --you either see them all (god mode) or only those you can cross or have visited

   -- -- -- -- -- -- -- -- -- --
   -- Draw Edges between Nodes
   -- -- -- -- -- -- -- -- -- --

   --determine the previous three visited nodes
   local previous_three = {};
   for i=1, 3 do
      table.insert(previous_three, aVISITED[i]);
   end

   love.graphics.setColor(255, 255, 255, 255);
   for i,v in ipairs(alCITY) do
      local left_node = v[1];

	  --you can only see edges if they're in local memory
	  --or if you are in god mode, and can see everything
	  if (count(previous_three, left_node) > 0) or (bGOD_MODE) then
         for i=2,#v do
   	        local right_node = v[i];
	        --love.graphics.setColor(unpack(NODE_COLORS[right_node]));
			if not (left_node == iYOU) then
	           love.graphics.setLineStipple(0x1111, 1);
			   love.graphics.setLineWidth(1);
			else
	           love.graphics.setLineStipple(0xFFFF, 1);
			   love.graphics.setLineWidth(2);
			end
			connect(left_node, right_node);
	     end
      end
   end
   love.graphics.setLineStipple(0xFFFF, 1);
   love.graphics.setLineWidth(1);

   -- -- -- -- -- -- -- -- -- --
   -- Draw Indicator-Line for Selector
   -- -- -- -- -- -- -- -- -- --
   love.graphics.setColor(255, 255, 0, 255);
   local x = positions[iYOU][1]-4;
   local y = positions[iYOU][2]-4;
   love.graphics.rectangle('line', x, y, iNODE_WIDTH+8, iNODE_HEIGHT+8);

   -- -- -- -- -- -- -- -- -- --
   -- Draw Selector
   -- -- -- -- -- -- -- -- -- --
   love.graphics.setColor(255, 0, 0, 255);
   local selected = get_selected_node();
   local x = positions[selected][1];
   local y = positions[selected][2];
   love.graphics.setLineWidth(3);
   love.graphics.rectangle('line', x-4, y-4, iNODE_WIDTH+8, iNODE_HEIGHT+8);
   love.graphics.line(x+(iNODE_WIDTH*0.50), y+(iNODE_HEIGHT*0.50), positions[iYOU][1]+(iNODE_WIDTH*0.50), positions[iYOU][2]+(iNODE_HEIGHT*0.50));
   love.graphics.setLineWidth(1);
   love.graphics.setColor(0, 0, 0, 255);
   love.graphics.line(x+(iNODE_WIDTH*0.50), y+(iNODE_HEIGHT*0.50), positions[iYOU][1]+(iNODE_WIDTH*0.50), positions[iYOU][2]+(iNODE_HEIGHT*0.50));

   -- -- -- -- -- -- -- -- -- -- --
   -- Where you are
   -- -- -- -- -- -- -- -- -- -- --
   love.graphics.setColor(255, 255, 255, 255);
   local rect = {love.graphics.getWidth()*0.01, love.graphics.getHeight()*0.01, love.graphics.getWidth()*0.34, love.graphics.getHeight()*0.08};
   love.graphics.setColor(unpack(NODE_COLORS[iYOU]));
   love.graphics.rectangle('line', rect[1], rect[2], rect[3], rect[4]);
   love.graphics.setColor(255, 255, 255, 255);
   love.graphics.print("You are here:", rect[1], rect[2]);
   love.graphics.printf(NODE_NAMES[iYOU], rect[1], rect[2]+love.graphics.getHeight()*0.04, rect[3], "center");

   -- -- -- -- -- -- -- -- -- -- --
   -- Legend
   -- -- -- -- -- -- -- -- -- -- --
   love.graphics.setColor(255, 255, 255, 255);
   local rect = {love.graphics.getWidth()*0.80, love.graphics.getHeight()*0.01, love.graphics.getWidth()*0.34, love.graphics.getHeight()*0.14};
   --love.graphics.rectangle('line', rect[1], rect[2], rect[3], rect[4]);
   love.graphics.print("Legend", rect[1], rect[2]);
   love.graphics.print("- Your Position", rect[1]+iNODE_WIDTH*1.2+30, rect[2]+love.graphics.getHeight()*0.03);
   love.graphics.print("- The Selector", rect[1]+iNODE_WIDTH*1.2+30, rect[2]+love.graphics.getHeight()*0.06);
   love.graphics.print("- The path chosen", rect[1]+iNODE_WIDTH*1.2+30, rect[2]+love.graphics.getHeight()*0.09);

   love.graphics.setColor(255, 255, 0, 255);
   love.graphics.rectangle('line', rect[1]+3+30, rect[2]+love.graphics.getHeight()*0.03, iNODE_WIDTH, iNODE_HEIGHT);
   love.graphics.setColor(255, 0, 0, 255);
   love.graphics.rectangle('line', rect[1]+3+30, rect[2]+love.graphics.getHeight()*0.06, iNODE_WIDTH, iNODE_HEIGHT);
   love.graphics.setColor(255, 0, 0, 255);
   love.graphics.line(rect[1]+3+30, rect[2]+love.graphics.getHeight()*0.105, rect[1]+iNODE_WIDTH+30, rect[2]+love.graphics.getHeight()*0.105);

   -- -- -- -- -- -- -- -- -- -- --
   -- Clues
   -- -- -- -- -- -- -- -- -- -- --
   love.graphics.setColor(255, 255, 255, 255);
   local rect = {love.graphics.getWidth()*0.01, love.graphics.getHeight()*0.25, love.graphics.getWidth()*0.34, love.graphics.getHeight()*0.14};
   --love.graphics.rectangle('line', rect[1], rect[2], rect[3], rect[4]);
   love.graphics.print("Clues", rect[1], rect[2]);
   if (sirens_here(iYOU)) then
      love.graphics.setColor(30, 0, 255, 255);
      love.graphics.print("You hear sirens...", rect[1]+30, rect[2]+love.graphics.getHeight()*0.02);
   end
   if (lights_here(iYOU)) then
      love.graphics.setColor(255, 255, 0, 255);
      love.graphics.print("You see lights...", rect[1]+30, rect[2]+love.graphics.getHeight()*0.04);
   end
   if (blood_here(iYOU)) then
      love.graphics.setColor(255, 30, 0, 255);
      love.graphics.print("You smell blood...", rect[1]+30, rect[2]+love.graphics.getHeight()*0.06);
   end

   -- -- -- -- -- -- -- -- -- -- --
   -- Game instructions
   -- -- -- -- -- -- -- -- -- -- --
   love.graphics.setColor(255, 255, 255, 255);
   local rect = {love.graphics.getWidth()*0.75, love.graphics.getHeight()*0.85, love.graphics.getWidth()*0.34, love.graphics.getHeight()*0.14};
   --love.graphics.rectangle('line', rect[1], rect[2], rect[3], rect[4]);
   love.graphics.print("Instructions and Keys", rect[1], rect[2]);

   --define strings
   local strings = {};
   strings["how to move"] = "Arrow Keys & Enter to move";
   strings["how to shoot"] = "(S)hoot!";
   strings["new game"] = "(P)lay New Game";
   strings["mulligan"] = "(M)ulligan";
   strings["quit"] = "(Q)uit";

   --print strings
   local cnt = 0;
   for i,v in pairs(strings) do
      cnt = cnt +1;
      love.graphics.print(v, rect[1]+30, (rect[2] + (cnt*(love.graphics.getHeight())*0.02)));
   end

   -- -- -- -- -- -- -- -- -- --
   -- Draw Alerts
   -- -- -- -- -- -- -- -- -- --
   local rect = {love.graphics.getWidth()*0.34, love.graphics.getHeight()*0.88};
   if (wumpus_here(iYOU)) then
      love.graphics.setColor(255, 0, 0, 255);
      love.graphics.printf("Oh no!  It's the Wumpus!", rect[1], rect[2], love.graphics.getWidth()*0.32, "center");
	  love.graphics.printf("The sound of an AK-47 resounds.", rect[1], rect[2]+love.graphics.getHeight()*0.02, love.graphics.getWidth()*0.32, "center");
	  love.graphics.printf("Game over...", rect[1], rect[2]+love.graphics.getHeight()*0.04, love.graphics.getWidth()*0.32, "center");

   elseif (bCOPS) then
      love.graphics.setColor(100, 0, 255, 255);
      love.graphics.printf("Oh no!  It's the police!", rect[1], rect[2], love.graphics.getWidth()*0.32, "center");
	  love.graphics.printf("Game over... See ya in 25 years pal.", rect[1], rect[2]+love.graphics.getHeight()*0.02, love.graphics.getWidth()*0.32, "center");
   elseif (bGLOW_WORMS) then
      love.graphics.setColor(200, 200, 0, 255);
      love.graphics.printf("You have been ganged by glow worms!", rect[1], rect[2], love.graphics.getWidth()*0.32, "center");
	  love.graphics.printf("You awaken in an unfamiliar region", rect[1], rect[2]+love.graphics.getHeight()*0.02, love.graphics.getWidth()*0.32, "center");
   end

   if (bWUMPUS_SHOT_MISSED) then
      love.graphics.setColor(180, 0, 255, 255);
      love.graphics.printf("Kaping! What were you aiming at?", rect[1], rect[2], love.graphics.getWidth()*0.32, "center");
	  love.graphics.printf("That was your last bullet!", rect[1], rect[2]+love.graphics.getHeight()*0.02, love.graphics.getWidth()*0.32, "center");
	  love.graphics.printf("Game over...", rect[1], rect[2]+love.graphics.getHeight()*0.04, love.graphics.getWidth()*0.32, "center");

   elseif (bWUMPUS_SHOT_HIT) then
      love.graphics.setColor(0, 255, 40, 255);
      love.graphics.printf("Kapow! Wow!", rect[1], rect[2], love.graphics.getWidth()*0.32, "center");
	  love.graphics.printf("Good job, you killed the Wumpus!", rect[1], rect[2]+love.graphics.getHeight()*0.02, love.graphics.getWidth()*0.32, "center");
   end
end
