package myClasses;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxVector;
import flixel.FlxSprite;

enum abstract ItemType(Int) to Int {
	var Mask = 0;
	var Gloves = 1;
	var Sanitizer = 2;
}

class Item extends FlxSprite {
	static final BASE_SCALE:Float = 1;
	static final EQUIPPED_SCALE:Float = 0.7;

	public var type(default, null):ItemType;

	public var slot(default, null):Int; // array slot where the item is kept in the human class (0 = Mask, 1 = Gloves, 2 = Sanitizer)

	var owner:Human;

	var maxDistFromOwner:Int; // distance after which the item starts following the player
	var velocityMultiplier:Float; // how fast the item follows

	var direction:FlxVector;

	public var infectionChanceReduction(default, null):Int;
	public var germSpeedReduction(default, null):Int;

	public var isEquipped(default, null):Bool;

	// for things that are only set once
	public function new() {
		super();

		drag.x = drag.y = 600;
	}

	// for things that need to be set each time we recycle
	public function initialize(_x:Float, _y:Float, _type:ItemType) {
		x = _x;
		y = _y;
		type = _type;
		isEquipped = false;

		if (owner != null) {
			owner = null;
		}

		switch type {
			case Mask:
				loadGraphic(AssetPaths.surgicalMask__png, false, 16, 16);
				maxDistFromOwner = 5;
				velocityMultiplier = 5;
				infectionChanceReduction = 25;
				germSpeedReduction = 7;
				slot = 0;

			case Gloves:
				loadGraphic(AssetPaths.latticeGlove__png, false, 16, 16);
				maxDistFromOwner = 10;
				velocityMultiplier = 3.5;
				infectionChanceReduction = 15;
				germSpeedReduction = 3;
				slot = 1;

			case Sanitizer:
				loadGraphic(AssetPaths.handSanitizer__png, false, 16, 16);
				maxDistFromOwner = 15;
				velocityMultiplier = 2.5;
				infectionChanceReduction = 20;
				germSpeedReduction = 5;
				slot = 2;
		}

		scale.set(BASE_SCALE, BASE_SCALE);
		updateHitbox();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		followOwner();
	}

	public function equipTo(_owner:Human) {
		if (!isEquipped) {
			solid = false;
			owner = _owner;
			isEquipped = true;
			setColorTransform(1, 1, 1, 1, 50, 100, 50);

			FlxTween.tween(this.scale, {
				x: BASE_SCALE + 0.7,
				y: BASE_SCALE + 0.5,
			}, 0.15, {
				ease: FlxEase.expoOut,
			}).then(FlxTween.tween(this.scale, {
				x: EQUIPPED_SCALE,
				y: EQUIPPED_SCALE,
			}, 0.15, {
				ease: FlxEase.expoOut,
				onComplete: function(_) updateHitbox()
			}));
		}
	}

	public function unEquip() {
		owner = null;
		isEquipped = false;
		setColorTransform();
		solid = true;
		scale.set(BASE_SCALE, BASE_SCALE);
		updateHitbox();
	}

	function followOwner() {
		if (owner != null) {
			var distFromOwner = getMidpoint().distanceTo(owner.getMidpoint());

			direction = FlxVector.weak(owner.x - x, owner.y - y);
			direction.length = distFromOwner * velocityMultiplier;

			if (distFromOwner > maxDistFromOwner) {
				velocity.set(direction.x, direction.y);
			}
		}
	}
}
