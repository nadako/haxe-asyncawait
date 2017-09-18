package async;

import utest.Assert;
import hxasync.*;

class TestAsyncCast extends BaseCase implements IAsyncable {

	@:async
	public function testUntypedCast() {
		var result:Int = cast @:await Task.forResult(10);
		Assert.equals(10, result);
	}

	@:async
	public function testTypedCast() {
		var result = cast(@:await Task.forResult(this), TestAsyncCast);
		Assert.equals(this, result);
	}
}