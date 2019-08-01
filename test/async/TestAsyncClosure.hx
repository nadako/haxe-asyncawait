package async;

import utest.Assert;

class TestAsyncClosure extends BaseCase implements IAsyncable {

	@:async
	public function testLoopVarNameReuseInClosure() {
		for(a in [0, 1, 2]) {}

		var fn = [];
		for(a in [0, 1, 2]) {
			fn.push(function() {
				var a1 = 0;
				return a + a1;
			});
		}

		Assert.equals(0, fn[0]());
	}

	@:async
	public function testNestedClosures() {
		var normalClosures = [];
		var asyncClosures = [];
		for(i in 0...3) {
			normalClosures.push(function() {
				return function() {
					return i;
				};
			});
			asyncClosures.push(@:async function() {
				return @:async function() {
					return i;
				};
			});
		}

		Assert.equals(0, normalClosures[0]()());
		Assert.equals(0, @:await (@:await asyncClosures[0]())());
	}

	@:async
	public function testAsyncMethodWithNormalClosure() {
		var a = 10;
		function fn1(arg) return arg + a;
		var fn2 = function(arg) return arg + a;
		Assert.equals(22, fn1(1) + fn2(1));
	}

	@:async
	public function testAsyncClosure() {
		var fn = @:async function():Task<Int> return @:await Task.forResult(10);
		Assert.equals(10, @:await fn());

		var fn = @:async function():Task<Int> {
			return @:await Task.forResult(10);
		}
		Assert.equals(10, @:await fn());
	}

	@:async
	public function testAsyncClosure_withoutReturnType() {
		var fn = @:async function() return @:await Task.forResult(10);
		Assert.equals(10, @:await fn());

		var fn = @:async function() { return @:await Task.forResult(10); }
		Assert.equals(10, @:await fn());
	}

	@:async
	public function testAsyncClosure_inNormalClosure() {
		var a = 10;
		var fn = function() {
			return @:async function():Task<Int> {
				return @:await Task.forResult(a);
			}
		}
		Assert.equals(10, @:await fn()());
	}

	@:async
	public function testNormalClosureScope_shouldNotLeakIntoAsyncContext() {
		var result = 0;
		var assert = Assert.createAsync(function() Assert.equals(2, result));

		var fn:Int->Void = null;
		var recursionLevel = 0;
		var arg = 10;
		fn = function(arg) {
			var z = arg;
			if(recursionLevel == 0) {
				++recursionLevel;
				fn(arg);
			}
			haxe.Timer.delay(function() result = ++z, 10);
		}
		fn(1);

		@:await Task.delay(100);
		Assert.equals(10, arg);
		assert();
	}

	@:async
	public function testLocalVarScopeInFor_overIntRange() {
		var normalClosures = [];
		var asyncClosures = [];
		var asyncClosures = [];
		var assert = Assert.createAsync(@:async function() {
			Assert.equals(100, normalClosures[0]());
			Assert.equals(100, @:await asyncClosures[0]());
		});

		for(i in 0...2) {
			var a = i;
			var b = -1;
			@:await Task.delay(1);
			normalClosures.push(function() { return a + b; });
			asyncClosures.push(@:async function() return a + b);
			@:await Task.delay(1);
			b = 100;
		}

		assert();
	}

	@:async
	public function testLocalVarScopeInFor_overIterator() {
		var normalClosures = [];
		var asyncClosures = [];
		var assert = Assert.createAsync(@:async function() {
			Assert.equals(100, normalClosures[0]());
			Assert.equals(100, @:await asyncClosures[0]());
		});

		var it = 0...2;
		for(i in it) {
			var a = i;
			var b = -1;
			@:await Task.delay(1);
			normalClosures.push(function() return a + b);
			asyncClosures.push(@:async function() return a + b);
			@:await Task.delay(1);
			b = 100;
		}

		assert();
	}

	@:async
	public function testLocalVarScopeInWhile() {
		var normalClosures = [];
		var asyncClosures = [];
		var assert = Assert.createAsync(@:async function() {
			Assert.equals(100, normalClosures[0]());
			Assert.equals(100, @:await asyncClosures[0]());
		});

		var i = 0;
		while(i < 2) {
			var a = i;
			var b = -1;
			@:await Task.delay(1);
			normalClosures.push(function() return a + b);
			asyncClosures.push(@:async function() return a + b);
			@:await Task.delay(1);
			b = 100;
			++i;
		}

		assert();
	}

	@:async
	public function testLocalVarScopeInDoWhile() {
		var normalClosures = [];
		var asyncClosures = [];
		var assert = Assert.createAsync(@:async function() {
			Assert.equals(100, normalClosures[0]());
			Assert.equals(100, @:await asyncClosures[0]());
		});

		var i = 0;
		do {
			var a = i;
			var b = -1;
			@:await Task.delay(1);
			normalClosures.push(function() return a + b);
			asyncClosures.push(@:async function() return a + b);
			@:await Task.delay(1);
			b = 100;
			++i;
		} while(i < 2);

		assert();
	}

	@:async
	public function testLocalVarScopeInNestedLoop() {
		var normalClosures = [];
		var asyncClosures = [];
		var assert = Assert.createAsync(@:async function() {
			Assert.equals(100, normalClosures[0]());
			Assert.equals(100, @:await asyncClosures[0]());
		});

		for(i in 0...2) {
			var a = i;
			@:await Task.delay(1);
			for(j in 0...2) {
				var b = -1;
				normalClosures.push(function() return a + b);
				asyncClosures.push(@:async function() return a + b);
				@:await Task.delay(1);
				b = 100;
			}
		}

		assert();
	}
}