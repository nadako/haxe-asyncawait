package async;

import hxasync.IAwaitable.AwaitableIdGenerator;
import utest.Assert;
import hxasync.*;

class TestIAwaitable extends BaseCase implements IAsyncable {
	@:async
	public function testVarAwait() {
		var awaitable = new DummyAwaiter(1);
		var result = @:await awaitable;
		Assert.equals(1, result);
	}

	@:async
	public function testAssign() {
		var awaitable = new DummyAwaiter(1);
		var result;
		result = @:await awaitable;
		Assert.equals(1, result);
	}

	@:async
	public function testReturnAwait() {
		Assert.equals(1, @:await returnAwait());
	}

	@:async
	function returnAwait():Task<Int> {
		var awaitable = new DummyAwaiter(1);
		return @:await awaitable;
	}
}

private class DummyAwaiter implements IAwaitable<Int> {
	public var id(default,null):Int = 0;
	var task:Task<Int>;

	public function new(result:Int) {
		id = AwaitableIdGenerator.nextId();
		task = Task.forResult(result);
	}

	public function getAwaiter():Task<Int> {
		return task;
	}
}