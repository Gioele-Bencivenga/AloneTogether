package myClasses;

import flixel.util.FlxColor;
import flixel.FlxG;

class Player extends Human {
	public var hasFoundCure:Bool;

	public function new() {
		hasFoundCure = false;

		super();
	}

	override public function initialize(_x:Float, _y:Float, ?_sprite:String) {
		super.initialize(_x, _y, _sprite);

		health = 30;
		coinAmount = FlxG.random.int(20, 40);
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
		one = FlxG.keys.justReleased.ONE;
		if (one)
			interactOption = 1;
		two = FlxG.keys.justReleased.TWO;
		if (two)
			interactOption = 2;
		three = FlxG.keys.justReleased.THREE;
		if (three)
			interactOption = 3;
		four = FlxG.keys.justReleased.FOUR;
		if (four)
			interactOption = 4;
	}

	override function doDamage(_damageAmount:Float) {
		FlxG.cameras.shake(0.003, 0.1);
		FlxG.cameras.flash(FlxColor.fromRGB(255, 0, 0, 50), 0.2);

		super.doDamage(_damageAmount);
	}

	override function heal(_healthAmount:Float) {
		FlxG.cameras.flash(FlxColor.fromRGB(0, 255, 0, 50), 0.5);

		super.heal(_healthAmount);
	}
}
