package ink_test

import "core:testing"
import "src:ink"

@(test)
empty :: proc(t: ^testing.T) {
	s := ink.story_make()

	got := ink.story_continue(&s)
	testing.expect_value(t, got, "")
}

@(test)
hello_world :: proc(t: ^testing.T) {
	s := ink.story_make(
		ink.Container {
			ink.Container {
				"Hello, world!",
				"\n",
				ink.Container {
					.Done,
					ink.Container_Info{flags = {.Visits, .Count_Start_Only}, name = "g-0"},
				},
				nil,
			},
			.Done,
			ink.Container_Info{flags = {.Visits}},
		},
	)

	got := ink.story_continue(&s)
	testing.expect_value(t, got, "Hello, world!\n")
}
