package async;

import hxasync.Task;
import utest.Assert;

class TestAsyncWhile extends BaseCase implements IAsyncable {

	@:async
	public function testNormalWhile() {
		var counter = 0;

		while(counter < 10) {
			Assert.notEquals(10, counter);
			@:await Task.forResult(null);
			counter++;
		}
		Assert.equals(10, counter);
	}

	@:async
	public function testBreakInNormalWhile() {
		var counter = 0;

		while(counter < 10) {
			@:await Task.forResult(null);
			counter++;
			break;
		}
		Assert.equals(1, counter);
	}

	@:async
	public function testContinueInNormalWhile() {
		var counter = 0;
		var continueCounter = 0;

		while(continueCounter < 10) {
			@:await Task.forResult(null);
			continueCounter++;
			continue;
			counter++;
		}
		Assert.equals(10, continueCounter);
		Assert.equals(0, counter);
	}

	@:async
	public function testNormalWhileReturnResult() {
		var result = 5;

		result = @:await getResultFromNormalWhile(result);
		Assert.equals(15, result);

		result = @:await getResultFromNormalWhile(result);
		Assert.equals(45, result);

		result = @:await getResultFromNormalWhile(result, 10);
		Assert.equals(0, result);
	}

	@:async
	public function testNotNormalWhile() {
		var counter = 0;

		do {
			@:await Task.forResult(null);
			counter++;
		} while(counter < 10);
		Assert.equals(10, counter);

		do {
			@:await Task.forResult(null);
			counter++;
		} while(counter < 10);
		Assert.notEquals(10, counter);
	}

	@:async
	public function testBreakInNotNormalWhile() {
		var counter = 0;

		do {
			@:await Task.forResult(null);
			counter++;
			break;
		} while(counter < 10);
		Assert.equals(1, counter);
	}

	@:async
	public function testContinueInNotNormalWhile() {
		var counter = 0;
		var continueCounter = 0;

		do {
			@:await Task.forResult(null);
			continueCounter++;
			continue;
			counter++;
		} while(continueCounter < 10);
		Assert.equals(10, continueCounter);
		Assert.equals(0, counter);
	}

	@:async
	public function testNotNormalWhileReturnResult() {
		var result = 5;

		result = @:await getResultFromNotNormalWhile(result);
		Assert.equals(15, result);

		result = @:await getResultFromNotNormalWhile(result);
		Assert.equals(45, result);

		result = @:await getResultFromNotNormalWhile(result, 10);
		Assert.equals(10, result);
	}

	@:async
	public function testAwaitInCondition() {
		var condition = 3;
		var result = 0;
		while(@:await Task.forResult(--condition > 0)) {
			result++;
		}
		Assert.equals(2, result);

		var condition = 3;
		var result = 0;
		do {
			result++;
		} while(@:await Task.forResult(--condition > 0));
		Assert.equals(3, result);
	}

// private section

	@:async
	private function getResultFromNormalWhile(element:Int, ?startCount:Int = 0):Task<Int> {
		var counter = startCount;
		var outcome = 0;
		while (counter < 10) {
			outcome += counter;
			if (counter == element) {
				return @:await Task.forResult(outcome);
			}
			counter++;
		}
		return outcome;
	}

	@:async
	private function getResultFromNotNormalWhile(element:Int, ?startCount:Int = 0):Task<Int> {
		var counter = startCount;
		var outcome = 0;
		do {
			outcome += counter;
			if (counter == element) {
				return @:await Task.forResult(outcome);
			}
			counter++;
		} while(counter < 10);
		return outcome;
	}

}
