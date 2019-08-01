package async;

import utest.Assert;
import hxasync.*;

class TestAsyncAwait extends BaseCase implements IAsyncable {

	@:async
	public function testAwaitReturnTypeResult() {
		var strResult = @:await Task.forResult("string");
		var intResult:Int;
		intResult = @:await Task.forResult(123);
		var awaitResult = new AwaitResult();
		var objResult:AwaitResult = @:await Task.forResult(awaitResult);

		Assert.is(strResult, String);
		Assert.equals("string", strResult);

		Assert.is(intResult, Int);
		Assert.equals(123, intResult);

		Assert.is(objResult, AwaitResult);
		Assert.equals(awaitResult, objResult);
	}

	@:async
	public function testAssignAwaitInBlock() {
		var i = 1;
		i = {
			i += 1;
			@:await Task.forResult(i + 1);
		}
		Assert.equals(3, i);

		var i = 1;
		i = @:mergeBlock {
			i += 1;
			@:await Task.forResult(i + 1);
		}
		Assert.equals(3, i);

		var i = {
			var i = 1;
			@:await Task.forResult(i + 1);
		}
		Assert.equals(2, i);

		var i = @:mergeBlock {
			var i = 1;
			@:await Task.forResult(i + 1);
		}
		Assert.equals(2, i);
	}

	@:async
	public function testAwaitReturnResult() {
		var result = null;

		result = @:await getAwaitWithResult();
		Assert.notNull(result);
		Assert.is(result, AwaitResult);
		result = null;

		Assert.isNull(result);

		result = @:await getResult();
		Assert.notNull(result);
		Assert.is(result, AwaitResult);
	}

	@:async
	public function testAwaitResultOperations() {
		var float:Float = 0.1;
		var int:Int = 5;

		float = @:await Task.forResult(5);
		Assert.equals(5, float);

		float += @:await Task.forResult(2);
		Assert.notEquals(5, float);

		float -= @:await Task.forResult(2);
		Assert.equals(5, float);

		float /= @:await Task.forResult(5);
		Assert.equals(1, float);

		float *= @:await Task.forResult(5);
		Assert.equals(5, float);

		float %= @:await Task.forResult(1);
		Assert.equals(0, float);

		int <<= @:await Task.forResult(2);
		Assert.equals(20, int);

		int >>= @:await Task.forResult(1);
		Assert.equals(10, int);

		int >>>= @:await Task.forResult(2);
		Assert.equals(2, int);

		int |= @:await Task.forResult(6);
		Assert.equals(6, int);

		int &= @:await Task.forResult(3);
		Assert.equals(2, int);

		int ^= @:await Task.forResult(3);
		Assert.equals(1, int);
	}

	@:async
	public function testAwaitBinOp() {
		var int = 2 + @:await Task.forResult(1) + 3;
		Assert.equals(6, int);

		var int = @:await Task.forResult(2) * @:await Task.forResult(4);
		Assert.equals(8, int);

		var int = @:await getBinopResult(1, 3);
		Assert.equals(4, int);

		var bool = false || @:await Task.forResult(true);
		Assert.isTrue(bool);

		var bool = true && @:await Task.forResult(false);
		Assert.isFalse(bool);

		var bool = 123 > @:await Task.forResult(999);
		Assert.isFalse(bool);

		var bool = 123 < @:await Task.forResult(999);
		Assert.isTrue(bool);

		var bool = 123 == @:await Task.forResult(999);
		Assert.isFalse(bool);

		var bool = 123 != @:await Task.forResult(999);
		Assert.isTrue(bool);
	}

	@:async
	public function testBoolNot() {
		var bool = !@:await Task.forResult(true);
		Assert.isFalse(bool);

		var bool = !@:await Task.forResult(true) || !@:await Task.forResult(false);
		Assert.isTrue(bool);
	}

	@:async
	public function testAwaitArgument() {
		function fn(a:Int, b:String) return a + b.length;

		var result = fn(@:await Task.forResult(1), @:await Task.forResult('123'));

		Assert.equals(4, result);
	}

	@:async
	public function testAwaitWithAwait() {
		function fn(a:Int, b:String) return Task.forResult(a + b.length);
		var result = @:await fn(@:await Task.forResult(1), @:await Task.forResult('123'));
		Assert.equals(4, result);

		var result = @:await @:await Task.forResult(Task.forResult(2));
		Assert.equals(2, result);
	}

	@:async
	public function testAwaitInNew() {
		var test = new AwaitResult(@:await Task.forResult(10));
		Assert.equals(10, test.value);
	}

	@:async
	public function testAwaitInField_read() {
		var fn = function(i:Int) return [i];
		Assert.equals(1, fn(@:await Task.forResult(10)).length);
	}

	@:async
	public function testAwaitInField_call() {
		var fn = function(i:Int) return [i];
		Assert.equals(10, fn(@:await Task.forResult(10)).pop());
	}

	@:async
	public function testAwaitLinearFlow() {
		var flag1 = "await1";
		var flag2 = "await2";
		var flag3 = "await3";
		var flowFlags = [flag1];

		@:await getResult();
		Assert.contains(flag1, flowFlags);
		Assert.notContains(flag2, flowFlags);
		Assert.notContains(flag3, flowFlags);
		flowFlags.push(flag2);

		@:await getAwaitWithResult();
		Assert.contains(flag1, flowFlags);
		Assert.contains(flag2, flowFlags);
		Assert.notContains(flag3, flowFlags);
		flowFlags.push(flag3);

		@:await getAwaitWithResult();
		Assert.contains(flag1, flowFlags);
		Assert.contains(flag2, flowFlags);
		Assert.contains(flag3, flowFlags);
	}

	@:async
	public function testAsyncGenericMethod() {
		var result = @:await genericMethod(10);
		Assert.equals(10, result);
	}

	@:async
	function genericMethod<T>(value:T):Task<T> {
		var result:T = value;
		return @:await Task.forResult(result);
	}

	@:async
	function getAwaitWithResult():Task<AwaitResult> {
		return @:await Task.forResult(new AwaitResult());
	}

	@:async
	function getResult():Task<AwaitResult> {
		return new AwaitResult();
	}

	@:async
	function getBinopResult(a:Int, b:Int):Task<Int> {
		return a + @:await Task.forResult(b);
	}

	@:async
	public function testAsyncLocalVarHasSameNameAsArg() {
		Assert.equals(1, @:await localVarWithSameNameAsArg('1'));
	}

	@:async
	function localVarWithSameNameAsArg(arg:String):Task<Int> {
		var arg:Int = @:await Task.forResult(Std.parseInt(arg));
		return arg;
	}
}

class AwaitResult {
	public var value:Int = 0;
	public function new(arg:Int = 0) value = arg;
}
