package async;

import hxasync.Task;
import utest.Assert;

class TestAsyncTryCatch extends BaseCase implements IAsyncable {

	@:async
	public function testHandleNonAsyncExceptions() {
		var done = Assert.createAsync(1000);

		try {
			methodWithException();
			@:await Task.forResult(null);
		} catch(e:Dynamic) {
			Assert.raises(function() { throw e; }, String);
			Assert.equals("non async exception", e);
		}

		try {
			throw 123;
			@:await Task.forResult(null);
		} catch(e:Dynamic) {
			Assert.equals(123, e);
		}

		done();
	}

	@:async
	public function testHandleNonAsyncExceptionsType() {
		var done = Assert.createAsync(1000);

		try {
			throw 123;
			@:await Task.forResult(null);
		} catch(e:String) {
			Assert.fail("Exception should be Int type.");
		} catch(e:Int) {
			Assert.equals(123, e);
		} catch(e:Dynamic) {
			Assert.fail("Exception should be Int type.");
		}

		try {
			methodWithException();
			@:await Task.forResult(null);
		} catch(e:String) {
			Assert.equals("non async exception", e);
		} catch(e:Int) {
			Assert.fail("Exception should be String type.");
		} catch(e:Dynamic) {
			Assert.fail("Exception should be String type.");
		}

		done();
	}

	@:async
	public function testNestedHandleNonAsync() {
		var done = Assert.createAsync(1000);

		try {
			methodWithException();
			@:await Task.forResult(null);
		} catch(e:Dynamic) {
			Assert.raises(function() { throw e; }, String);
			Assert.equals("non async exception", e);
			try {
				throw "non async exception";
				@:await Task.forResult(null);
				@:await Task.forError("async exception");
				@:await Task.forResult(null);
			} catch(_e:Dynamic) {
				Assert.raises(function() { throw _e; }, String);
				Assert.equals("non async exception", e);
			}
		}

		try {
			throw 123;
			@:await Task.forResult(null);
		} catch(e:Dynamic) {
			Assert.equals(123, e);
			try {
				methodWithException();
			} catch(_e:Dynamic) {
				Assert.raises(function() { throw _e; }, String);
				Assert.equals("non async exception", _e);
			}
		}

		done();
	}

	@:async
	public function testHandleAsyncExceptions() {
		var done = Assert.createAsync(1000);

		try {
			@:await Task.forResult(null);
			throw "async string exception";
		} catch(e:Dynamic) {
			Assert.raises(function() { throw e; }, String);
			Assert.equals("async string exception", e);
		}

		try {
			@:await asyncWithHandleException();
			Assert.pass();
		} catch(e:Dynamic) {
			Assert.fail("Unhandled exception.");
		}

		try {
			@:await Task.forResult(null);
			methodWithException();
		} catch(e:Dynamic) {
			Assert.raises(function() { throw e; }, String);
			Assert.equals("non async exception", e);
		}

		done();
	}

	@:async
	public function testHandleAsyncExceptionsType() {
		var done = Assert.createAsync(1000);

		try {
			@:await Task.forError("async handle exception");
			throw 123;
		} catch(e:String) {
			Assert.equals("async handle exception", e);
		} catch(e:Dynamic) {
			Assert.fail("Exception should be String type.");
		}

		try {
			@:await asyncWithHandleException();
			@:await Task.forError(123);
		} catch(e:String) {
			Assert.fail("Exception should be Int type.");
		} catch(e:Int) {
			Assert.equals(123, e);
		} catch(e:Dynamic) {
			Assert.fail("Exception should be Int type.");
		}

		try {
			@:await asyncWithHandleException();
			@:await asyncWithUnhandledException();
		} catch(e:String) {
			Assert.equals("async non handle exception", e);
		} catch(e:Int) {
			Assert.fail("Exception should be String type.");
		} catch(e:Dynamic) {
			Assert.fail("Exception should be String type.");
		}

		done();
	}

	@:async
	public function testNestedHandleAsync() {
		var done = Assert.createAsync(1000);

		try {
			@:await asyncWithUnhandledException();
		} catch(e:Dynamic) {
			try {
				@:await Task.forError("async handle exception");
			} catch(_e:Dynamic) {
				Assert.raises(function() { throw _e; }, String);
				Assert.equals("async handle exception", _e);
			}
		}

		try {
			@:await Task.forResult(null);
			@:await asyncWithUnhandledException();
		} catch(e:String) {
			try {
				@:await Task.forError(123);
			} catch(_e:Dynamic) {
				Assert.equals(123, _e);
			}
		} catch(e:Dynamic) {
			Assert.fail("Exception should be String type.");
		}

		done();
	}

	@:async
	public function testNestedTry_secondTryDoesNotCatchException() {
		var result = 0;
		try {
			try {
				throw 1;
				@:await Task.forResult(0);
			} catch(e:String) {
			}
		} catch(e:Dynamic) {
			result += e;
		}
		Assert.equals(1, result);
	}

	@:async
	function asyncMetaWithUnhandledException() {
		@:await asyncWithUnhandledException();
	}

	@:async
	function asyncMetaWithUncaughtException() {
		try {
			@:await asyncWithUnhandledException();
			Assert.fail();
		}
		catch(e:TestAsyncTryCatch) {
			Assert.fail();
		}
	}

	private function methodWithException() {
		throw "non async exception";
	}

	@:async
	private function asyncWithHandleException():Task<Unit> {
		try {
			@:await Task.forError("async handle exception");
		} catch(e:String) {
			// handle exception
		}
		return null;
	}

	private function asyncWithUnhandledException():Task<Unit> {
		throw "async non handle exception";
	}

}
