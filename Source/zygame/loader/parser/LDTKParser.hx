package zygame.loader.parser;

import zygame.utils.load.TextureLoader.TextureAtlas;
import zygame.utils.StringUtils;
import zygame.ldtk.LDTKProject;
import haxe.Json;
import zygame.utils.AssetsUtils;

/**
 * 用于加载LDTKParser解析使用，当加载一个ldtk文件时，则会将所有的瓦片加载。
 */
class LDTKParser extends ParserBase {
	private var ldtk:LDTKProject;

	private var tilesetLoadIndex = 0;

	private var _rootPath:String = "";

	/**
	 * 支持ldtk文件
	 * @param data 
	 * @return Bool
	 */
	public static function supportType(data:Dynamic):Bool {
		return StringTools.endsWith(data, ".ldtk");
	}

	override function process() {
		if (ldtk == null) {
			// 开始加载
			_rootPath = getData();
			_rootPath = _rootPath.substr(0, _rootPath.lastIndexOf("/"));
			AssetsUtils.loadText(getData()).onComplete(function(data) {
				ldtk = new LDTKProject(data);
				this.contiune();
			});
		} else if (tilesetLoadIndex < ldtk.defs.tilesets.length) {
			var tileset = ldtk.defs.tilesets[tilesetLoadIndex];
			if (tileset != null) {
				AssetsUtils.loadBitmapData(_rootPath + "/" + tileset.relPath).onComplete(function(data) {
					tilesetLoadIndex++;
					// 解析瓦片数据
					var root:Xml = Xml.createDocument();
					var textures:Xml = Xml.createElement("TextureAtlas");
					root.addChild(textures);
					var ix = Std.int(tileset.pxWid / tileset.tileGridSize);
					var iy = Std.int(tileset.pxHei / tileset.tileGridSize);
					// var fixFloat = tileset.tileGridSize * 0.001;
					var fixFloat = 0;
					for (i in 0...ix) {
						for (i2 in 0...iy) {
							var texture = Xml.createElement("Texture");
							texture.set("name", i * tileset.tileGridSize + "x" + i2 * tileset.tileGridSize);
							texture.set("width", Std.string(tileset.tileGridSize - fixFloat * 2));
							texture.set("height", Std.string(tileset.tileGridSize - fixFloat * 2));
							texture.set("x", Std.string(i * tileset.tileGridSize + fixFloat));
							texture.set("y", Std.string(i2 * tileset.tileGridSize + fixFloat));
							textures.addChild(texture);
						}
					}
					this.getAssets().putTextureAtlas(StringUtils.getName(tileset.relPath), new TextureAtlas(data, root));
					ldtk.assets = this.getAssets();
					this.contiune();
				});
			}
		} else {
			// 资源准备完毕
			this.finalAssets(AssetsType.LDTK, ldtk, 1);
		}
	}
}
