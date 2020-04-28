package;

import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.FlxState;

class MenuState extends FlxState {
	var playButton:FlxButton;
	var titleText:FlxText;
	var descriptionText:FlxText;

	override public function create():Void {
		titleText = new FlxText(0, 20, 0, "MAYOR OUTBREAK", 80);
		titleText.setBorderStyle(SHADOW, FlxColor.BLUE, 15);
		titleText.color = FlxColor.ORANGE;
		titleText.screenCenter(FlxAxes.X);
		add(titleText);

		var description = "You are the Mayor of a city hit by a major virus outbreak!\n
		Close down buildings to slow the spread of the virus!\n
		Don't close too many buildings though, as workers are the people bringing money in!\n
		Help your denizens fight the virus by giving them protective gear and they will reward you!\n
		Invest money in the search for a cure, then distribute said cure until the virus is eradicated!";
		descriptionText = new FlxText(0, titleText.y + titleText.height + 20, 0, description, 16);
		descriptionText.setBorderStyle(SHADOW, FlxColor.BLUE, 3);
		descriptionText.screenCenter(FlxAxes.X);
		add(descriptionText);

		playButton = new FlxButton(0, descriptionText.y + descriptionText.height + 30, "PLAY", startGame);
		playButton.setGraphicSize(200, 30);
		playButton.screenCenter(FlxAxes.X);
		add(playButton);

		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}

	function startGame() {
		FlxG.switchState(new PlayState());
	}
}
