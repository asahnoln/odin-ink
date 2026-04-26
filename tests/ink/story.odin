package ink_test

import "core:testing"
import "src:ink"

// @(test)
continue_empty :: proc(t: ^testing.T) {
	s := ink.make_story()
	testing.expect_value(t, ink.can_continue(s), false)
	testing.expect_value(t, ink.story_continue(&s), "")
	testing.expect_value(t, ink.can_continue(s), false)
}

// @(test)
continue_simple :: proc(t: ^testing.T) {
	s := ink.make_story()
	s.root = ink.Container { 	//
		"Simple!",
		"\n",
	}
	testing.expect_value(t, ink.can_continue(s), true)

	l := ink.story_continue(&s)
	testing.expect_value(t, l, "Simple!\n")
	delete(l)

	testing.expect_value(t, ink.can_continue(s), false)
}

// @(test)
continue_two_lines :: proc(t: ^testing.T) {
	s := ink.make_story()
	s.root = ink.Container { 	//
		"First line.",
		"\n",
		"Second line.",
		"\n",
	}
	testing.expect_value(t, ink.can_continue(s), true)

	l := ink.story_continue(&s)
	testing.expect_value(t, l, "First line.\n")
	delete(l)

	testing.expect_value(t, ink.can_continue(s), true)

	l = ink.story_continue(&s)
	testing.expect_value(t, l, "Second line.\n")
	delete(l)

	testing.expect_value(t, ink.can_continue(s), false)
}

@(test)
continue_deeper :: proc(t: ^testing.T) {
	s := ink.make_story()
	s.root = ink.Container {
		ink.Container { 	//
			"Deeper first line.",
			"\n",
			"Deeper second line.",
			"\n",
		},
	}
	testing.expect_value(t, ink.can_continue(s), true)

	l := ink.story_continue(&s)
	testing.expect_value(t, l, "Deeper first line.\n")
	delete(l)

	testing.expect_value(t, ink.can_continue(s), true)

	l = ink.story_continue(&s)
	testing.expect_value(t, l, "Deeper second line.\n")
	delete(l)

	testing.expect_value(t, ink.can_continue(s), false)
}

@(test)
continue_different_levels :: proc(t: ^testing.T) {
	s := ink.make_story()
	s.root = ink.Container {
		ink.Container { 	//
			"Deeper first line, waiting go upper.",
			"\n",
		},
		"Second line.",
		"\n",
	}
	testing.expect_value(t, ink.can_continue(s), true)

	l := ink.story_continue(&s)
	testing.expect_value(t, l, "Deeper first line, waiting go upper.\n")
	delete(l)

	testing.expect_value(t, ink.can_continue(s), true)

	l = ink.story_continue(&s)
	testing.expect_value(t, l, "Second line.\n")
	delete(l)

	testing.expect_value(t, ink.can_continue(s), false)
}
