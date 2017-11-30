Prism.languages.ghost = {
	'comment': [
		/\/\*[\s\S]+?\*\//,
		/\/\/.*/
	],
	'keyword':  [
		/\b(?:domain|problem|import)\b/,
		/\b(?:type|const|comp|sv|resource|int|enum)\b/,
		/\b(?:external|planned)\b/,
		/\b(?:transition|synchronize|variable)\b/,
		/\b(?:inherited|or|var)\b/,
		/\b(?:contr|uncontr)\b/,
		/\b(?:require|consume|produce)\b/,
		/\b(?:init|fact|goal)\b/,
		/\b(?:at)\b/,
		/\b(?:INF)\b/,
		/\b(?:start|end|this)\b/,
		/\b(?:equals|before|after|meets|during|contains|starts|ends)\b/
	],
	'directive': /\$\w+.*/,
	'annotation': [
		/@\([^\)]*\)/,
		/@[^\(].*/
	],
	'number': /([+-]|\b)\d+/,
	'operator': /=|<=?|>=?|!=|[+\-*%]|->/,
	'punctuation': /\(\.|\.\)|[()\[\]:;,.]/
};
