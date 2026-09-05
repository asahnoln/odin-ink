package ink_test

import "core:testing"
import "src:ink"

@(test)
divert :: proc(t: ^testing.T) {
	s := ink.story_make(
	ink.Container {
		ink.Divert{path = "3.2"},
		"Skip this",
		"\n",
		ink.Container {
			"Skip that",
			"\n",
			ink.Container {
				"Now ", //
			},
			"collect ",
		},
		"this!",
		"\n",
		"Stop",
	},
	)
	defer ink.story_destroy(&s)

	{
		l := ink.story_continue(&s)
		defer delete(l)
		testing.expect_value(t, l, "Now collect this!\n")
	}

}
