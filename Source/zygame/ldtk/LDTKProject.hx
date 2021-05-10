package zygame.ldtk;

import zygame.display.batch.BImage;
import zygame.utils.ZAssets;
import zygame.display.batch.ImageBatchs;
import zygame.utils.StringUtils;
import zygame.components.ZBox;
import haxe.Json;

class LDTKProject {
	/**
	 * 世界瓦片的宽度
	 */
	public var worldGridWidth:Int = 0;

	/**
	 * 世界瓦片的高度
	 */
	public var worldGridHeight:Int = 0;

	/**
	 * 默认的瓦片尺寸
	 */
	public var defaultGridSize:Int = 0;

	/**
	 * 背景颜色
	 */
	public var bgColor:Int = 0;

	/**
	 * 默认关卡颜色
	 */
	public var defaultLevelBgColor:Int = 0;

	/**
	 * 地图的所有第一关系
	 */
	public var defs:LDTKDefs = null;

	/**
	 * 关卡数据
	 */
	public var levels:Array<LDTKLevel> = [];

	/**
	 * 资源引用
	 */
	public var assets:ZAssets;

	/**
	 * 瓦片路径绑定UID
	 */
	public var tilesetPathByUid:Map<Int, String>;

	public function new(data:String) {
		var ldtkData = Json.parse(data);
		zygame.macro.JsonSet.setData(this, ldtkData);
		tilesetPathByUid = [];
		for (index => value in this.defs.tilesets) {
			tilesetPathByUid.set(value.uid, StringUtils.getName(value.relPath));
		}
	}

	/**
	 * 创建LDTK地图
	 * @param levelid 
	 */
	public function createLDTKMap(levelid:String):LDTKMap {
		var level = getLDTKLevel(levelid);
		var box = new LDTKMap(level.pxWid, level.pxHei, level.layerInstances[0].__gridSize);
		// 开始渲染
		var len = level.layerInstances.length;
		while (len > 0) {
			len--;
			var value = level.layerInstances[len];
			// var fixFloat = value.__gridSize * 0.002;
			var fixFloat = 0;
			switch (value.__type) {
				case "Entities":
					// 事件渲染
					var layer = new ZBox();
					layer.name = value.__identifier;
					box.addChild(layer);
					for (index => value in value.entityInstances) {
						var entity = new LDTKEntity(this, value);
						layer.addChild(entity);
						entity.x = value.px[0];
						entity.y = value.px[1];
					}
				case "IntGrid", "AutoLayer":
					var tilesetId = StringUtils.getName(value.__tilesetRelPath);
					var batch = new ImageBatchs(assets.getTextureAtlas(tilesetId), -1, -1, false);
					batch.name = value.__identifier;
					batch.width = level.pxWid;
					batch.height = level.pxHei;
					for (tile in value.autoLayerTiles) {
						var bimg = new BImage(assets.getBitmapData(tilesetId + ":" + tile.src[0] + "x" + tile.src[1]));
						batch.addChild(bimg);
						bimg.x = tile.px[0] - fixFloat * 2;
						bimg.y = tile.px[1] - fixFloat * 2;
						bimg.width += fixFloat * 4;
						bimg.height += fixFloat * 4;
						switch (tile.f) {
							case 1:
								bimg.scaleX = -1;
								bimg.x += bimg.width;
							case 2:
								bimg.scaleY = -1;
								bimg.y += bimg.height;
							case 3:
								bimg.scaleX = -1;
								bimg.scaleY = -1;
								bimg.x += bimg.width;
								bimg.y += bimg.height;
						}
					}
					box.addChild(batch);
					batch.alpha = value.__opacity;
					if (value.__type == "IntGrid")
						box.bindIntGridCsv(value.intGridCsv);
			}
		}
		return box;
	}

	/**
	 * 根据关卡ID获取关卡数据
	 * @param levelid 
	 * @return LDTKLevel
	 */
	public function getLDTKLevel(levelid:String):LDTKLevel {
		for (index => value in levels) {
			if (value.identifier == levelid) {
				return value;
			}
		}
		return null;
	}
}

class LDTKMap extends ZBox {
	public var tileWidth:Int = 0;

	public var tileHeight:Int = 0;

	public var tileSize:Int = 0;

	private var _mapInt:Array<Array<Int>> = [];

	public function new(tileW:Int, tileH:Int, tileSize:Int) {
		super();
		this.tileSize = tileSize;
		this.tileWidth = Std.int(tileW / this.tileSize);
		this.tileHeight = Std.int(tileH / this.tileSize);
	}

	/**
	 * 绑定地图块数据
	 */
	public function bindIntGridCsv(data:Array<Int>):Void {
		var ix = 0;
		var iy = 0;
		trace(this.tileWidth, data.length);
		for (i in 0...data.length) {
			if (_mapInt[ix] == null)
				_mapInt[ix] = [];
			_mapInt[ix][iy] = data[i];
			ix++;
			if (ix >= this.tileWidth) {
				ix = 0;
				iy++;
			}
		}
	}

	/**
	 * 碰撞逻辑
	 * @param rect 
	 */
	public function hitGrid(rect:{
		x:Float,
		y:Float,
		w:Float,
		h:Float
	}):LDTKHitData {
		var XIndex = Std.int(rect.x / tileSize);
		var YIndex = Std.int(rect.y / tileSize);
		var centerYIndex = Std.int((rect.y - 1 / 2) / tileSize);
		var topIndex = Std.int((rect.y - rect.h) / tileSize);
		var centerIndex = Std.int((rect.y - rect.h / 2) / tileSize);
		var leftIndex = Std.int((rect.x - rect.w / 2) / tileSize);
		var rightIndex = Std.int((rect.x + rect.w / 2) / tileSize);
		var right = _mapInt[rightIndex][centerYIndex];
		var left = _mapInt[leftIndex][centerYIndex];
		var bottom = _mapInt[XIndex][YIndex];
		var leftIndex2 = Std.int((rect.x - (rect.w - 2) / 2) / tileSize);
		var rightIndex2 = Std.int((rect.x + (rect.w - 2) / 2) / tileSize);
		if (bottom == 0)
			bottom = _mapInt[leftIndex2][YIndex];
		if (bottom == 0)
			bottom = _mapInt[rightIndex2][YIndex];
		var top = _mapInt[XIndex][topIndex];
		// if (top == 0)
		// 	top = _mapInt[leftIndex][topIndex];
		// if (top == 0)
		// top = _mapInt[rightIndex][topIndex];
		return {
			top: top,
			center: _mapInt[XIndex][centerIndex],
			right: right == 0 ? _mapInt[rightIndex][topIndex] : right,
			left: left == 0 ? _mapInt[leftIndex][topIndex] : left,
			bottom: bottom,
			centerYIndex: YIndex,
			centerXIndex: XIndex,
			topIndex: topIndex
		};
	}
}

typedef LDTKHitData = {
	left:Int,
	right:Int,
	top:Int,
	bottom:Int,
	centerXIndex:Int,
	centerYIndex:Int,
	topIndex:Int,
	center:Int
}

/**
 * 关卡数据
 */
typedef LDTKLevel = {
	pxWid:Int,
	pxHei:Int,
	worldX:Int,
	worldY:Int,
	identifier:String,
	layerInstances:Array<{
		__gridSize:Int,
		__type:String,
		__identifier:String,
		__tilesetRelPath:String,
		__opacity:Float,
		autoLayerTiles:Array<{
			px:Array<Int>,
			src:Array<Int>,
			f:Int,
			t:Int,
			d:Array<Int>
		}>,
		intGridCsv:Array<Int>,
		entityInstances:Array<LDTKEventEntity>
	}>
};

/**
 * LDTK的事件实例
 */
typedef LDTKEventEntity = {
	__identifier:String,
	__grid:Array<Int>,
	__pivot:Array<Float>,
	__tile:{
		tilesetUid:Int, srcRect:Array<Int>
	},
	width:Int,
	height:Int,
	defUid:Int,
	px:Array<Int>,
	fieldInstances:Array<{
		__identifier:String,
		__value:String,
		__type:String,
		defUid:Int,
		realEditorValues:Array<Dynamic>
	}>
}

/**
 * LDTK的定义描述
 */
typedef LDTKDefs = {
	layers:Array<Dynamic>,
	entities:Array<Dynamic>,
	tilesets:Array<{
		relPath:String,
		pxWid:Int,
		pxHei:Int,
		tileGridSize:Int,
		spacing:Int,
		padding:Int,
		uid:Int
	}>,
	enums:Array<Dynamic>,
	externalEnums:Array<Dynamic>,
	levelFields:Array<Dynamic>
}
