package async;

import hxasync.Task;
import Math;
import utest.Assert;

class TestAsyncSwitch extends BaseCase implements IAsyncable {

	@:async
	public function testSwitchWithoutDefault() {
		var result = 0;
		var random = Math.round(Math.random() * 9 + 1);

		switch (random) {
			case _:
				result = @:await Task.forResult(random);
		}
		Assert.equals(random, result);
	}

	@:async
	public function testSwitchWithDefault() {
		var result = 0;
		var random = Math.round(Math.max((Math.random() * 9 + 1), 5));

		switch (random) {
			case 1:
				result = @:await Task.forResult(100);
			case 2, 3, 4:
				// do nothing
			default:
				result = @:await Task.forResult(random);
		}
		Assert.equals(random, result);
	}

	@:async
	public function testSwitchReturnResult() {
		var result = 0;

		result = @:await getResultFromSwitch(result);
		Assert.equals(6, result);

		result = @:await getResultFromSwitch(result);
		Assert.equals(4, result);

		result = @:await getResultFromSwitch(result);
		Assert.equals(8, result);

		result = @:await getResultFromSwitch(result);
		Assert.equals(8, result);
	}

	@:async
	public function testSwitchReturnResultWithGuards() {
		var result = 0;

		result = @:await getResultFromSwitchWithGuards(result, false);
		Assert.equals(0, result);

		result = @:await getResultFromSwitchWithGuards(result);
		Assert.equals(6, result);

		result = @:await getResultFromSwitchWithGuards(result);
		Assert.equals(4, result);

		result = @:await getResultFromSwitchWithGuards(result);
		Assert.equals(8, result);

		result = @:await getResultFromSwitchWithGuards(result);
		Assert.equals(0, result);
	}

	@:async public function testAwaitSwitchCondition() {
		switch(@:await Task.forResult(true)) {
			case true: Assert.pass();
			case false: Assert.fail();
		}

		switch(@:await Task.forResult(false)) {
			case true: Assert.fail();
			case false: Assert.pass();
		}
	}

// private section

	@:async
	private function getResultFromSwitch(subject:Int):Task<Int> {
		switch (subject) {
			case 0, 1, 2, 3:
				return 6;
			case 4:
				return 8;
			case 5, 6:
				return @:await Task.forResult(4);
			case _:
				return @:await Task.forResult(subject);
		}
	}

	@:async
	private function getResultFromSwitchWithGuards(subject:Int, ?cond:Bool = true):Task<Int> {
		switch (subject) {
			case 0, 1, 2, 3 if (cond):
				return 6;
			case 4 if (cond):
				return 8;
			case 4 if (!cond):
				return 7;
			case 5, 6:
				return @:await Task.forResult(4);
			case _ if (subject < 9 && subject > 7):
				return 0;
			case _:
				return @:await Task.forResult(subject);
		}
	}

}
