class Utils {
    public static macro function  attempt(expr:haxe.macro.Expr){

        return macro try {
            $expr;
            true;
        } catch(e:Any) {
            trace(e);
            false;
        };
    
} 
}