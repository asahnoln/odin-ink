package ink_test

import "core:testing"
import "src:ink"

@(test)
apply_elem_cmd_ev :: proc(t: ^testing.T) {
	s := ink.story_make()
	defer ink.story_destroy(&s)

	ink.apply_elem(&s, ink.Cmd.Ev)
	testing.expect(t, s.mode == .Evaluation)

	ink.apply_elem(&s, ink.Cmd.EvEnd)
	testing.expect(t, s.mode == .Default)
}

@(test)
apply_elem_cmd_str :: proc(t: ^testing.T) {
	s := ink.story_make()
	defer ink.story_destroy(&s)

	ink.apply_elem(&s, ink.Cmd.Str)
	testing.expect(t, s.mode == .Content)
	ink.apply_elem(&s, ink.Cmd.StrEnd)
	testing.expect(t, s.mode == .Evaluation)
}

@(test)
apply_elem_cmd_done :: proc(t: ^testing.T) {
	s := ink.story_make()
	defer ink.story_destroy(&s)

	ink.apply_elem(&s, ink.Cmd.Done)
	testing.expect(t, s.mode == .Done)
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
	testing.expect_value(t, err, ink.Stack_Element_Cast_Error{T = f64, v = "NO"})
}

@(test)
apply_elem_func_err_short_stack :: proc(t: ^testing.T) {
	s := ink.story_make()
	defer ink.story_destroy(&s)

	err := ink.apply_elem(&s, ink.Func.Plus)
	testing.expect_value(t, err, ink.Error.Short_Stack)
}

@(test)
apply_elem_str :: proc(t: ^testing.T) {
	s := ink.story_make()
	defer ink.story_destroy(&s)

	ink.apply_elem(&s, "Text")
	testing.expect_value(t, s.current_text_array[0], "Text")

	ink.apply_elem(&s, "\n")
	testing.expect_value(t, s.current_text_array[1], "\n")
}

@(test)
apply_elem_choice :: proc(t: ^testing.T) {
	s := ink.story_make()
	append(&s.ev_stack, "Choose me!")
	defer ink.story_destroy(&s)

	err := ink.apply_elem(&s, ink.Choice{path = "path.to.smth"})
	if !testing.expect_value(t, err, nil) {
		return
	}

	testing.expect_value(t, len(s.current_choices), 1)
	testing.expect_value(
		t,
		s.current_choices[0],
		ink.Choice{path = "path.to.smth", text = "Choose me!"},
	)
}

@(test)
apply_elem_tempvar :: proc(t: ^testing.T) {
	s := ink.story_make()
	append(&s.ev_stack, ink.DivertValue{path = "lol"})
	defer ink.story_destroy(&s)

	err := ink.apply_elem(&s, ink.VarAssignTemp{name = "someVar"})
	if !testing.expect_value(t, err, nil) {
		return
	}

	testing.expect_value(t, len(s.ev_stack), 0)
	testing.expect_value(
		t,
		s.vars["someVar"],
		ink.VarAssignTemp{name = "someVar", v = ink.DivertValue{path = "lol"}},
	)
}

// @(test)
// apply_elem_divert :: proc(t: ^testing.T) {
// 	s := ink.story_make()
// 	defer ink.story_destroy(&s)
//
// 	err := ink.apply_elem(&s, ink.Divert{path = "0.0.s"})
// 	if !testing.expect_value(t, err, nil) {
// 		return
// 	}
//
// 	testing.expect_value(t, s.divert_container, ink.Divert_Container{c = ink.Container{}, i = 0})
// }
