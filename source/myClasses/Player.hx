package myClasses;

import flixel.FlxG;

class Player extends Human {
	public function new() {
		super();
	}

	override public function initialize(_x:Float, _y:Float, ?_sprite:String) {
		super.initialize(_x, _y, _sprite);

		health = 20;
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
		j = FlxG.keys.anyJustReleased([J, C]);
		k = FlxG.keys.anyJustReleased([K, X]);
		l = FlxG.keys.anyJustReleased([L, Z]);
		e = FlxG.keys.anyJustReleased([E, V]);
	}

	override function doDamage(_damageAmount:Float) {
		FlxG.cameras.shake(0.003, 0.1);

		super.doDamage(_damageAmount);
	}
}
