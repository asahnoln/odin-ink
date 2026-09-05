package ink_test

import "core:testing"
import "src:ink"

@(test)
story_empty :: proc(t: ^testing.T) {
	s := ink.story_make(ink.Container{})
	defer ink.story_destroy(&s)

	l := ink.story_continue(&s)
	testing.expect_value(t, l, "")
}

@(test)
story_collects_strings :: proc(t: ^testing.T) {
	s := ink.story_make(
	ink.Container {
		"Hey", //
		" ",
		"you",
		"!",
		"\n",
	},
	)
	defer ink.story_destroy(&s)

	l := ink.story_continue(&s)
	defer delete(l)
	testing.expect_value(t, l, "Hey you!\n")
}

@(test)
story_stops_on_newlines :: proc(t: ^testing.T) {
	s := ink.story_make(
	ink.Container {
		"Read this", //
		"\n",
		"Don't read this",
	},
	)
	defer ink.story_destroy(&s)

	l := ink.story_continue(&s)
	defer delete(l)
	testing.expect_value(t, l, "Read this\n")
}

@(test)
story_keep_going_from_where_stopped :: proc(t: ^testing.T) {
	s := ink.story_make(
	ink.Container {
		"Skip this", //
		"\n",
		"Cool!",
		"\n",
		"Stop there",
	},
	)
	defer ink.story_destroy(&s)

	delete(ink.story_continue(&s))

	{
		l := ink.story_continue(&s)
		defer delete(l)
		testing.expect_value(t, l, "Cool!\n")
	}
	{
		l := ink.story_continue(&s)
		defer delete(l)
		testing.expect_value(t, l, "Stop there")
	}

}

@(test)
story_can_continue :: proc(t: ^testing.T) {
	s := ink.story_make(
	ink.Container {
		"1", //
		"\n",
		"2",
		"\n",
	},
	)
	defer ink.story_destroy(&s)

	testing.expect_value(t, s.can_continue, true)
	delete(ink.story_continue(&s))

	testing.expect_value(t, s.can_continue, true)
	delete(ink.story_continue(&s))

	// NOTE: I don't know if it's possible cleanly check can_continue without calling story_continue
	delete(ink.story_continue(&s))
	testing.expect_value(t, s.can_continue, false)
}

@(test)
story_through_sub_containers :: proc(t: ^testing.T) {
	s := ink.story_make(
	ink.Container {
		"Hey ",
		ink.Container {
			"you!", //
		},
		ink.Container{"\n", "How"},
		" ",
		ink.Container{"are ", ink.Container{"you "}, "do"},
		"ing?",
		ink.Container{"\n"},
	},
	)
	defer ink.story_destroy(&s)

	{
		l := ink.story_continue(&s)
		defer delete(l)
		testing.expect_value(t, l, "Hey you!\n")
	}

	{
		l := ink.story_continue(&s)
		defer delete(l)
		testing.expect_value(t, l, "How are you doing?\n")
	}
}
