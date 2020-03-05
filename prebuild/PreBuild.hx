package prebuild;
class PreBuild {
	public static function main() {
        final hxml = sys.io.File.getContent("./haxe-libraries/hxdbc.hxml");
        final classPathParser = ~/-cp (.*)/gi;
        if(classPathParser.match(hxml)) {
            final path = classPathParser.matched(1);
            final info = getProjectInfoFromSrcPath(path);
            trace(haxe.Json.stringify(info));
        }
    }
    static function getProjectInfoFromSrcPath(path) {
        var retVal:Dynamic = {};
        var pathParts = haxe.io.Path.normalize(path).split("/");
        var basePathLength = 4;
        retVal.projectName = pathParts[1];
        retVal.projectVer = pathParts[2];
        retVal.projectLoc = pathParts[3];
        retVal.gitHash = "";
        if(projectLoc.toLowerCase() == "github") {
        	retVal.gitHash = pathParts[4];    
            basePathLength=5;
        }
        retVal.basePath = pathParts.slice(0, basePathLength).join('/');
        return retVal;
    }
}
