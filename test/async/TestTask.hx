package async;

import hxasync.executors.TimerTaskExecutor;
import utest.Assert;
import hxasync.Task;
import hxasync.TaskCompletionSource;
import hxasync.TaskCanceledException;

class TestTask extends BaseCase implements IAsyncable {

	public function testPrimitives() {
		var complete = Task.forResult(5);
		var error = Task.forError("task error");
		var cancelled = Task.cancelled();

		Assert.isTrue(complete.isCompleted);
		Assert.equals(5, complete.result);
		Assert.isFalse(complete.isFaulted);
		Assert.isFalse(complete.isCancelled);
		Assert.isTrue(complete.isSuccessed);

		Assert.isTrue(error.isCompleted);
		Assert.is(error.error, String);
		Assert.equals("task error", error.error);
		Assert.isTrue(error.isFaulted);
		Assert.isFalse(error.isCancelled);
		Assert.isFalse(error.isSuccessed);

		Assert.isTrue(cancelled.isCompleted);
		Assert.isFalse(cancelled.isFaulted);
		Assert.isTrue(cancelled.isCancelled);
		Assert.isFalse(cancelled.isSuccessed);
	}

	public function testSynchronousContinuation() {
		var complete = Task.forResult(5);
		var error = Task.forError("task error");
		var cancelled = Task.cancelled();

		var completeHandled = false;
		var errorHandled = false;
		var cancelledHandled = false;

		complete.continueWith(function(task:Task<Int>) {
			Assert.same(complete, task);
			Assert.isTrue(task.isCompleted);
			Assert.equals(5, task.result);
			Assert.isFalse(task.isFaulted);
			Assert.isFalse(task.isCancelled);
			Assert.isTrue(task.isSuccessed);
			completeHandled = true;
		});

		error.continueWith(function(task:Task<Int>) {
			Assert.same(error, task);
			Assert.isTrue(task.isCompleted);
			Assert.is(task.error, String);
			Assert.equals("task error", task.error);
			Assert.isTrue(task.isFaulted);
			Assert.isFalse(task.isCancelled);
			Assert.isFalse(task.isSuccessed);
			Assert.isNull(task.result);
			errorHandled = true;
		});

		cancelled.continueWith(function(task : Task<Int>) {
			Assert.same(cancelled, task);
			Assert.isTrue(task.isCompleted);
			Assert.isFalse(task.isFaulted);
			Assert.isTrue(task.isCancelled);
			Assert.isFalse(task.isSuccessed);
			cancelledHandled = true;
		});

		Assert.isTrue(completeHandled);
		Assert.isTrue(errorHandled);
		Assert.isTrue(cancelledHandled);
	}

	public function testSynchronousChaining() {
		var first = Task.forResult(1);
		var second = first.continueWith(function(task:Task<Int>):Int {
			return 2;
		});
		var third = second.continueWithTask(function(task:Task<Int>):Task<Int> {
			return Task.forResult(3);
		});

		Assert.isTrue(first.isCompleted);
		Assert.isTrue(second.isCompleted);
		Assert.isTrue(third.isCompleted);

		Assert.equals(1, first.result);
		Assert.equals(2, second.result);
		Assert.equals(3, third.result);
	}

	public function testSynchronousCancellation() {
		var first = Task.forResult(1);
		var second = first.continueWith(function(task:Task<Int>):Int {
			throw new TaskCanceledException();
		});

		Assert.isTrue(first.isCompleted);
		Assert.isTrue(second.isCancelled);
	}

	public function testSynchronousTaskCancellation() {
		var first = Task.forResult(1);
		var second = first.continueWithTask(function(task:Task<Int>):Task<Int> {
			throw new TaskCanceledException();
		});

		Assert.isTrue(first.isCompleted);
		Assert.isTrue(second.isCancelled);
	}

	public function testBackgroundCall() {
		var timerExecutor = new TimerTaskExecutor(10);
		var task:Task<Int> = null;
		var done = Assert.createAsync(function() {
			Assert.equals(5, task.result);
		}, 5000);

		Task.call(function():Int {
			return 5;
		}, timerExecutor).continueWith(function(t:Task<Int>) {
			task = t;
			done();
		});
	}

	public function testBackgroundError() {
		var timerExecutor = new TimerTaskExecutor(10);
		var task:Task<Int> = null;
		var done = Assert.createAsync(function() {
			Assert.isTrue(task.isFaulted);
			Assert.is(task.error, String);
		}, 5000);

		Task.call(function():Int {
			throw "task error";
		}, timerExecutor).continueWith(function(t:Task<Int>) {
			task = t;
			done();
		});
	}

	public function testBackgroundCancellation() {
		var timerExecutor = new TimerTaskExecutor(10);
		var task:Task<Int> = null;
		var done = Assert.createAsync(function() {
			Assert.isTrue(task.isCancelled);
		}, 5000);

		Task.call(function():Int {
			throw new TaskCanceledException();
		}, timerExecutor).continueWith(function(t:Task<Int>) {
			task = t;
			done();
		});
	}

	public function testContinueOnTimerExecutor() {
		var timerExecutor = new TimerTaskExecutor(10);
		var task:Task<Int> = null;
		var done = Assert.createAsync(function() {
			Assert.equals(3, task.result);
		}, 5000);

		Task.call(function():Int {
			return 1;
		}, timerExecutor).continueWith(function(t:Task<Int>):Int {
			return t.result + 1;
		}, timerExecutor).continueWithTask(function(t:Task<Int>):Task<Int> {
			return Task.forResult(t.result + 1);
		}, timerExecutor).continueWith(function(t:Task<Int>) {
			task = t;
			done();
		});
	}

	public function testWhenAllNoTasks() {
		var task = Task.whenAll(new Array<Task<Unit>>());

		Assert.isTrue(task.isCompleted);
		Assert.isFalse(task.isFaulted);
		Assert.isFalse(task.isCancelled);
		Assert.isTrue(task.isSuccessed);
	}

	public function testWhenAnyResultFirstSuccess() {
		var task:Task<Task<Int>> = null;
		var tasks = new Array<Task<Int>>();
		var firstToCompleteSuccess = Task.call(function():Int {
			return 2000;
		}, new TimerTaskExecutor(50));
		var done = Assert.createAsync(function() {
			Assert.isTrue(task.isCompleted);
			Assert.isFalse(task.isFaulted);
			Assert.isFalse(task.isCancelled);
			Assert.isTrue(task.isSuccessed);
			Assert.same(firstToCompleteSuccess, task.result);
			Assert.isTrue(task.result.isCompleted);
			Assert.isFalse(task.result.isFaulted);
			Assert.isFalse(task.result.isCancelled);
			Assert.isTrue(task.result.isSuccessed);
			Assert.equals(2000, task.result.result);
		}, 5000);

		addTasksWithRandomCompletions(tasks, 5);
		tasks.push(firstToCompleteSuccess);
		addTasksWithRandomCompletions(tasks, 5);

		Task.whenAny(tasks).continueWith(function(t:Task<Task<Int>>) {
			task = t;
			done();
		});
	}

	public function testWhenAnyFirstSuccess() {
		var task:Task<Task<Dynamic>> = null;
		var tasks = new Array<Task<Dynamic>>();
		var firstToCompleteSuccess = Task.call(function():String {
			return "SUCCESS";
		}, new TimerTaskExecutor(50));
		var done = Assert.createAsync(function() {
			Assert.isTrue(task.isCompleted);
			Assert.isFalse(task.isFaulted);
			Assert.isFalse(task.isCancelled);
			Assert.isTrue(task.isSuccessed);
			Assert.same(firstToCompleteSuccess, task.result);
			Assert.isTrue(task.result.isCompleted);
			Assert.isFalse(task.result.isFaulted);
			Assert.isFalse(task.result.isCancelled);
			Assert.isTrue(task.result.isSuccessed);
			Assert.equals("SUCCESS", task.result.result);
		}, 5000);

		addTasksWithRandomCompletions(tasks, 5);
		tasks.push(firstToCompleteSuccess);
		addTasksWithRandomCompletions(tasks, 5);

		Task.whenAny(tasks).continueWith(function(t:Task<Task<Dynamic>>) {
			task = t;
			done();
		});
	}

	public function testWhenAnyFirstError() {
		var task:Task<Task<Dynamic>> = null;
		var error = "task error";
		var tasks = new Array<Task<Dynamic>>();
		var firstToCompleteError = Task.call(function():String {
			throw error;
		}, new TimerTaskExecutor(50));
		var done = Assert.createAsync(function() {
			Assert.isTrue(task.isCompleted);
			Assert.isFalse(task.isFaulted);
			Assert.isFalse(task.isCancelled);
			Assert.isTrue(task.isSuccessed);
			Assert.same(firstToCompleteError, task.result);
			Assert.isTrue(task.result.isCompleted);
			Assert.isTrue(task.result.isFaulted);
			Assert.isFalse(task.result.isCancelled);
			Assert.isFalse(task.result.isSuccessed);
			Assert.same(error, task.result.error);
		}, 5000);

		addTasksWithRandomCompletions(tasks, 5);
		tasks.push(firstToCompleteError);
		addTasksWithRandomCompletions(tasks, 5);

		Task.whenAny(tasks).continueWith(function(t:Task<Task<Dynamic>>) {
			task = t;
			done();
		});
	}

	public function testWhenAnyFirstCancelled() {
		var task:Task<Task<Dynamic>> = null;
		var tasks = new Array<Task<Dynamic>>();
		var firstToCompleteError = Task.call(function():String {
			throw new TaskCanceledException();
		}, new TimerTaskExecutor(50));
		var done = Assert.createAsync(function() {
			Assert.isTrue(task.isCompleted);
			Assert.isFalse(task.isFaulted);
			Assert.isFalse(task.isCancelled);
			Assert.isTrue(task.isSuccessed);
			Assert.same(firstToCompleteError, task.result);
			Assert.isTrue(task.result.isCompleted);
			Assert.isFalse(task.result.isFaulted);
			Assert.isTrue(task.result.isCancelled);
			Assert.isFalse(task.result.isSuccessed);
		}, 5000);

		addTasksWithRandomCompletions(tasks, 5);
		tasks.push(firstToCompleteError);
		addTasksWithRandomCompletions(tasks, 5);

		Task.whenAny(tasks).continueWith(function(t:Task<Task<Dynamic>>) {
			task = t;
			done();
		});
	}

	public function testWhenAllSuccess() {
		var task:Task<Unit> = null;
		var tasks = new Array<Task<Unit>>();
		var done = Assert.createAsync(function() {
			Assert.isTrue(task.isCompleted);
			Assert.isFalse(task.isFaulted);
			Assert.isFalse(task.isCancelled);
			Assert.isTrue(task.isSuccessed);
			for (t in tasks) {
				Assert.isTrue(t.isCompleted);
			}
		}, 5000);

		for (i in 0 ... 20) {
			tasks.push(Task.call(function() : Unit {
				// do nothing
				return null;
			}, new TimerTaskExecutor(randomInt(10, 50))));
		}

		Task.whenAll(tasks).continueWith(function(t:Task<Unit>) {
			task = t;
			done();
		});
	}

	public function testWhenAllOneError() {
		var task:Task<Unit> = null;
		var error = "task error";
		var tasks = new Array<Task<Unit>>();
		var done = Assert.createAsync(function() {
			Assert.isTrue(task.isCompleted);
			Assert.isTrue(task.isFaulted);
			Assert.isFalse(task.isCancelled);
			Assert.isFalse(task.isSuccessed);
			Assert.is(task.error, Array);
			Assert.equals((cast task.error:Array<Dynamic>).length, 1);
			Assert.same((cast task.error:Array<Dynamic>)[0], error);
			for (t in tasks) {
				Assert.isTrue(t.isCompleted);
			}
		}, 5000);

		for (i in 0 ... 20) {
			tasks.push(Task.call(function() : Unit {
				if (i == 10) {
					throw error;
				}
				return null;
			}, new TimerTaskExecutor(randomInt(10, 50))));
		}

		Task.whenAll(tasks).continueWith(function(t:Task<Unit>) {
			task = t;
			done();
		});
	}

	public function testWhenAllTwoErrors() {
		var task:Task<Unit> = null;
		var error0 = "task error_0";
		var error1 = "task error_1";
		var tasks = new Array<Task<Unit>>();
		var done = Assert.createAsync(function() {
			Assert.isTrue(task.isCompleted);
			Assert.isTrue(task.isFaulted);
			Assert.isFalse(task.isCancelled);
			Assert.isFalse(task.isSuccessed);
			Assert.is(task.error, Array);
			Assert.equals((cast task.error:Array<Dynamic>).length, 2);
			Assert.same((cast task.error:Array<Dynamic>)[0], error0);
			Assert.same((cast task.error:Array<Dynamic>)[1], error1);
			for (t in tasks) {
				Assert.isTrue(t.isCompleted);
			}
		}, 5000);

		for (i in 0 ... 20) {
			tasks.push(Task.call(function():Unit {
				if (i == 10) {
					throw error0;
				} else if (i == 11) {
					throw error1;
				}
				return null;
			}, new TimerTaskExecutor(10 + i * 10)));
		}

		Task.whenAll(tasks).continueWith(function(t:Task<Unit>) {
			task = t;
			done();
		});
	}

	public function testWhenAllCancel() {
		var task:Task<Unit> = null;
		var tasks = new Array<Task<Unit>>();
		var done = Assert.createAsync(function() {
			Assert.isTrue(task.isCompleted);
			Assert.isFalse(task.isFaulted);
			Assert.isTrue(task.isCancelled);
			Assert.isFalse(task.isSuccessed);
			for (t in tasks) {
				Assert.isTrue(t.isCompleted);
			}
		}, 5000);

		for (i in 0 ... 20) {
			var tcs = new TaskCompletionSource<Unit>();

			Task.call(function() {
				if (i == 10) {
					tcs.setCancelled();
				} else {
					tcs.setResult(null);
				}
			}, new TimerTaskExecutor(randomInt(10, 50)));
			tasks.push(tcs.task);
		}

		Task.whenAll(tasks).continueWith(function(t:Task<Unit>) {
			task = t;
			done();
		});
	}

	public function testWhenAllResultNoTasks() {
		var task = Task.whenAllResult(new Array<Task<Unit>>());

		Assert.isTrue(task.isCompleted);
		Assert.isFalse(task.isFaulted);
		Assert.isFalse(task.isCancelled);
		Assert.isTrue(task.isSuccessed);
		Assert.is(task.result, Array);
		Assert.equals(task.result.length, 0);
	}

	public function testWhenAllResultSuccess() {
		var task:Task<Array<Int>> = null;
		var tasks = new Array<Task<Int>>();
		var done = Assert.createAsync(function() {
			Assert.isTrue(task.isCompleted);
			Assert.isFalse(task.isFaulted);
			Assert.isFalse(task.isCancelled);
			Assert.isTrue(task.isSuccessed);
			Assert.equals(tasks.length, task.result.length);
			for (i in 0 ... tasks.length) {
				var t = tasks[i];
				Assert.isTrue(t.isCompleted);
				Assert.equals(t.result, task.result[i]);
			}
		}, 5000);

		for (i in 0 ... 20) {
			tasks.push(Task.call(function():Int {
				return (i + 1);
			}, new TimerTaskExecutor(randomInt(10, 50))));
		}

		Task.whenAllResult(tasks).continueWith(function(t:Task<Array<Int>>) {
			task = t;
			done();
		});
	}

	public function testAsyncChaining() {
		var task:Task<Unit> = null;
		var tasks = new Array<Task<Int>>();
		var sequence = new Array<Int>();
		var result = Task.forResult(null);
		var done = Assert.createAsync(function() {
			Assert.equals(20, sequence.length);
			for (i in 0 ... 20) {
				Assert.equals(i, sequence[i]);
			}
		}, 5000);

		for (i in 0 ... 20) {
			result = result.continueWithTask(function(task:Task<Unit>):Task<Unit> {
				return Task.call(function():Unit {
					sequence.push(i);
					return null;
				}, new TimerTaskExecutor(randomInt(10, 50)));
			});
		}

		result.continueWith(function(t:Task<Unit>) {
			task = t;
			done();
		});
	}

	public function testOnSuccess() {
		var continuation = function(task:Task<Int>):Int {
			return task.result + 1;
		};
		var complete = Task.forResult(5).onSuccess(continuation);
		var error = Task.forError("task error").onSuccess(continuation);
		var cancelled = Task.cancelled().onSuccess(continuation);

		Assert.isTrue(complete.isCompleted);
		Assert.equals(6, complete.result);
		Assert.isFalse(complete.isFaulted);
		Assert.isFalse(complete.isCancelled);
		Assert.isTrue(complete.isSuccessed);

		Assert.isTrue(error.isCompleted);
		Assert.is(error.error, String);
		Assert.equals("task error", error.error);
		Assert.isTrue(error.isFaulted);
		Assert.isFalse(error.isCancelled);
		Assert.isFalse(error.isSuccessed);

		Assert.isTrue(cancelled.isCompleted);
		Assert.isFalse(cancelled.isFaulted);
		Assert.isTrue(cancelled.isCancelled);
		Assert.isFalse(cancelled.isSuccessed);
	}

	public function testOnSuccessTask() {
		var continuation = function(task:Task<Int>):Task<Int> {
			return Task.forResult(task.result + 1);
		};
		var complete = Task.forResult(5).onSuccessTask(continuation);
		var error = Task.forError("task error").onSuccessTask(continuation);
		var cancelled = Task.cancelled().onSuccessTask(continuation);

		Assert.isTrue(complete.isCompleted);
		Assert.equals(6, complete.result);
		Assert.isFalse(complete.isFaulted);
		Assert.isFalse(complete.isCancelled);
		Assert.isTrue(complete.isSuccessed);

		Assert.isTrue(error.isCompleted);
		Assert.is(error.error, String);
		Assert.equals("task error", error.error);
		Assert.isTrue(error.isFaulted);
		Assert.isFalse(error.isCancelled);
		Assert.isFalse(error.isSuccessed);

		Assert.isTrue(cancelled.isCompleted);
		Assert.isFalse(cancelled.isFaulted);
		Assert.isTrue(cancelled.isCancelled);
		Assert.isFalse(cancelled.isSuccessed);
	}

	public function testContinueWhile() {
		var count = 0;
		var handled = false;

		Task.forResult(null).continueWhile(function():Bool {
			return (count < 10);
		}, function(task:Task<Unit>):Task<Unit> {
			count++;
			return null;
		}).continueWith(function(task:Task<Unit>):Void {
			Assert.equals(10, count);
			handled = true;
		});

		Assert.isTrue(handled);
	}

	public function testContinueWhileAsync() {
		var count = 0;
		var done = Assert.createAsync(function() {
			Assert.equals(10, count);
		}, 5000);

		Task.forResult(null).continueWhile(function():Bool {
			return (count < 10);
		}, function(task:Task<Unit>):Task<Unit> {
			count++;
			return null;
		}, new TimerTaskExecutor(10)).continueWith(function(task:Task<Unit>) {
			done();
		});
	}

	public function testNullError() {
		var error = Task.forError(null);

		Assert.isTrue(error.isCompleted);
		Assert.same(error.error, null);
		Assert.isTrue(error.isFaulted);
		Assert.isFalse(error.isCancelled);
		Assert.isFalse(error.isSuccessed);
	}

// private section

	private function addTasksWithRandomCompletions(
		tasks:Array<Task<Dynamic>>,
		numberOfTasksToLaunch:Int,
		minDelay:Int = 100,
		maxDelay:Int = 200,
		minResult:Int = 0,
		maxResult:Int = 1000
	) {
		for (i in 0...numberOfTasksToLaunch) {
			tasks.push(Task.call(function():Int {
				var rand : Float = Math.random();

				if (rand >= 0.7) {
					throw "task error";
				} else if (rand >= 0.4) {
					throw new TaskCanceledException();
				}

				return randomInt(minResult, maxResult);
			}, new TimerTaskExecutor(randomInt(minDelay, maxDelay))));
		}
	}

	private function randomInt(from:Int, to:Int):Int {
		return from + Math.floor((to - from + 1) * Math.random());
	}

}
