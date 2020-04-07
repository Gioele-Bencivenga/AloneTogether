package;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		
		addChild(new FlxGame(1280, 720, MenuState, 1, 60, 60, true));

		// we enable the system cursor instead of using the default since flixel's cursor is kind of laggy
		FlxG.mouse.useSystemCursor = true;
	}
}
