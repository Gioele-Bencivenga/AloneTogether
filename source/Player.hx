package;

import flixel.FlxObject;
import flixel.FlxG;
import flixel.util.FlxColor;

class Player extends Human {

	var sprite:String = AssetPaths.bobert__png;

	public function new(x:Float = 0, y:Float = 0) {
		super(x, y, sprite);
	}

	override function update(elapsed:Float) {
		processInput();

		super.update(elapsed);
	}

	function processInput() {
		up = FlxG.keys.anyPressed([UP, W]);
		down = FlxG.keys.anyPressed([DOWN, S]);
		left = FlxG.keys.anyPressed([LEFT, A]);
		right = FlxG.keys.anyPressed([RIGHT, D]);
	}
}
