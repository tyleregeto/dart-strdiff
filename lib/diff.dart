
library diff;

class Diff {
	List<DiffString> pieces;
	int numDeletes = 0;
	int numInserts = 0;

	Diff() {
		pieces = [];
	}

	void add(DiffString str) {
		pieces.add(str);
		if(str.insert) {
			numInserts++;
		} else if(str.delete) {
			numDeletes++;
		}
	}

	int get numChanges {
		return numDeletes + numInserts;
	}

	String toString() {
		var s = "";
		for(var i=0; i<pieces.length; i++) {
			s += " ${pieces[i].toString()}";
		}
		return s;
	}
}

class DiffString {
	bool delete;
	bool insert;
	String text;

	DiffString({this.delete:false, this.insert:false});

	String append(String str) {
		if(text == null) {
			text = str;
		} else {
			text += " $str";
		}
	}

	String toString() {
		if(insert) {
			return "[+$text]";
		}
		else if(delete) {
			return "[-$text]";
		}
		return text;
	}
}

class _Unit {
	// hashcode of the string unit
	int key;
	// old count
	int oc;
	// new count
	int nc;
	// the string value
	String raw;
	// old file line number
	int olno;

	_Unit(this.key, this.raw, {int this.oc:0, int this.nc:0});

	String toJson() {
		return "[Unit=${raw}]";
	}

	String toString() {
		return "[Unit=${raw}:${olno}]";
	}
}

// diffs two strings
Diff diff(String o, String n, [Object pattern = null]) {
	// what unit we want to diff against, ie: line, word, etc.
	if(pattern == null) {
		pattern = new RegExp('\n|\r');
	}

	var oa = [];
	var na = [];

	var ol = o.split(pattern);
	var nl = n.split(pattern);
	var units = new Map<int, _Unit>();

	for(var i=0; i<nl.length; i++) {
		String str = nl[i];
		_Unit unit = units[str.hashCode];

		if(unit == null) {
			units[str.hashCode] = unit = new _Unit(str.hashCode, str, nc: 1);
		} else {
			unit.nc++;
		}
		na.add(unit);
	}

	for(var i=0; i<ol.length; i++) {
		String str = ol[i];
		_Unit unit = units[str.hashCode];

		if(unit == null) {
			units[str.hashCode] = unit = new _Unit(str.hashCode, str, oc: 1);
		} else {
			unit.oc++;
		}
		unit.olno = i;
		oa.add(unit);
	}

	//phase 3
	for(var i=0; i<na.length;i++) {
		var u = na[i];
		if(u.nc == 1 && u.oc == 1) {
			na[i] = u.olno;
			oa[u.olno] = i;
		}
	}

	//phase 4
	for(var i = 0; i < na.length; i++) {
		var u = na[i];

		if(u is int && na.length > i+1) {
			var v1 = nl[i+1];
			var v2 = ol[u+1];

			if(v1 is _Unit && v1 == v2) {
				na[i+1] = units[v2.hashCode];
				oa[u+1] = units[v1.hashCode];
			}
		}
	}

	// phase 5
	for(var i = na.length - 1; i > 0; i--) {
		var u = na[i];
		if(u is int && u > 0) {
			var v1 = nl[i-1];
			var v2 = ol[u-1];

			if(v1 is _Unit && v1 == v2) {
				na[i-1] = units[v2.hashCode];
				oa[u-1] = units[v1.hashCode];
			}
		}
	}

	// phase 6
	var result = new Diff();
	var cursor = 0;
	var count = units.length;

	int findInserts(List src, int pos, DiffString str) {
		while(true) {
			var u = pos < src.length ? src[pos] : null;
			if(u is _Unit) {
				str.append(u.raw);
				src[pos] = null;
			} else {
				break;
			}
			pos++;
		}
		return pos;
	}

	int findDeletes(List src, int pos, DiffString str) {
		while(true) {
			var u = pos < src.length ? src[pos] : null;
			if(u is _Unit) {
				str.append(u.raw);
				src[pos] = null;
			} else {
				break;
			}
			pos++;
		}
	}

	print("a: $oa");
	print("b: $na");

	while(cursor < count) {
		var u = cursor < na.length ? na[cursor] : null;
		var u2 = cursor < oa.length ? oa[cursor] : null;

		// delete
		if(u2 is _Unit) {
			var str = new DiffString(delete: true);
			findDeletes(oa, cursor, str);
			result.add(str);
		}

		if(u is _Unit) {
			var str = new DiffString(insert: true);
			findInserts(na, cursor, str);
			result.add(str);
		}

		if(u is int) {
			// its just text
			var str = new DiffString();
			result.add(str);

			while(true) {
				var u = cursor < na.length ? na[cursor] : null;
				if(u is int) {
					str.append(ol[u]);

					if(cursor < oa.length) {
						u = oa[cursor];

						if(u is _Unit) {
							var str = new DiffString(delete: true);
							findDeletes(oa, cursor, str);
							result.add(str);
							cursor++;
							break;
						}
					}
				} else {
					break;
				}

				cursor++;
			}
		}

		if(u == null) {
			cursor++;
		}
	}

	return result;
}

