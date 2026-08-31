package ink

import "core:strings"
Element :: union {
	Container,
	Container_Info,
	string,
	Control_Command,
}

Container :: []Element

Container_Flag :: enum {
	Visits,
	Turns,
	Count_Start_Only,
}

Container_Flag_Set :: bit_set[Container_Flag]

Container_Info :: struct {
	flags: Container_Flag_Set,
	name:  string,
}

Control_Command :: enum {
	Done,
}

Story :: struct {
	root: Container,
}

story_make :: proc {
	story_make_empty,
	story_make_from_struct,
}

story_make_empty :: proc() -> Story {
	return {}
}

story_make_from_struct :: proc(c: Container) -> Story {
	return {root = c}
}

story_continue :: proc(s: ^Story) -> string {
	b := strings.builder_make()
	defer strings.builder_destroy(&b)

	_process_container(s.root, &b)

	return strings.to_string(b)
}

_process_container :: proc(c: Container, b: ^strings.Builder) -> (cont: bool) {
	for e in c {
		#partial switch v in e {
		case Container:
			_process_container(v, b) or_return
		case string:
			strings.write_string(b, v)

			if e.(string) == "\n" {
				return false
			}
		}
	}
	return true
}
