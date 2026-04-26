package ink

import "core:strings"
Story :: struct {
	can_continue:      bool,
	root:              Container,
	index:             int,
	current_container: Container,
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
	b := strings.builder_make()

	for s.index < len(s.current_container) {
		e := s.current_container[s.index]

		switch v in e {
		case Container:
			s.current_container = v
			return story_continue(s)
		case string:
			strings.write_string(&b, v)
			s.index += 1
			if v == "\n" {
				s.can_continue = s.index < len(s.current_container)
				return strings.to_string(b)
			}
		}
	}


	return ""

}

has_string :: proc(c: Container) -> bool {
	for e in c {
		if _, ok := e.(string); ok {
			return true
		}
	}

	return false
}
