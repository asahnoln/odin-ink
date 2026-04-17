package ink_test

import "core:testing"
import "src:ink"

@(test)
story_continue :: proc(t: ^testing.T) {
	story := ink.Story {
		root = {
			ink.Container { 	//
				"Only one line of text.",
				"\n",
			},
		},
	}

	s := ink.story_continue(&story)

	testing.expect_value(t, s, "Only one line of text.\n")
}
