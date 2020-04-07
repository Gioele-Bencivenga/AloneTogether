package;

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
	var coins:FlxTypedGroup<Coin>;

	var map:FlxOgmo3Loader;

	var collisionsLayer:FlxTilemap;
	var groundLayer:FlxTilemap;
	var buildingsLayer:FlxTilemap;
	var rooftopsLayer:FlxTilemap;

	override public function create():Void {
		/// TILEMAP STUFF
		map = new FlxOgmo3Loader(AssetPaths.cityTilemap__ogmo, AssetPaths.city1__json);
		collisionsLayer = map.loadTilemap(AssetPaths.tiles__png, "collisions");
		collisionsLayer.setTileProperties(1, FlxObject.NONE);
		collisionsLayer.setTileProperties(2, FlxObject.ANY);
		add(collisionsLayer);
		groundLayer = map.loadTilemap(AssetPaths.tilemap_packed__png, "ground");
		add(groundLayer);
		buildingsLayer = map.loadTilemap(AssetPaths.tilemap_packed__png, "buildings");
		add(buildingsLayer);

		/// COIN STUFF
		coins = new FlxTypedGroup<Coin>();
		add(coins);

		/// PLAYER STUFF
		player = new Player();
		map.loadEntities(placeEntities, "entities");
		add(player);

		// we put the rooftops after the player so they get rendered in front of it
		rooftopsLayer = map.loadTilemap(AssetPaths.tilemap_packed__png, "rooftops");
		add(rooftopsLayer);

		/// CAMERA STUFF
		collisionsLayer.follow(); // lock the camera to the wall map edges
		FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON);
		FlxG.camera.zoom = 2.5;

		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		FlxG.collide(player, collisionsLayer);
		FlxG.overlap(player, coins, playerTouchCoin);
	}

	function placeEntities(entity:EntityData) {
		if (entity.name == "player") {
			player.setPosition(entity.x, entity.y);
		} else if (entity.name == "coin") {
			coins.add(new Coin(entity.x + 4,
				entity.y + 4)); // we add the coin in the ogmo project to our coins group, the +4 is to center the coin in the middle of the tile
		}
	}

	function playerTouchCoin(player:Player, coin:Coin) {
		if (player.alive && player.exists && coin.alive && coin.exists) {
			coin.kill();
		}
	}
}
