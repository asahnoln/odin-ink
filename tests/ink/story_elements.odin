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

@(test)
story_simple_choice :: proc(t: ^testing.T) {
	s := ink.make_story(
	ink.Container { 	//
		.Ev,
		.Str,
		"One choice",
		.Str_End,
		.Ev_End,
		Choice{path = "0.c-1", flg = {.Has_Choice_Only_Content, .Once_Only}},
	},
	)
	defer ink.destroy_story(&s)

	testing.expect_value(t, s.can_continue, false)

	testing.expect_value(t, len(s.current_choices), 1)
}
