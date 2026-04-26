package ink_test

import "core:testing"
import "src:ink"

@(test)
continue_empty :: proc(t: ^testing.T) {
	s := ink.make_story()
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
