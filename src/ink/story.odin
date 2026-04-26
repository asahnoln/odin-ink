package ink

import "core:strings"

Story :: struct {
	root:              Container,
	index:             int,
	current_container: ^Container,
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
	if s.current_container == nil {
		s.current_container = &s.root
	}

	if len(s.current_container) == 0 {
		return ""
	}

	b := strings.builder_make()

	for s.index < len(s.current_container) {
		e := s.current_container[s.index]

		if _, ok := e.(Container); ok {
			s.current_container = &s.current_container[s.index].(Container)
			s.index = 0
			return story_continue(s)
		}

		strings.write_string(&b, e.(string))
		s.index += 1

		if e.(string) == "\n" {
			break
		}
	}

	if s.current_container != nil &&
	   s.current_container != &s.root &&
	   s.index == len(s.current_container) {
		s.current_container = &s.root
		s.index = 1
	}

	return strings.to_string(b)
}


can_continue :: proc(s: Story) -> bool {
	c := s.current_container^ if s.current_container != nil else s.root
	return s.index < len(c)
}
