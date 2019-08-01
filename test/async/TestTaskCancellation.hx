package async;

import utest.Assert;
import hxasync.cancellation.CancellationToken;
import hxasync.cancellation.CancellationTokenSource;

class TestTaskCancellation extends BaseCase implements IAsyncable {

	public function testSynchronousCancellation() {
		var cts = new CancellationTokenSource();
		var ct = cts.token;
		var continuationMarker = 0;

		var tcs = new TaskCompletionSource<Int>();
		var task = tcs.task;

		task.continueWith(function(task:Task<Int>) : Unit {
			Assert.fail("Task should be cancelled!");
			return null;
		}, ct).continueWith(function(task:Task<Unit>):Unit {
			Assert.isTrue(task.isCompleted);
			Assert.isTrue(task.isCancelled);
			Assert.isFalse(task.isFaulted);
			return null;
		}, CancellationToken.NONE);

		task.continueWith(function(task:Task<Int>) {
			Assert.equals(100, task.result);
			Assert.isTrue(task.isCompleted);
			Assert.isFalse(task.isCancelled);
			Assert.isFalse(task.isFaulted);
		});

		cts.cancel();

		tcs.setResult(100);

		Task.forResult(null, ct).continueWith(function(task:Task<Unit>) {
			Assert.fail("Task should be cancelled!");
		}, ct);

		Task.forResult(null, ct).continueWith(function(task:Task<Unit>) {
			Assert.isTrue(task.isCompleted);
			Assert.isTrue(task.isCancelled);
			Assert.isFalse(task.isFaulted);
			continuationMarker = 5;
		});
		Assert.equals(5, continuationMarker);

		Task.forResult(null, ct).continueWith(function(task:Task<Unit>) {
			Assert.isTrue(task.isCompleted);
			Assert.isTrue(task.isCancelled);
			Assert.isFalse(task.isFaulted);
			continuationMarker = 7;
		}, CancellationToken.NONE);
		Assert.equals(7, continuationMarker);

		Task.forResult(null, ct).continueWith(function(task:Task<Unit>) : Unit {
			Assert.fail("Task should be cancelled!");
			return null;
		}, ct).onSuccess(function(task:Task<Unit>) : Unit {
			Assert.fail("Task couldn't be successed!");
			return null;
		});

		Task.forResult(null, ct).continueWith(function(task:Task<Unit>) : Unit {
			Assert.isTrue(task.isCompleted);
			Assert.isTrue(task.isCancelled);
			Assert.isFalse(task.isFaulted);
			continuationMarker = 9;
			return null;
		}).onSuccess(function(task:Task<Unit>) : Unit {
			Assert.equals(9, continuationMarker);
			Assert.isTrue(task.isCompleted);
			Assert.isFalse(task.isCancelled);
			Assert.isFalse(task.isFaulted);
			continuationMarker = 11;
			return null;
		});
		Assert.equals(11, continuationMarker);
	}

	@:async
	public function testSynchronousCancellationWithAwait() {
		var cts = new CancellationTokenSource();
		var ct = cts.token;
		var result = 0;

		result = @:await Task.forResult(5, ct);
		Assert.equals(5, result);

		cts.cancel();
		try {
			result += @:await Task.forResult(5, ct);
			Assert.fail("Task should be cancelled!");
		} catch(e:Dynamic) {
			Assert.isTrue(Std.is(e, TaskCanceledException));
			return;
		}
		Assert.fail("Await should be never started!");
		result += @:await Task.forResult(5);
		Assert.fail("Await should be never completed!");
	}

	public function testAsynchronousCancellation() {
		var cts = new CancellationTokenSource();
		var ct = cts.token;
		var continuationMarker = 0;

		var done = Assert.createAsync(function() {
			Assert.equals(1, continuationMarker);
		}, 5000);

		Task.delay(10, ct).continueWith(function(task:Task<Unit>) {
			Assert.fail("Task should be cancelled!");
		}, ct);

		Task.delay(10, ct).continueWith(function(task:Task<Unit>) {
			Assert.isTrue(task.isCompleted);
			Assert.isTrue(task.isCancelled);
			Assert.isFalse(task.isFaulted);
			continuationMarker++;
			done();
		});

		cts.cancel();
	}

	@:async
	public function testAsynchronousCancellationWithAwait() {
		var cts = new CancellationTokenSource();
		var ct = cts.token;
		var result = 0;

		var done = Assert.createAsync(function() {
			Assert.equals(15, result);
		}, 5000);

		try {
			for (i in 0...10) {
				@:await Task.delay(10, ct);
				result += i;
				if (i == 5) {
					cts.cancel();
				}
			}
		} catch(e:TaskCanceledException) {
			Assert.isTrue(Std.is(e, TaskCanceledException));
			done();
			return;
		}
		Assert.fail("Task should be cancelled!");
	}

	public function testDelayedAsynchronousCancellation() {
		var cts1 = new CancellationTokenSource(CancellationType.DELAYED_CANCELLATION(100));
		var cts2 = new CancellationTokenSource();
		var continuationMarker = 0;

		var done = Assert.createAsync(function() {
			Assert.equals(2, continuationMarker);
		}, 5000);

		Task.delay(5, cts1.token).continueWith(function(task:Task<Unit>) {
			Assert.isTrue(task.isCompleted);
			Assert.isFalse(task.isCancelled);
			Assert.isFalse(task.isFaulted);
			continuationMarker++;
		}, cts1.token);

		Task.delay(150, cts1.token).continueWith(function(task:Task<Unit>) {
			Assert.fail("Task should be cancelled!");
		}, cts1.token);

		Task.delay(5, cts2.token).continueWith(function(task:Task<Unit>) {
			Assert.isTrue(task.isCompleted);
			Assert.isFalse(task.isCancelled);
			Assert.isFalse(task.isFaulted);
			continuationMarker++;
		}, cts2.token);

		Task.delay(100, cts2.token).continueWith(function(task:Task<Unit>) {
			Assert.fail("Task should be cancelled!");
		}, cts2.token);

		cts2.cancelAfter(CancellationType.DELAYED_CANCELLATION(50));

		Task.delay(200).onSuccess(function(task:Task<Unit>) { done(); });
	}
}
