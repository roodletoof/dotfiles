import {
	map,
	rule,
	simlayer,
	writeToProfile,
} from 'karabiner.ts'

const no_modifier_added = undefined
const no_mandatory_modifier = undefined

writeToProfile(
	'KarabinerTS',
	[
		rule('dual purpose modifiers').manipulators([

			map('spacebar', no_mandatory_modifier, 'any')
				.to('left_shift', no_modifier_added, {'lazy': true})
				.toIfAlone('spacebar'),

			map('caps_lock', no_mandatory_modifier, 'any')
				.to('left_control', no_modifier_added, {'lazy': true})
				.toIfAlone('escape'),

		]),
	]
)



//		simlayer( 'slash', 'slash-layer', 100 ).manipulators([
//			// norwegian characters
//			map('8').to('a', 'left_option'),
//			map('0').to("'", 'left_option'),
//			map('9').to("o", 'left_option'),
//
//			// control characters
//			map('h').to('delete_or_backspace'),
//			map('j').to('return_or_enter'),
//			map('l').to('tab'),
//
//			// symbols
//			map('q').to("non_us_backslash", no_modifier_added, {'repeat': false}),
//			map('a').to("non_us_backslash", 'left_shift', {'repeat': false}),
//
//			map('e').to(']', no_modifier_added, {'repeat': false}),
//			map('d').to('0', 'left_shift', {'repeat': false}),
//			map('c').to(']', 'left_shift', {'repeat': false}),
//
//			map('w').to('[', no_modifier_added, {'repeat': false}),
//			map('s').to('9', 'left_shift', {'repeat': false}),
//			map('x').to('[', 'left_shift', {'repeat': false}),
//
//			map('f').to('8', 'left_shift', {'repeat': false}),
//			map('r').to('7', 'left_shift', {'repeat': false}),
//			map('g').to('\\', no_modifier_added, {'repeat': false}),
//			map('t').to('\\', 'left_shift', {'repeat': false}),
//
//			map('k').to('/', no_modifier_added, {'repeat': false}),
//
//			map('u').to('-', 'left_shift', {'repeat': false}),
//			map('i').to('-', no_modifier_added, {'repeat': false}),
//			map('o').to('=', 'left_shift', {'repeat': false}),
//			map('p').to('=', no_modifier_added, {'repeat': false}),
//
//			map('y').to('6', 'left_shift', {'repeat': false}),
//			map('z').to('4', 'left_shift', {'repeat': false}),
//
//			map('v').to('1', 'left_shift', {'repeat': false}),
//
//			map('m').to(';', 'left_shift', {'repeat': false}),
//			map('b').to('5', 'left_shift', {'repeat': false}),
//			map(',').to(',', 'left_shift', {'repeat': false}),
//			map('.').to('.', 'left_shift', {'repeat': false}),
//
//		]),
//
//		simlayer( 'z', 'z-layer', 100 ).manipulators([
//			// norwegian characters
//			map('8').to('a', 'left_option'),
//			map('0').to("'", 'left_option'),
//			map('9').to("o", 'left_option'),
//
//			// control characters
//			map('h').to('delete_or_backspace'),
//			map('j').to('return_or_enter'),
//			map('l').to('tab'),
//
//			// symbols
//			map('q').to("non_us_backslash", no_modifier_added, {'repeat': false}),
//			map('a').to("non_us_backslash", 'left_shift', {'repeat': false}),
//
//			map('e').to(']', no_modifier_added, {'repeat': false}),
//			map('d').to('0', 'left_shift', {'repeat': false}),
//			map('c').to(']', 'left_shift', {'repeat': false}),
//
//			map('w').to('[', no_modifier_added, {'repeat': false}),
//			map('s').to('9', 'left_shift', {'repeat': false}),
//			map('x').to('[', 'left_shift', {'repeat': false}),
//
//			map('f').to('8', 'left_shift', {'repeat': false}),
//			map('r').to('7', 'left_shift', {'repeat': false}),
//			map('g').to('\\', no_modifier_added, {'repeat': false}),
//			map('t').to('\\', 'left_shift', {'repeat': false}),
//
//			map('k').to('/', no_modifier_added, {'repeat': false}),
//
//			map('u').to('-', 'left_shift', {'repeat': false}),
//			map('i').to('-', no_modifier_added, {'repeat': false}),
//			map('o').to('=', 'left_shift', {'repeat': false}),
//			map('p').to('=', no_modifier_added, {'repeat': false}),
//
//			map('y').to('6', 'left_shift', {'repeat': false}),
//
//			map('v').to('1', 'left_shift', {'repeat': false}),
//
//			map('m').to(';', 'left_shift', {'repeat': false}),
//			map('b').to('5', 'left_shift', {'repeat': false}),
//			map(',').to(',', 'left_shift', {'repeat': false}),
//			map('.').to('.', 'left_shift', {'repeat': false}),
//			map('/').to('=', no_modifier_added, {'repeat': false}),
//
//		]),
