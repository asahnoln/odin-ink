package ink_test

import "core:testing"
import "src:ink"

@(test)
story_done :: proc(t: ^testing.T) {
	s := ink.make_story(
	ink.Container { 	//
		"Line before done.",
		"\n",
		.Done,
		"Line after done.",
	},
	)
	defer ink.destroy_story(&s)

	delete(ink.story_continue(&s))

	testing.expect_value(t, s.can_continue, false)
}
