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

	i := 0
	main_loop: for e, i in s.root {
		switch v in e {
		case Container:
		case string:
			strings.write_string(&b, v)
			if v == "\n" {
				break main_loop
			}
		}
	}

	s.can_continue = find_str(s.root[i + 1:])

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
