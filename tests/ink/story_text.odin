package ink_test

import "core:testing"
import "src:ink"

@(test)
continue_one_line :: proc(t: ^testing.T) {
	s := ink.make_story(
	ink.Container { 	//
		"First line.",
		"\n",
		"Second line.",
		"\n",
		ink.Container { 	//
			"Deep line.",
			"\n",
			"Deep line 2.",
			"\n",
			"Split ",
		},
		"line.",
		"\n",
	},
	)
	defer ink.destroy_story(&s)

	testing.expect_value(t, s.can_continue, true)

	l := ink.story_continue(&s)
	testing.expect_value(t, l, "First line.\n")
	delete(l)

	testing.expect_value(t, s.can_continue, true)

	l = ink.story_continue(&s)
	testing.expect_value(t, l, "Second line.\n")
	delete(l)

	testing.expect_value(t, s.can_continue, true)

	l = ink.story_continue(&s)
	testing.expect_value(t, l, "Deep line.\n")
	delete(l)

	testing.expect_value(t, s.can_continue, true)

	l = ink.story_continue(&s)
	testing.expect_value(t, l, "Deep line 2.\n")
	delete(l)

	testing.expect_value(t, s.can_continue, true)

	l = ink.story_continue(&s)
	testing.expect_value(t, l, "Split line.\n")
	delete(l)

	testing.expect_value(t, s.can_continue, false)

	l = ink.story_continue(&s)
	testing.expect_value(t, l, "")
	delete(l)
}
