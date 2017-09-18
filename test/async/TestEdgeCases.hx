package async;

import utest.Assert;

class TestEdgeCases extends BaseCase implements IAsyncable {
	@:async
	public function testTupleCase() {
		@:await TupleCase.tupleCase();
		Assert.pass();
	}

	@:async
	public function testArrayComprehension() {
		var result:Int = [for(i in 0...2) i][0];
		Assert.equals(0, result);
	}

	@:async
	public function testStringInterpolation() {
		var v = 'world';
		Assert.equals('hello, world', 'hello, $v');
	}

	@:async
	public function testAsyncGenerciMethodWithConstraints() {
		var result = @:await genericMethodWithConstraints(ConstraintTest);
		Assert.equals(ConstraintTest, result);
	}

	@:async
	@:access(hxasync.v2.async.MetaTest)
	public function testThirdPartyMeta() {
		Assert.isTrue(MetaTest.privateVar);
	}

	@:async
	function genericMethodWithConstraints<T:(IFace1,IFace2)>(cls:Class<T>):Task<Class<T>> {
		return @:await Task.forResult(cls);
	}
}


private class Tuple2<T1, T2> {
	public var item1:T1;
	public var item2:T2;

	public function new(item1:T1, item2:T2) {
		this.item1 = item1;
		this.item2 = item2;
	}
}

private class TupleCase implements IAsyncable {
	@:async
	public static function tupleCase():Task<Unit> {
		var data:Tuple2<Int, Int> = @:await Task.call(function()return new Tuple2(10, 20));
		Assert.equals(10, data.item1);
		Assert.equals(20, data.item2);
	}
}


private interface IFace1 {}
private interface IFace2 {}
private class ConstraintTest implements IFace1 implements IFace2 {}
private class MetaTest {
	static var privateVar = true;
}