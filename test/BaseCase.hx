package;

import utest.Assert;

@:keepSub
@:keep
class BaseCase {
	var dummy:String = '';

	public function new() {}

	public function setup() {
		dummy = '';
	}

	function assert<T>(expected:Array<T>, generator:Iterable<T>) {
		dummy = '';
		for(it in generator) {
			Assert.equals(expected.shift(), it);
		}
		Assert.equals(0, expected.length);
	}
}