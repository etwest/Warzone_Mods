function Client_PresentConfigureUI(rootParent)
	-- Set the default number of turns
	NumTurns = Mod.Settings.NumTurns;
	if (NumTurns == nil) then
		NumTurns = 10;
	end

	-- Ask user to configure the number of turns
	row = UI.CreateHorizontalLayoutGroup(rootParent)
	UI.CreateLabel(row).SetText('How many turns should the game last')
	inputNumTurns = UI.CreateNumberInputField(row).SetSliderMinValue(5).SetSliderMaxValue(30).SetValue(NumTurns)
end