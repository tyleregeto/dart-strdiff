
import "package:diff/diff.dart";
import 'dart:html';


var a = "NO disaster has accompanied the commencement of an enterprise which you have regarded with such evil forebodings. My first task is to assure my dear sister of my welfare, and increase her confidence in the success of my undertaking.";
var b = "No disaster has accompanied the start of my journy, which you have regarded with such evil forebodings. I arrived here yesterday; and my first task is to assure my dear sister of my welfare, and increasing confidence in the success of my undertaking.";

var c = "The dog in the shoe!";
var e = "The cat in the hat!";

Element space() {
	var span = new SpanElement();
	span.text = " ";
	return span;
}

void main() {
	Element result = querySelector("#result");
	Diff d = diff(c, e, ' ');

	for(var i=0; i<d.pieces.length; i++) {
		var p = d.pieces[i];
		var span = new SpanElement();
		span.text = p.text;

		if(p.delete) {
			span.classes.add("delete");
		}
		if(p.insert) {
			span.classes.add("insert");
		}

		if(i > 0) {
			result.append(space());
		}
		result.append(span);
	}
}