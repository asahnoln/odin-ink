package ink

import "core:strings"
Story :: struct {
	can_continue: bool,
	root:         Container,
	index_path:   [dynamic]int,
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
		root = c,
	}

	s.can_continue = has_string(s.root)
	return s
}

destroy_story :: proc(s: ^Story) {
	delete(s.index_path)
}

story_continue :: proc(s: ^Story) -> string {
	if !s.can_continue {
		return ""
	}

	b := strings.builder_make()

	c := s.root
	if len(s.index_path) == 0 {
		append(&s.index_path, 0)
		append(&s.index_path, 0)
	}

	for i in s.index_path[:len(s.index_path) - 1] {
		c = c[i].(Container)
	}

	process_container(&b, c, &s.index_path, len(s.index_path) - 1)

	return strings.to_string(b)
}

process_container :: proc(b: ^strings.Builder, c: Container, index_path: ^[dynamic]int, i: int) {
	for index_path[i] < len(c) {
		e := c[index_path[i]].(string)
		strings.write_string(b, e)
		index_path[i] += 1

		if index_path[i] == len(c) && i > 0 {
			pop_safe(index_path)
			index_path[i - 1] += 1
		}

		if e == "\n" {
			return
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
