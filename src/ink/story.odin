package ink

import "core:strings"
Story :: struct {
	can_continue: bool,
	root:         Container,
	index:        int,
}

Element :: union {
	Container,
	string,
}

Container :: []Element

make_story :: proc {
	make_story_empty,
	make_story_from_container,
}

make_story_empty :: proc() -> Story {
	return Story{}
}

make_story_from_container :: proc(c: Container) -> Story {
	s := Story {
		root = c,
	}

	s.can_continue = has_string(s.root)
	return s
}

story_continue :: proc(s: ^Story) -> string {
	if len(s.root) == 0 {
		return ""
	}

	b := strings.builder_make()

	i: int
	for s.index < len(s.root) {
		e := s.root[s.index].(string)
		strings.write_string(&b, e)
		s.index += 1

		if e == "\n" {
			break
		}
	}

	s.can_continue = s.index < len(s.root)

	return strings.to_string(b)

}

has_string :: proc(c: Container) -> bool {
	for e in c {
		if _, ok := e.(string); ok {
			return true
		}
	}

	return false
}
