package async;

import hxasync.Task;
import utest.Assert;

class TestAsyncIf extends BaseCase implements IAsyncable {

	@:async
	public function testIfElse() {
		var cond = false;
		var result = 0;

		if (cond) {
			result += @:await Task.forResult(1);
		}
		Assert.equals(0, result);

		if (cond || result == 0) {
			result += @:await Task.forResult(1);
			result *= 5;
		} else {
			result += @:await Task.forResult(10);
		}
		Assert.equals(5, result);
	}

	@:async
	public function testIfElseReturnResult() {
		var result = 0;

		result = @:await getResultFromIf(true);
		Assert.equals(7, result);

		result += @:await getResultFromIf(false);
		Assert.equals(20, result);
	}

	@:async
	public function testIfWithElseIf() {
		var rand = Math.floor(Math.random() * 10);
		var result = 0;

		if (rand < 5) {
			result = @:await Task.forResult(rand);
		} else if (rand == 5) {
			result = 5;
		} else if (rand > 5 && rand < 8) {
			result = rand;
		} else {
			rand = @:await Task.forResult(0);
		}
		Assert.equals(rand, result);
	}

	@:async
	public function testIfWithElseIfReturnResult() {
		var result = 0;

		result = @:await getResultFromIfElseIf(result);
		Assert.equals(5, result);

		result = @:await getResultFromIfElseIf(result);
		Assert.equals(7, result);

		result = @:await getResultFromIfElseIf(result);
		Assert.equals(13, result);

		result = @:await getResultFromIfElseIf(result);
		Assert.equals(0, result);
	}

	@:async
	public function testAwaitCondition() {
		var result = @:await getResultAwaitCondition(true);
		Assert.isTrue(result);

		var result = @:await getResultAwaitCondition(false);
		Assert.isFalse(result);
	}

	@:async public function testTernary() {
		var result = @:await Task.forResult(true) ? @:await Task.forResult(10) : 0;
		Assert.equals(10, result);

		var result = @:await Task.forResult(false) ? 0 : @:await Task.forResult(10);
		Assert.equals(10, result);
	}

// private section

	@:async
	private function getResultFromIf(cond:Bool):Task<Int> {
		@:await Task.forResult(null);
		if (cond) {
			return @:await Task.forResult(7);
		} else {
			return 13;
		}
	}

	@:async
	private function getResultFromIfElseIf(value:Int):Task<Int> {
		if (value < 5) {
			return @:await Task.forResult(5);
		} else if (value == 5) {
			var outcome = @:await Task.forResult(value);
			outcome *= @:await Task.forResult(2);
			outcome -= 3;
			return outcome;
		} else if (value > 5 && value < 8) {
			return 13;
		} else {
			return @:await Task.forResult(0);
		}
	}

	@:async
	private function getResultAwaitCondition(cond:Bool):Task<Bool> {
		if (@:await Task.forResult(cond)) {
			return true;
		} else {
			return false;
		}
	}

}
