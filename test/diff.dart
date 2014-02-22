
import "package:diff/diff.dart";
import 'package:unittest/unittest.dart';


String _a1 = "This is a simple story about dogs and cats.";
String _a2 = "This is a complex poem about dogs and pigs.";

String _b1 = "a b c";
String _b2 = "a b c f";

String _c1 = "The cat was green blue";
String _c2 = "The dog cat was black";

String _d1 = "All it takes is one bad day to reduce the sanest man alive to lunacy.";
String _d2 = "All it takes is a crying baby to reduce the sanest woman to lunacy.";

void main() {
	test("Router: no match, use default", () {
		Diff d = diff(_b1, _b2, ' ');
		Diff d2 = diff(_b2, _b1, ' ');
		expect(d.numChanges, equals(1));
		expect(d2.numChanges, equals(1));
	});

	test("Router: no match, use default", () {
		Diff d = diff(_a1, _a2, ' ');
		expect(d.numChanges, equals(4));

		d = diff(_a2, _a1, ' ');
		expect(d.numChanges, equals(4));
	});

	test("Router: no match, use default", () {
		Diff d = diff(_c1, _c2, ' ');
		expect(d.numChanges, equals(3));

		d = diff(_c1, _c2, ' ');
		expect(d.numChanges, equals(3));
	});

	test("Router: no match, use default", () {
		Diff d = diff(_d1, _d2, ' ');
		expect(d.numChanges, equals(4));

		d = diff(_d2, _d1, ' ');
		expect(d.numChanges, equals(4));
		print(d);
	});
}