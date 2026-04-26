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
continue_two_lines_first_line :: proc(t: ^testing.T) {
	s := ink.make_story(ink.Container{"First line.", "\n", "Second line.", "\n"})

	l := ink.story_continue(&s)
	defer delete(l)
	testing.expect_value(t, l, "First line.\n")
	testing.expect_value(t, s.can_continue, true)
}

@(test)
continue_two_lines_second_line :: proc(t: ^testing.T) {
	s := ink.make_story(ink.Container{"First line.", "\n", "Second line.", "\n"})
	s.index = 2

	l := ink.story_continue(&s)
	defer delete(l)
	testing.expect_value(t, l, "Second line.\n")
}

@(test)
continue_nested_container :: proc(t: ^testing.T) {
	s := ink.make_story(
	ink.Container {
		ink.Container { 	//
			"First line.",
			"\n",
			"Second line.",
			"\n",
		},
	},
	)

	l := ink.story_continue(&s)
	defer delete(l)
	testing.expect_value(t, l, "First line.\n")
}

@(test)
continue_nested_container_second_line :: proc(t: ^testing.T) {
	s := ink.make_story(
	ink.Container {
		ink.Container { 	//
			"First line.",
			"\n",
			"Second line.",
			"\n",
		},
	},
	)

	s.current_container = s.root[0].(ink.Container)
	s.index = 2

	l := ink.story_continue(&s)
	defer delete(l)
	testing.expect_value(t, l, "Second line.\n")
}
