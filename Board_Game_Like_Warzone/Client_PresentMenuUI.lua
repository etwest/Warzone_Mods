require('Utilities');

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game)

	if game.Game.State == 5 then -- manual distribution in progress
		UI.CreateLabel(rootParent).SetText("Territories are currently being distributed. Check back here for points once the game begins.");
		return;
	end

	if game.Game.State == 4 then -- the game is over
		setMaxSize(500, 600);
		vert = UI.CreateVerticalLayoutGroup(rootParent);
		UI.CreateLabel(vert).SetText('The game is over. You may now view the history of points for previous turns.');
		
		local history_header = UI.CreateHorizontalLayoutGroup(vert);
		UI.CreateButton(history_header).SetText('Prev').SetOnClick(
			function()
				local turn_num = inputTurnNum.GetValue();
				turn_num = turn_num - 1;
				if turn_num < 1 then turn_num = 1; end
				if turn_num > game.Game.NumberOfTurns then turn_num = game.Game.NumberOfTurns; end

				inputTurnNum.SetValue(turn_num);
				local history_msg = "Turn " .. turn_num .. ' rankings:\n';
				local turn_data = Mod.PublicGameData.PointsList[turn_num]
				if turn_data == nil then
					history_msg = "ERROR: Don't have data for this turn :("
				else
					for position, msg in pairs(turn_data) do
						history_msg = history_msg .. msg .. "\n";
					end
				end
				historyLabel.SetText(history_msg);
			end
		);
		UI.CreateButton(history_header).SetText('Next').SetOnClick(
			function()
				local turn_num = inputTurnNum.GetValue();
				turn_num = turn_num + 1;
				if turn_num < 1 then turn_num = 1; end
				if turn_num > game.Game.NumberOfTurns then turn_num = game.Game.NumberOfTurns; end

				inputTurnNum.SetValue(turn_num);
				local history_msg = "Turn " .. turn_num .. ' rankings:\n';
				local turn_data = Mod.PublicGameData.PointsList[turn_num];
				if turn_data == nil then
					history_msg = "ERROR: Don't have data for this turn :("
				else
					for position, msg in pairs(turn_data) do
						history_msg = history_msg .. msg .. "\n";
					end
				end
				historyLabel.SetText(history_msg);
			end
		);
		UI.CreateButton(history_header).SetText('View Turn:').SetOnClick(
			function()
				local turn_num = inputTurnNum.GetValue();
				local history_msg = "Turn " .. turn_num .. ' rankings:\n';
				if turn_num < 1 or turn_num > game.Game.NumberOfTurns then
					history_msg = history_msg .. "Invalid Turn number!";
				else
					local turn_data = Mod.PublicGameData.PointsList[turn_num]
					if turn_data == nil then
						history_msg = "ERROR: Don't have data for this turn :("
					else
						for position, msg in pairs(turn_data) do
							history_msg = history_msg .. msg .. "\n";
						end
					end
				end
					
				historyLabel.SetText(history_msg);
			end
		);
		inputTurnNum = UI.CreateNumberInputField(history_header).SetValue(1).SetSliderMinValue(1).SetSliderMaxValue(game.Game.NumberOfTurns);
		historyLabel = UI.CreateLabel(vert);
		return;
	end

	if (game.Us == nil) then
		UI.CreateLabel(rootParent).SetText("You are spectating this game. Once the game ends you can find the points history here.");
		return;
	end

	setMaxSize(450, 280);
	vert = UI.CreateVerticalLayoutGroup(rootParent);

	if Mod.Settings.DisplayRelative then
		local players_by_combat = get_players_by_combat(game);
		local players_by_income = get_players_by_income(game);

		-- get current player's income and killPoints
		local player = game.Us
		local p_id = player.ID
		local income = player.Income(0, game.LatestStanding, false, true).Total
		local kill_points = Mod.PublicGameData.KillPoints[p_id];
		local income_points = income * Mod.Settings.NumTurns / 4;
		kill_points = math.floor(kill_points/5) * 5;
		income_points = math.floor(income_points/5) * 5;

		local combat_rank = 0;
		local income_rank = 0;
		for position, id in pairs(players_by_combat) do
			if id == p_id then
				combat_rank = position;
			end
		end 
		for position, id in pairs(players_by_income) do
			if id == p_id then
				income_rank = position;
			end
		end

		UI.CreateLabel(vert).SetText("You have approximately:")
		UI.CreateLabel(vert).SetText(kill_points .. ' points from combat. Rank: ' .. combat_rank);
		UI.CreateLabel(vert).SetText(income_points .. ' points from income. Rank: ' .. income_rank)
		UI.CreateLabel(vert).SetText("This gives you a total of: " .. kill_points + income_points .. " points.")
	end
	
	if Mod.Settings.DisplayOrder then
		local row = UI.CreateHorizontalLayoutGroup(vert);
		UI.CreateLabel(row).SetText("Players ordered by total points:")

		-- get the players, ordered by points
		local players_by_points = get_players_by_points(game)

		-- display the current order of players
		for position, player in pairs(players_by_points) do
			local row = UI.CreateHorizontalLayoutGroup(vert);
			local player_obj = game.Game.Players[player];
			UI.CreateLabel(row).SetText(position .. ". " .. player_obj.DisplayName(nil, false))
		end
	end
end

function get_players_by_combat(game)
	local sorted_players = {};
	local kill_info = Mod.PublicGameData.KillPoints;
	for player in pairs(game.Game.Players) do
		table.insert(sorted_players, player);
	end

	table.sort(sorted_players, function(a, b)
		return kill_info[a] > kill_info[b];
	end)

	return sorted_players;
end

function get_players_by_income(game)
	local sorted_players = {};
	local income_points = Mod.PublicGameData.IncomePoints;
	for player in pairs(game.Game.Players) do
		table.insert(sorted_players, player);
	end

	table.sort(sorted_players, function(a, b)
		return income_points[a] > income_points[b];
	end)

	return sorted_players;
end

function get_players_by_points(game)
	local sorted_players = {};
	local income_points = Mod.PublicGameData.IncomePoints;
	local kill_points = Mod.PublicGameData.KillPoints;
	for player in pairs(game.Game.Players) do
		table.insert(sorted_players, player);
	end

	table.sort(sorted_players, function(a, b)
		return income_points[a] + kill_points[a] > income_points[b] + kill_points[b];
	end)

	return sorted_players;
end