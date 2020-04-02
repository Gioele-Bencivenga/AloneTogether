package;

import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.FlxState;

class MenuState extends FlxState {
	var playButton:FlxButton;

	override public function create():Void {
        playButton = new FlxButton(0, 0, "Play", startGame);
        playButton.screenCenter();
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
