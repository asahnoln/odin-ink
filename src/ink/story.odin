package ink

import "core:encoding/json"
import "core:strings"

Apply_Elem_Error :: union {
	Apply_Func_Error,
}

Apply_Func_Error :: struct {
	func: Func,
	x, y: Stack_Element,
}

Element :: union {
	Cmd,
	string,
	f64,
	bool,
	[]Element,
	map[string]Element,
	Divert,
	DivertValue,
	VarAssignTemp,
}

DivertValue :: struct {
	path: string,
}

Divert :: struct {
	path: string,
}

VarAssignTemp :: struct {
	name: string,
}

Mode :: enum {
	Default,
	Evaluation,
	Content,
	Done,
}

Cmd :: enum {
	Ev,
	EvEnd,
	Str,
	StrEnd,
	Done,
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
	root:         Element,
}

Story_Make_Error :: union {
	json.Error,
	JSON_Conversion_Error,
}

story_make :: proc {
	story_make_empty,
	story_make_from_json,
}

story_make_empty :: proc(allocator := context.allocator) -> Story {
	return Story {
		builder = strings.builder_make(allocator),
		ev_stack = make([dynamic]Stack_Element, allocator),
	}
}

story_make_from_json :: proc(
	json_data: []byte,
	allocator := context.allocator,
) -> (
	s: Story,
	err: Story_Make_Error,
) {
	j := json.parse(json_data, allocator = allocator) or_return
	defer json.destroy_value(j, allocator)

	s = story_make(allocator)
	s.root = convert_json(j.(json.Object)["root"], allocator) or_return
	return
}

story_destroy :: proc(s: ^Story, allocator := context.allocator) {
	delete(s.ev_stack)
	strings.builder_destroy(&s.builder)
	destroy_element(s.root, allocator)
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
	case .Done:
		s.mode = .Done
	}
}

apply_elem_func :: proc(s: ^Story, el: Func) -> Apply_Elem_Error {
	x := ev_stack_pop_f64(&s.ev_stack) or_return
	y := ev_stack_pop_f64(&s.ev_stack) or_return

	append(&s.ev_stack, x + y)

	return nil
}


ev_stack_pop_f64 :: proc(st: ^[dynamic]Stack_Element) -> (x: f64, err: Apply_Elem_Error) {
	el := pop(st)

	ok: bool
	x, ok = el.(f64)
	if !ok {
		err = Apply_Func_Error {
			func = .Plus,
			x    = el,
		}
	}

	return
}
