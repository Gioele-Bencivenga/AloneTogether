package;

import openfl.filters.ShaderFilter;
import flixel.util.FlxTimer;
import openfl.ui.GameInputControl;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxEmitter;
import flixel.math.FlxMath;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.FlxState;
import myClasses.*;

class PlayState extends FlxState {
	var player:Player;

	public static var coins:FlxTypedGroup<Coin>; // group of coins
	public static var items:FlxTypedGroup<Item>;

	public static var npcs:FlxTypedGroup<NPC>; // group of npcs
	public static var actors:FlxTypedGroup<Human>; // group of npcs + player
	public static var spawners:FlxTypedGroup<NPCSpawner>;
	public static var emitters:FlxTypedGroup<FlxEmitter>; // group of emitters

	var map:FlxOgmo3Loader;
	var collisionsLayer:FlxTilemap;
	var groundLayer:FlxTilemap;
	var buildingsLayer:FlxTilemap;
	var rooftopsLayer:FlxTilemap;

	var hud:HUD;

	var gameCamera:FlxCamera;
	var hudCamera:FlxCamera;
	var shaderCamera:FlxCamera;

	var npcDetectionTimer:FlxTimer;

	override public function create():Void {
		/// TILEMAP STUFF
		map = new FlxOgmo3Loader(AssetPaths.cityTilemap__ogmo, AssetPaths.city1__json);
		collisionsLayer = map.loadTilemap(AssetPaths.tiles__png, "collisions");
		collisionsLayer.setTileProperties(1, FlxObject.NONE);
		collisionsLayer.setTileProperties(2, FlxObject.ANY);
		collisionsLayer.immovable = true;
		add(collisionsLayer);
		groundLayer = map.loadTilemap(AssetPaths.tilemap_packed__png, "ground");
		add(groundLayer);
		buildingsLayer = map.loadTilemap(AssetPaths.tilemap_packed__png, "buildings");
		add(buildingsLayer);

		/// CAMERA STUFF
		gameCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		gameCamera.bgColor = FlxColor.TRANSPARENT;
		collisionsLayer.follow(gameCamera); // lock the camera to the wall map edges
		gameCamera.zoom = 2.4;
		FlxG.cameras.add(gameCamera);
		// hud camera
		hudCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		hudCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(hudCamera);

		FlxCamera.defaultCameras = [gameCamera];

		/// ITEMS STUFF
		coins = new FlxTypedGroup<Coin>();
		add(coins);
		items = new FlxTypedGroup<Item>();
		add(items);

		/// VIRUS STUFF
		emitters = new FlxTypedGroup<FlxEmitter>();
		add(emitters);

		/// NPC STUFF
		npcs = new FlxTypedGroup<NPC>();
		add(npcs);

		/// PLAYER STUFF
		player = new Player();
		player.initialize(0, 0);
		add(player);
		add(player.emitter);
		emitters.add(player.emitter);
		gameCamera.follow(player, FlxCameraFollowStyle.LOCKON);

		/// ACTOR STUFF
		actors = new FlxTypedGroup<Human>();
		actors.add(player);

		/// SPAWNER
		spawners = new FlxTypedGroup<NPCSpawner>();

		/// ENTITIES STUFF
		map.loadEntities(placeEntities, "entities");

		npcs.getRandom().infect();

		// we put the rooftops after the player so they get rendered in front of it
		rooftopsLayer = map.loadTilemap(AssetPaths.tilemap_packed__png, "rooftops");
		add(rooftopsLayer);

		/// HUD STUFF
		hud = new HUD(player, actors);
		hud.forEach(function(element) {
			element.cameras = [hudCamera];
		});
		add(hud);

		/// TIMER STUFF
		npcDetectionTimer = new FlxTimer();
		npcDetectionTimer.start(1, callNpcDetectMethod, 0);

		super.create();
	}

	function placeEntities(entity:EntityData) {
		switch (entity.name) {
			case "player":
				player.setPosition(entity.x, entity.y);

			case "coin": // we add the coin in the ogmo project to our coins group, the +4 is to center the coin in the middle of the tile
				var newCoin = new Coin();
				newCoin.initialize(entity.x + 4, entity.y + 4);
				emitters.add(newCoin.emitter);
				coins.add(newCoin);

			case "mask":
				var newMask = new Item();
				newMask.initialize(entity.x, entity.y, Mask);
				items.add(newMask);

			case "gloves":
				var newGloves = new Item();
				newGloves.initialize(entity.x, entity.y, Gloves);
				items.add(newGloves);

			case "sanitizer":
				var newSanitizer = new Item();
				newSanitizer.initialize(entity.x, entity.y, Sanitizer);
				items.add(newSanitizer);

			case "npc":
				var newNpc = new NPC();
				newNpc.initialize(entity.x + 4, entity.y + 4);
				emitters.add(newNpc.emitter);
				npcs.add(newNpc);
				actors.add(newNpc);

			case "spawner":
				spawners.add(new NPCSpawner(entity.x, entity.y));
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		// collisions between actors
		FlxG.collide(actors, actors, humanTouchesHuman);
		// collisions between actors and tilemap
		FlxG.collide(actors, collisionsLayer);
		// collisions between germs and tilemap
		FlxG.collide(emitters, collisionsLayer);
		FlxG.collide(items, collisionsLayer);

		// overlaps between actors and virus
		FlxG.overlap(actors, emitters, humanTouchesVirus);
		// overlaps between actors and coins
		FlxG.overlap(actors, coins, humanTouchesCoin);
		// overlaps between actors and items
		FlxG.overlap(actors, items, humanTouchesItem);

		// pressing period/comma zooms in/out
		if (FlxG.keys.justPressed.PERIOD) {
			SetZoom(FlxG.camera.zoom += 0.2);
		}
		if (FlxG.keys.justPressed.COMMA) {
			SetZoom(FlxG.camera.zoom -= 0.2);
		}
	}

	function humanTouchesCoin(_actor:Human, _coin:Coin) {
		if (_actor.alive && _actor.exists && _coin.alive && _coin.exists) {
			_coin.kill();
			_actor.gainCoin(1);
		}
	}

	function humanTouchesItem(_actor:Human, _item:Item) {
		if (_actor.alive && _actor.exists && _item.alive && _item.exists && !_item.isEquipped) {
			if (_actor.canPickUp) {
				switch _item.type {
					case Mask:
						if (_actor.items.members[0] == null) {
							_item.equipTo(_actor);
							_actor.equipItem(_item);
						}
					case Gloves:
						if (_actor.items.members[1] == null) {
							_item.equipTo(_actor);
							_actor.equipItem(_item);
						}
					case Sanitizer:
						if (_actor.items.members[2] == null) {
							_item.equipTo(_actor);
							_actor.equipItem(_item);
						}
				}
			}
		}
	}

	function humanTouchesVirus(_actor:Human, _emitter:FlxEmitter) {
		if (_actor.alive && _actor.exists && _emitter.alive && _emitter.exists) {
			if (!_actor.isInfected && !_actor.isImmune) {
				_actor.tryToInfect();
			}
		}
	}

	function humanTouchesHuman(_actor1:Human, _actor2:Human) {
		if (_actor1.alive && _actor1.exists && _actor2.alive && _actor2.exists) {
			if (_actor1.isInfected) {
				if (!_actor2.isInfected && !_actor2.isImmune) {
					_actor2.tryToInfect();
				}
			}
			if (_actor2.isInfected) {
				if (!_actor1.isInfected && !_actor1.isImmune) {
					_actor1.tryToInfect();
				}
			}
		}
	}

	function callNpcDetectMethod(_) { // called each second by the timer so that NPCs run less into walls
		for (npc in npcs) {
			npc.detectSurroundings(collisionsLayer);
		}
	}

	private function SetZoom(_zoom:Float) {
		gameCamera.zoom = FlxMath.bound(_zoom, 2, 4);
	}
}
