package ink_test

import "core:testing"
import "src:ink"

@(test)
continue_empty :: proc(t: ^testing.T) {
	s := ink.make_story(ink.Container{})
	defer ink.destroy_story(&s)

	testing.expect_value(t, s.can_continue, false)
	testing.expect_value(t, ink.story_continue(&s), "")
}

@(test)
continue_empty_nested :: proc(t: ^testing.T) {
	s := ink.make_story(ink.Container{ink.Container{}})
	defer ink.destroy_story(&s)

	testing.expect_value(t, s.can_continue, false)
	testing.expect_value(t, ink.story_continue(&s), "")
}

@(test)
continue_one_line :: proc(t: ^testing.T) {
	s := ink.make_story(ink.Container{"One line.", "\n"})
	defer ink.destroy_story(&s)

	testing.expect_value(t, s.can_continue, true)

	l := ink.story_continue(&s)
	testing.expect_value(t, l, "One line.\n")
	delete(l)

	testing.expect_value(t, s.can_continue, false)
}

@(test)
continue_one_line_with_element_before :: proc(t: ^testing.T) {
	s := ink.make_story(
	ink.Container { 	//
		ink.Container{},
		"One line.",
		"\n",
	},
	)
	defer ink.destroy_story(&s)

	testing.expect_value(t, s.can_continue, true)

	l := ink.story_continue(&s)
	testing.expect_value(t, l, "One line.\n")
	delete(l)

	testing.expect_value(t, s.can_continue, false)
}

@(test)
continue_two_lines :: proc(t: ^testing.T) {
	s := ink.make_story(
	ink.Container { 	//
		"First line.",
		"\n",
		"Second line.",
		"\n",
	},
	)
	defer ink.destroy_story(&s)

	testing.expect_value(t, s.can_continue, true)

	l := ink.story_continue(&s)
	testing.expect_value(t, l, "First line.\n")
	delete(l)

	testing.expect_value(t, s.can_continue, true)
}
