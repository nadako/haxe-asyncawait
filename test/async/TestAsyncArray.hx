package async;

import utest.Assert;
import hxasync.*;

class TestAsyncArray extends BaseCase implements IAsyncable {

	@:async
	public function testAwaitInArrayDeclaration() {
		var a:Array<Int> = [1, @:await Task.forResult(2)];
		Assert.same([1, 2], a);
	}

	@:async
	public function testAwaitInArrayDeclaration_behindAnotherAwait() {
		var a:Array<Int> = @:await Task.forResult([1, @:await Task.forResult(2)]);
		Assert.same([1, 2], a);
	}

	@:async
	public function testAwaitInArrayAccess() {
		var a:Array<Int> = [1, 2];
		var item = a[@:await Task.forResult(1)];
		Assert.same(2, item);
	}
}

