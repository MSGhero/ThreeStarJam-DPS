package attacks;

enum abstract AttackLevel(Int) from Int to Int {
	var BASIC; // every character will have these, in order
	var AUTO;
	var DOT;
	var ADV;
	var ULT;
}