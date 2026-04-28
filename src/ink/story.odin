package ink

import "core:strings"
Story :: struct {
	can_continue:      bool,
	root:              Container,
	index:             int,
	current_container: Container,
	last_indexes:      [dynamic]int,
	parents:           [dynamic]Container,
}

Element :: union {
	Container,
	string,
}

Container :: distinct []Element

make_story :: proc {
	make_story_from_container,
}

make_story_from_container :: proc(c: Container) -> Story {
	s := Story {
		root              = c,
		current_container = c,
	}

	s.can_continue = has_string(s.root)
	return s
}

story_continue :: proc(s: ^Story) -> string {
	if !s.can_continue {
		return ""
	}

	b := strings.builder_make()

	collect(&b, s.root)

	s.can_continue = false

	return strings.to_string(b)
}

collect :: proc(b: ^strings.Builder, c: Container) {
	for e in c {
		switch v in e {
		case Container:
			collect(b, v)
		case string:
			strings.write_string(b, v)

			if v == "\n" {
				return
			}
		}
	}
}

has_string :: proc(c: Container) -> bool {
	for e in c {
		if _, ok := e.(string); ok {
			return true
		}
	}

	return false
}
