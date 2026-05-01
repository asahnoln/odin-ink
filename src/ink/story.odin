package ink

import "core:strings"

Story :: struct {
	can_continue: bool,
	root:         Container,
	idx_path:     [dynamic]int,
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
		root     = c,
		idx_path = make([dynamic]int),
	}

	append(&s.idx_path, 0)
	s.can_continue = has_next_str(c, s.idx_path[:])
	return s
}

destroy_story :: proc(s: ^Story) {
	delete(s.idx_path)
}

story_continue :: proc(s: ^Story) -> string {
	if !s.can_continue {
		return ""
	}

	b := strings.builder_make()

	traverse_container(
		s.root,
		&s.idx_path,
		0,
		&b,
		proc(e: Element, data: ^strings.Builder) -> (cont: bool) {
			if str, ok := e.(string); ok {
				b := data
				strings.write_string(b, str)

				if str == "\n" {
					return false
				}
			}

			return true
		},
	)

	s.can_continue = has_next_str(s.root, s.idx_path[:])

	return strings.to_string(b)
}

@(private)
find_str :: proc(c: Container) -> bool {
	for e in c {
		switch v in e {
		case Container:
			if find_str(v) {
				return true
			}
		case string:
			return true
		}
	}

	return false
}
