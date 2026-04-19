package ink_test

import "core:testing"
import "src:ink"

@(test)
apply_elem_cmd_ev :: proc(t: ^testing.T) {
	s := ink.story_make()
	defer ink.story_destroy(&s)

	ink.apply_elem(&s, .Ev)
	testing.expect_value(t, s.mode, ink.Mode.Evaluation)

	ink.apply_elem(&s, .EvEnd)
	testing.expect_value(t, s.mode, ink.Mode.Default)
}

@(test)
apply_elem_cmd_str :: proc(t: ^testing.T) {
	s := ink.story_make()
	defer ink.story_destroy(&s)

	ink.apply_elem(&s, .Str)
	testing.expect_value(t, s.mode, ink.Mode.Content)

	ink.apply_elem(&s, .StrEnd)
	testing.expect_value(t, s.mode, ink.Mode.Evaluation)
}
