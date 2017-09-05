// Generated by Haxe 4.0.0 (git build development @ 3764ebc)
(function () { "use strict";
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var Main = function() { };
Main.getNumber = function(cb) {
	cb(++Main.nextNumber);
};
Main.getNumberP = function() {
	return new Promise(function(resolve,_) {
		Main.getNumber(resolve);
		return;
	});
};
Main.test = function(n,cont) {
	cont("hi " + n + " times");
};
Main.main = function() {
	(function(n,__continuation) {
		var __state = 0;
		var tmp0;
		var tmp1;
		var v;
		var tmp2;
		var tmp3;
		var tmp4;
		var __stateMachine = null;
		__stateMachine = function(__result) {
			while(true) switch(__state) {
			case 0:
				console.log("Main.hx:18:","hi");
				v = 0;
				__state = 1;
				break;
			case 1:
				v += 1;
				if(v - 1 < 10) {
					__state = 2;
				} else {
					__state = 5;
				}
				break;
			case 2:
				__state = 3;
				Main.getNumber(__stateMachine);
				return;
			case 3:
				tmp0 = __result;
				__state = 4;
				Main.test(tmp0,__stateMachine);
				return;
			case 4:
				tmp1 = __result;
				console.log("Main.hx:21:",tmp1);
				__state = 1;
				break;
			case 5:
				__state = 6;
				Main.getNumber(__stateMachine);
				return;
			case 6:
				tmp2 = __result;
				__state = 7;
				Main.getNumberP().then(__stateMachine);
				return;
			case 7:
				tmp3 = __result;
				v = tmp2 + tmp3;
				__state = 8;
				Main.getNumber(__stateMachine);
				return;
			case 8:
				tmp4 = __result;
				__state = -1;
				__continuation(n + v + tmp4);
				return;
			default:
				throw new js__$Boot_HaxeError("Invalid state");
			}
		};
		__stateMachine(null);
	})(10,function(value) {
		console.log("Main.hx:26:","Result: " + value);
		return;
	});
};
var js__$Boot_HaxeError = function(val) {
	Error.call(this);
	this.val = val;
	this.message = String(val);
	if(Error.captureStackTrace) {
		Error.captureStackTrace(this,js__$Boot_HaxeError);
	}
};
js__$Boot_HaxeError.wrap = function(val) {
	if((val instanceof Error)) {
		return val;
	} else {
		return new js__$Boot_HaxeError(val);
	}
};
js__$Boot_HaxeError.__super__ = Error;
js__$Boot_HaxeError.prototype = $extend(Error.prototype,{
});
Main.nextNumber = 0;
Main.main();
})();
