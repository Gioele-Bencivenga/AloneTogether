package myClasses;

import flixel.util.FlxColor;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class Coin extends FlxSprite {
	public var emitter:FlxEmitter;

	public function new() {
		super();
		loadGraphic(AssetPaths.coin__png, false, 8, 8);

		emitter = new FlxEmitter();
		emitter.makeParticles(2, 2, FlxColor.YELLOW, 50);
	}

	public function initialize(_x:Float, _y:Float) {
		x = _x;
		y = _y;

		/// EMITTER
		emitter.color.set(FlxColor.YELLOW, FlxColor.ORANGE, FlxColor.WHITE, FlxColor.YELLOW);
		emitter.lifespan.set(0.1, 0.4);
		emitter.speed.set(0, 150);
		emitter.angularVelocity.set(-500, 500);
		emitter.launchMode = FlxEmitterMode.CIRCLE;
	}

	override function kill() {
		alive = false;

		var randX = FlxG.random.int(-5, 5);
		var randY = FlxG.random.int(15, 30);
		var randAngle = FlxG.random.int(500, 1000);

		FlxTween.tween(this, {
			x: x + randX,
			y: y - randY,
			angle: angle - randAngle
		}, 0.50, {
			ease: FlxEase.circOut,
			onComplete: function(_) {
				emitter.focusOn(this);
				emitter.start();
				exists = false;
			}
		});
	}
}
