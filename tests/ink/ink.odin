package ink_test

import "core:testing"
import "src:ink"

@(test)
apply_elem_cmd_ev :: proc(t: ^testing.T) {
	s := ink.story_make()
	defer ink.story_destroy(&s)

	ink.apply_elem(&s, ink.Cmd.Ev)
	testing.expect_value(t, s.mode, ink.Mode.Evaluation)

	ink.apply_elem(&s, ink.Cmd.EvEnd)
	testing.expect_value(t, s.mode, ink.Mode.Default)
}

@(test)
apply_elem_cmd_str :: proc(t: ^testing.T) {
	s := ink.story_make()
	defer ink.story_destroy(&s)

	ink.apply_elem(&s, ink.Cmd.Str)
	testing.expect_value(t, s.mode, ink.Mode.Content)

	ink.apply_elem(&s, ink.Cmd.StrEnd)
	testing.expect_value(t, s.mode, ink.Mode.Evaluation)
}

@(test)
apply_elem_func :: proc(t: ^testing.T) {
	s := ink.story_make()
	append(&s.ev_stack, 2, 1.25)
	defer ink.story_destroy(&s)

	err := ink.apply_elem(&s, ink.Func.Plus)
	testing.expect_value(t, err, nil)
	testing.expect_value(t, len(s.ev_stack), 1)
	testing.expect_value(t, s.ev_stack[0], 3.25)
}

@(test)
apply_elem_func_err :: proc(t: ^testing.T) {
	s := ink.story_make()
	append(&s.ev_stack, 2, "NO")
	defer ink.story_destroy(&s)

	err := ink.apply_elem(&s, ink.Func.Plus)
	testing.expect_value(t, err, ink.Apply_Func_Err{func = .Plus, x = "NO"})
}
