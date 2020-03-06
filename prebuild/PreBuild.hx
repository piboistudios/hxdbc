package prebuild;

using StringTools;

class PreBuild {
    static var lixLibCachePath = Sys.getEnv("HAXE_LIBCACHE");
    public static function run(haxelib, nativelib, buildCmd, haxelibsDir = "haxe_libraries") {
        _run({
            haxelib: haxelib,
            nativelib: nativelib,
            buildCmd: buildCmd,
            haxelibsDir: haxelibsDir,
            nativePath: nativelib
        })
    }
	public static function _run(config:Dynamic) {
        if(config.nativePath == null) {
            var ammerLibPath = 'ammer.lib.${config.nativelib}.library';
            if(haxe.macro.Context.defined(ammerLibPath)) {
                config.nativePath = haxe.macro.Context.definedValue(ammerLibPath);
            }
        }
        if(lixLibCachePath != null && lixLibCachePath.length != 0) {

            var lixHxmlPath = './${config.haxeLibsDir}/${config.haxelib}.hxml';
            if (sys.FileSystem.exists(lixHxmlPath)) {
                config.lixHxmlPath = lixHxmlPath;
                runLixBuild(config);
                return;
            } 
        }
        runHaxelibBuild(config);
		return;
	}

	static function runLixBuild(config:Dynamic) {
		final hxml = sys.io.File.getContent(config.lixHxmlPath);
		final classPathParser = ~/-cp (.*)/gi;
		if (classPathParser.match(hxml)) {
            final path = classPathParser.matched(1);
            try {

                final info = getProjectInfoFromSrcPath(path);
                build(config, info.basePath);
            } catch(e:Dynamic) {
                trace('Could not build ${config.lixHxmlPath}.hxml');
                trace('ERROR: $e');
            }
		}
	}

	static function runHaxelibBuild(config:Dynamic) {
		final haxelibPath = Sys.getEnv("HAXELIB_PATH");
		final thisLibPath = '$haxelibPath/${config.haxelib}';
		final currentFilePath = '$thisLibPath/.current';
		if (sys.FileSystem.exists(currentFilePath)) {
            try {

                build(config, '$thisLibPath/${~/\\./gi.replace(sys.io.File.getContent(currentFilePath), ',')}');
            } catch(e:Dynamic) {
                trace('Could not locate \'${config.haxelib}.hxml\' in HAXELIB_PATH.');
                trace('ERROR: $e');
            }
		}
	}

	static function build(config, libraryPath) {
		final userCwd = Sys.getCwd();
		Sys.setCwd(libraryPath + '/${config.nativePath}');
		new sys.io.Process(config.buildCmd).exitCode(true);
		Sys.setCwd(userCwd);
	}

	static function getProjectInfoFromSrcPath(path) {
		var retVal:Dynamic = {};
		var pathParts = haxe.io.Path.normalize(path).split("/");
		var basePathLength = 4;
		retVal.name = pathParts[1];
		retVal.version = pathParts[2];
		retVal.source = pathParts[3];
		retVal.git = {hash: ""};
		if (retVal.source.toLowerCase() == "github") {
			retVal.git.hash = pathParts[4];
			basePathLength = 5;
		}
		retVal.basePath = pathParts.slice(0, basePathLength).join('/').replace("${HAXE_LIBCACHE}", Sys.getEnv("HAXE_LIBCACHE"));
		return retVal;
	}
}
