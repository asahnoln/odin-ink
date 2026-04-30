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
		root       = c,
		index_path = make([dynamic]int),
	}

	s.can_continue = find_str(s.root)
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

	for e in s.root {
		strings.write_string(&b, e.(string))
	}

	s.can_continue = false

	return strings.to_string(b)
}

@(private)
find_str :: proc(c: Container) -> bool {
	for e in c {
		switch v in e {
		case Container:
			return find_str(v)
		case string:
			return true
		}
	}

	return false
}
