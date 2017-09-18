package async;

import hxasync.Task;
import utest.Assert;

class TestAsyncParentheses extends BaseCase implements IAsyncable {

	@:async
	public function testParentheses_inBinaryOperations() {
		var result = 1 - (2 - @:await Task.forResult(3)) + 1;
		Assert.equals(3, result);
	}

	@:async
	public function testParentheses_inUnaryOperations() {
		var result = !(@:await Task.forResult(false));
		Assert.isTrue(result);
	}
}
