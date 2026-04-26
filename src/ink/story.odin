package ink

import "core:strings"

Story :: struct {
	root:              Container,
	index:             int,
	current_container: Detailed_Container,
}

Detailed_Container :: struct {
	parent:     ^Container,
	c:          ^Container,
	last_index: int,
}

Element :: union {
	Container,
	string,
}

Container :: []Element

make_story :: proc() -> Story {
	return Story{}
}

story_continue :: proc(s: ^Story) -> string {
	if s.current_container.c == nil {
		s.current_container = {
			c = &s.root,
		}
	}

	if len(s.current_container.c) == 0 {
		return ""
	}

	b := strings.builder_make()

	for s.index < len(s.current_container.c) {
		e := s.current_container.c[s.index]

		if _, ok := e.(Container); ok {
			s.current_container.parent = s.current_container.c
			s.current_container.c = &s.current_container.c[s.index].(Container)
			s.current_container.last_index = s.index + 1
			s.index = 0
			return story_continue(s)
		}

		strings.write_string(&b, e.(string))
		s.index += 1

		if e.(string) == "\n" {
			break
		}
	}

	if s.current_container.parent != nil && s.index == len(s.current_container.c) {
		s.current_container.c = s.current_container.parent
		s.current_container.parent = nil
		s.index = s.current_container.last_index
	}

	return strings.to_string(b)
}


can_continue :: proc(s: Story) -> bool {
	c := s.current_container.c^ if s.current_container.c != nil else s.root
	return s.index < len(c)
}
