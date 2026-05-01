package ink_test

import "core:testing"
import "src:ink"

@(test)
make_story_from_json :: proc(t: ^testing.T) {
	s, err := ink.make_story(#load("testdata/two_lines.json"))
	defer ink.destroy_story(&s)

	if !testing.expect_value(t, err, nil) {
		return
	}

	testing.expect_value(t, s.can_continue, true)

	l := ink.story_continue(&s)
	testing.expect_value(t, l, "One line.\n")
	delete(l)

	testing.expect_value(t, s.can_continue, true)

	l = ink.story_continue(&s)
	testing.expect_value(t, l, "Second line.\n")
	delete(l)

	testing.expect_value(t, s.can_continue, false)
}
