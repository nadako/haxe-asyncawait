package async;

import hxasync.Task;
import utest.Assert;

class TestAsyncFor extends BaseCase implements IAsyncable {

	@:async
	public function testForWithIntervals() {
		var counter = 0;

		for (i in 1...10) {
			@:await Task.forResult(null);
			Assert.equals(i, ++counter);
		}
		Assert.equals(10, ++counter);
	}

	@:async
	public function testBreakInForWithIntervals() {
		var counter = 0;

		for (i in 1...10) {
			@:await Task.forResult(null);
			counter++;
			break;
		}
		Assert.equals(1, counter);
	}

	@:async
	public function testContinueInForWithIntervals() {
		var counter = 0;
		var continueCounter = 0;

		for (i in 1...10) {
			@:await Task.forResult(null);
			continueCounter++;
			continue;
			counter++;
		}
		Assert.equals(10, ++continueCounter);
		Assert.equals(0, counter);
	}

	@:async
	public function testForReturnResultWithIntervals() {
		var result = 5;

		result = @:await getResultFromForWithIntervals(result);
		Assert.equals(15, result);

		result = @:await getResultFromForWithIntervals(result);
		Assert.equals(55, result);
	}

	@:async
	public function testForWithIterable() {
		var iter = [1, 2, 3, 4, 5, 6, 7, 8, 9];
		var counter = 0;

		for (item in iter) {
			@:await Task.forResult(null);
			Assert.equals(item, ++counter);
		}
		Assert.equals(iter.length, counter);
	}

	@:async
	public function testBreakInForWithIterable() {
		var iter = [1, 2, 3, 4, 5, 6, 7, 8, 9];
		var counter = 0;

		for (item in iter) {
			@:await Task.forResult(null);
			counter++;
			break;
		}
		Assert.equals(1, counter);
	}

	@:async
	public function testContinueInForWithIterable() {
		var iter = [1, 2, 3, 4, 5, 6, 7, 8, 9];
		var counter = 0;
		var continueCounter = 0;

		for (item in iter) {
			@:await Task.forResult(null);
			continueCounter++;
			continue;
			counter++;
		}
		Assert.equals(iter.length, continueCounter);
		Assert.equals(0, counter);
	}

	@:async
	public function testForReturnResultWithIterable() {
		var result = 5;

		result = @:await getResultFromForWithIterable(result);
		Assert.equals(15, result);

		result = @:await getResultFromForWithIterable(result);
		Assert.equals(55, result);
	}

	@:async
	private function getResultFromForWithIntervals(element:Int):Task<Int> {
		var counter = 0;
		var list = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
		for (i in 0...list.length) {
			counter += @:await Task.forResult(list[i]);
			if (list[i] == element) return counter;
		}
		return counter;
	}

	@:async
	private function getResultFromForWithIterable(element:Int):Task<Int> {
		var counter = 0;
		var list = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
		for (item in list) {
			counter += @:await Task.forResult(item);
			if (item == element) return counter;
		}
		return counter;
	}

}
