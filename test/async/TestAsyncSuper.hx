package async;

import utest.Assert;

class TestAsyncSuper extends BaseCase implements IAsyncable {
	@:async
	public function testSuperMethodVoid() {
		var test = new ChildClass();
		test.methodVoid();
		Assert.pass();
	}

	@:async
	public function testSuperMethod() {
		var test = new ChildClass();
		var result = @:await test.method();
		Assert.equals(30, result);
	}
}


private class ParentClass implements IAsyncable {
	public function new() {}

	public function methodVoid() {}

	@:async
	public function method():Task<Int> {
		return @:await Task.forResult(10);
	}

	@:async
	public function genericMethod<T>(v:T):Task<T> {
		return @:await Task.forResult(v);
	}
}

private class ChildClass extends ParentClass {
	@:async
	override public function methodVoid() {
		super.method();
		@:await Task.forResult(10);
	}

	@:async
	override public function method():Task<Int> {
		var result = @:await super.method();
		return result + 20;
	}
}