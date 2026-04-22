package ink

import "core:strings"

Element :: union {
	Cmd,
	string,
	f64,
	bool,
	[]Element,
	map[string]Element,
}

Apply_Elem_Err :: union {
	Apply_Func_Err,
}

Apply_Func_Err :: struct {
	func: Func,
	x, y: Stack_Element,
}

Mode :: enum {
	Default,
	Evaluation,
	Content,
}

Cmd :: enum {
	Ev,
	EvEnd,
	Str,
	StrEnd,
}

Func :: enum {
	Plus,
}

Stack_Element :: union {
	f64,
	string,
}

Story :: struct {
	mode:         Mode,
	ev_stack:     [dynamic]Stack_Element,
	current_text: string,
	builder:      strings.Builder,
}

story_make :: proc() -> Story {
	return Story{builder = strings.builder_make()}
}

story_destroy :: proc(s: ^Story) {
	delete(s.ev_stack)
	strings.builder_destroy(&s.builder)
}

apply_elem :: proc {
	apply_elem_cmd,
	apply_elem_func,
	apply_elem_str,
}

apply_elem_str :: proc(s: ^Story, el: string) {
	strings.write_string(&s.builder, s.current_text)
	strings.write_string(&s.builder, el)
	s.current_text = strings.to_string(s.builder)

	strings.builder_reset(&s.builder)
}

apply_elem_cmd :: proc(s: ^Story, el: Cmd) {
	switch el {
	case .Ev:
		s.mode = .Evaluation
	case .EvEnd:
		s.mode = .Default
	case .Str:
		s.mode = .Content
	case .StrEnd:
		s.mode = .Evaluation
	}
}

apply_elem_func :: proc(s: ^Story, el: Func) -> Apply_Elem_Err {
	x := ev_stack_pop_f64(&s.ev_stack) or_return
	y := ev_stack_pop_f64(&s.ev_stack) or_return

	append(&s.ev_stack, x + y)

	return nil
}


ev_stack_pop_f64 :: proc(st: ^[dynamic]Stack_Element) -> (x: f64, err: Apply_Elem_Err) {
	el := pop(st)

	ok: bool
	x, ok = el.(f64)
	if !ok {
		err = Apply_Func_Err {
			func = .Plus,
			x    = el,
		}
	}

	return
}
