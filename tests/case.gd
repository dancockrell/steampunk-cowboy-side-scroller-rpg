class_name TestCase
extends RefCounted
## Minimal assertion base. Every method named test_* is discovered and run.
##
## Deliberately tiny: no plugin, no addon, no external dependency, so a clean
## checkout can run the suite with only the pinned editor.

var failures: PackedStringArray = PackedStringArray()
var assertion_count: int = 0
var _current: String = ""

func before_each() -> void:
	pass

func after_each() -> void:
	pass

func _fail(message: String) -> void:
	failures.append("%s: %s" % [_current, message])

func set_current_test(name: String) -> void:
	_current = name

func assert_true(condition: bool, message: String) -> void:
	assertion_count += 1
	if not condition:
		_fail("expected true, got false. %s" % message)

func assert_false(condition: bool, message: String) -> void:
	assertion_count += 1
	if condition:
		_fail("expected false, got true. %s" % message)

func assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	assertion_count += 1
	if actual != expected:
		_fail("expected %s, got %s. %s" % [str(expected), str(actual), message])

func assert_ne(actual: Variant, unexpected: Variant, message: String) -> void:
	assertion_count += 1
	if actual == unexpected:
		_fail("expected anything but %s. %s" % [str(unexpected), message])

func assert_almost_eq(actual: float, expected: float, tolerance: float, message: String) -> void:
	assertion_count += 1
	if absf(actual - expected) > tolerance:
		_fail("expected %f +/- %f, got %f. %s" % [expected, tolerance, actual, message])

func assert_null(value: Variant, message: String) -> void:
	assertion_count += 1
	if value != null:
		_fail("expected null, got %s. %s" % [str(value), message])

func assert_not_null(value: Variant, message: String) -> void:
	assertion_count += 1
	if value == null:
		_fail("expected a value, got null. %s" % message)
