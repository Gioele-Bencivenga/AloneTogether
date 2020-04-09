package myClasses;

import flixel.FlxG;

class Player extends Human {

	var sprite:String = AssetPaths.bobert__png;

	public function new(_x:Float = 0, _y:Float = 0) {
		super(_x, _y, sprite);
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
		running = FlxG.keys.anyPressed([SHIFT, Z]);
	}
}
