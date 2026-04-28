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
continue_one_line_with_additional_element :: proc(t: ^testing.T) {
	s := ink.make_story(
	ink.Container { 	//
		"One line.",
		"\n",
		ink.Container{},
	},
	)

	l := ink.story_continue(&s)
	defer delete(l)
	testing.expect_value(t, l, "One line.\n")

	testing.expect_value(t, s.can_continue, false)
}

@(test)
continue_line_from_several_containers :: proc(t: ^testing.T) {
	s := ink.make_story(
	ink.Container { 	//
		"Combined ",
		ink.Container{"line", "."},
		"\n",
	},
	)

	l := ink.story_continue(&s)
	defer delete(l)
	testing.expect_value(t, l, "Combined line.\n")

	testing.expect_value(t, s.can_continue, false)
}

@(test)
continue_first_line_of_two :: proc(t: ^testing.T) {
	s := ink.make_story(
	ink.Container { 	//
		"First line.",
		"\n",
		"Second line.",
		"\n",
	},
	)

	l := ink.story_continue(&s)
	defer delete(l)
	testing.expect_value(t, l, "First line.\n")

	testing.expect_value(t, s.can_continue, true)

	// l = ink.story_continue(&s)
	// defer delete(l)
	// testing.expect_value(t, l, "Second line.\n")

}
