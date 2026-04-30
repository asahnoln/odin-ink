package ink_test

import "core:testing"
import "src:ink"

@(test)
continue_empty :: proc(t: ^testing.T) {
	s := ink.make_story(ink.Container{})
	testing.expect_value(t, s.can_continue, false)
	testing.expect_value(t, ink.story_continue(&s), "")
}

@(test)
continue_one_line :: proc(t: ^testing.T) {
	s := ink.make_story(ink.Container{"One line.", "\n"})

	testing.expect_value(t, s.can_continue, true)

	l := ink.story_continue(&s)
	defer delete(l)
	testing.expect_value(t, l, "One line.\n")

	testing.expect_value(t, s.can_continue, false)
}

@(test)
continue_multiple_lines_in_containers :: proc(t: ^testing.T) {
	s := ink.make_story(
	ink.Container {
		ink.Container { 	//
			"First deep line.",
			"\n",
			"Second deep line.",
			"\n",
		},
		"Third shallow line.",
		"\n",
		"Fourth shallow line.",
		"\n",
	},
	)
	defer ink.destroy_story(&s)

	testing.expect_value(t, s.can_continue, true)

	l := ink.story_continue(&s)
	testing.expect_value(t, l, "First deep line.\n")
	delete(l)

	l = ink.story_continue(&s)
	testing.expect_value(t, l, "Second deep line.\n")
	delete(l)

	l = ink.story_continue(&s)
	testing.expect_value(t, l, "Third shallow line.\n")
	delete(l)

	l = ink.story_continue(&s)
	testing.expect_value(t, l, "Fourth shallow line.\n")
	delete(l)
}

// @(test)
// continue_one_between_containers :: proc(t: ^testing.T) {
// 	s := ink.make_story(
// 	ink.Container {
// 		ink.Container { 	//
// 			"Split ",
// 			"between containers.",
// 			"\n",
// 		},
// 	},
// 	)
// 	defer ink.destroy_story(&s)
//
// 	testing.expect_value(t, s.can_continue, true)
//
// 	l := ink.story_continue(&s)
// 	testing.expect_value(t, l, "Split between containers.\n")
// 	delete(l)
// }
