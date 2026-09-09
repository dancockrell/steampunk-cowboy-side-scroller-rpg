extends SceneTree
## Headless test runner.
##
##   godot --headless --path . --script res://tests/run_tests.gd
##
## Reports the DENOMINATOR (files found, tests run, assertions made) before any
## verdict. A suite that discovers nothing, or that runs fewer assertions than
## the declared floor, fails loudly instead of printing a green zero.

const TEST_ROOT := "res://tests"
const MIN_TEST_FILES := 6
const MIN_ASSERTIONS := 60

var _files_found: int = 0
var _tests_run: int = 0
var _assertions: int = 0
var _failures: PackedStringArray = PackedStringArray()
var _load_errors: PackedStringArray = PackedStringArray()

func _initialize() -> void:
	var only: String = ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--only="):
			only = arg.substr(7)

	var paths := _discover(TEST_ROOT)
	paths.sort()
	for path: String in paths:
		if only != "" and not path.contains(only):
			continue
		_run_file(path)

	_report(only)

func _discover(dir_path: String) -> PackedStringArray:
	var found := PackedStringArray()
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return found
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		var full := dir_path.path_join(entry)
		if dir.current_is_dir():
			found.append_array(_discover(full))
		elif entry.begins_with("test_") and entry.ends_with(".gd"):
			found.append(full)
		entry = dir.get_next()
	dir.list_dir_end()
	return found

func _run_file(path: String) -> void:
	_files_found += 1
	var script: Variant = load(path)
	if script == null:
		_load_errors.append("%s: failed to load" % path)
		return
	var instance: Variant = (script as GDScript).new()
	if instance == null:
		_load_errors.append("%s: failed to instantiate" % path)
		return
	var case := instance as TestCase
	if case == null:
		_load_errors.append("%s: does not extend TestCase" % path)
		return
	case.tree = self

	var method_names: Array[String] = []
	for method: Dictionary in (script as GDScript).get_script_method_list():
		var n := String(method["name"])
		if n.begins_with("test_") and not method_names.has(n):
			method_names.append(n)
	method_names.sort()

	if method_names.is_empty():
		_load_errors.append("%s: contains no test_* methods" % path)
		return

	for method_name: String in method_names:
		case.set_current_test("%s::%s" % [path.get_file(), method_name])
		case.before_each()
		case.call(method_name)
		case.after_each()
		_tests_run += 1
	_assertions += case.assertion_count
	_failures.append_array(case.failures)

func _report(only: String) -> void:
	print("")
	print("test files found : %d" % _files_found)
	print("tests run        : %d" % _tests_run)
	print("assertions made  : %d" % _assertions)
	print("load errors      : %d" % _load_errors.size())
	print("failures         : %d" % _failures.size())
	print("")

	for e: String in _load_errors:
		print("LOAD ERROR  %s" % e)
	for f: String in _failures:
		print("FAIL  %s" % f)

	# Denominator guards. These are the numbers that go to zero when the harness
	# breaks rather than when the code is correct, so they are checked first.
	var floor_broken := false
	if only == "":
		if _files_found < MIN_TEST_FILES:
			print("HARNESS FAIL: found %d test files, floor is %d. Discovery is broken or the suite was truncated."
				% [_files_found, MIN_TEST_FILES])
			floor_broken = true
		if _assertions < MIN_ASSERTIONS:
			print("HARNESS FAIL: made %d assertions, floor is %d. The suite did not really run."
				% [_assertions, MIN_ASSERTIONS])
			floor_broken = true
	if _tests_run == 0:
		print("HARNESS FAIL: zero tests executed.")
		floor_broken = true

	if floor_broken or _failures.size() > 0 or _load_errors.size() > 0:
		print("RESULT: FAILED")
		quit(1)
		return
	print("RESULT: PASSED (%d assertions across %d tests)" % [_assertions, _tests_run])
	quit(0)
