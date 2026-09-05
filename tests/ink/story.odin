package ink_test

import "base:builtin"
import "base:runtime"
import "core:mem"
import "core:testing"
import "src:ink"

@(test)
story_empty :: proc(t: ^testing.T) {
	s := ink.story_make(ink.Container{})

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
story_collects_strings_recursively :: proc(t: ^testing.T) {
	s := ink.story_make(
	ink.Container {
		"Hey",
		ink.Container {
			" ", //
			ink.Container{"you"},
		},
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
		"Hey", //
		"\n",
		"Don't continue here...",
	},
	)
	defer ink.story_destroy(&s)

	l := ink.story_continue(&s)
	defer delete(l)
	testing.expect_value(t, l, "Hey\n")
}

@(test)
story_continues_from_last_stop :: proc(t: ^testing.T) {
	s := ink.story_make(
	ink.Container {
		"Skip this", //
		"\n",
		"Read this",
		"\n",
		"And read this",
		"\n",
	},
	)
	defer ink.story_destroy(&s)

	l := ink.story_continue(&s)
	delete(l)

	l = ink.story_continue(&s)
	testing.expect_value(t, l, "Read this\n")
	delete(l)

	l = ink.story_continue(&s)
	testing.expect_value(t, l, "And read this\n")
	delete(l)

	l = ink.story_continue(&s)
	testing.expect_value(t, l, "")
}

@(test)
story_can_continue :: proc(t: ^testing.T) {
	s := ink.story_make(
	ink.Container {
		"Go", //
		"\n",
		"Go",
		"\n",
		"Go",
		"\n",
	},
	)
	defer ink.story_destroy(&s)

	testing.expect_value(t, s.can_continue, true)
	delete(ink.story_continue(&s))

	testing.expect_value(t, s.can_continue, true)
	delete(ink.story_continue(&s))

	testing.expect_value(t, s.can_continue, true)
	delete(ink.story_continue(&s))

	// TODO: Would be great to see in advance if the story can continue...
	l := ink.story_continue(&s)
	testing.expect_value(t, l, "")
	testing.expect_value(t, s.can_continue, false)
}

@(test)
story_stops_and_goes_recursively :: proc(t: ^testing.T) {
	s := ink.story_make(
	ink.Container {
		"Skip this", //
		"\n",
		ink.Container{"Read this", "\n"},
		"And read this",
		"\n",
	},
	)

	append(&s.idx_path, 2)

	defer ink.story_destroy(&s)

	l: string

	l = ink.story_continue(&s)
	testing.expect_value(t, l, "Read this\n")
	delete(l)

	l = ink.story_continue(&s)
	testing.expect_value(t, l, "And read this\n")
	delete(l)

	l = ink.story_continue(&s)
	testing.expect_value(t, l, "")
}
