package ink

import "core:strings"

Story :: struct {
	root:              Container,
	current_container: Detailed_Container,
}

Detailed_Container :: struct {
	parent: ^Detailed_Container,
	c:      Container,
	index:  int,
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
		s.current_container.c = s.root
	}

	if len(s.current_container.c) == 0 {
		return ""
	}

	b := strings.builder_make()

	defer if s.current_container.parent != nil &&
	   s.current_container.index == len(s.current_container.c) {
		p := s.current_container.parent

		s.current_container.c = p.c
		s.current_container.index = p.index
		s.current_container.parent = p.parent

		free(p)
	}

	for s.current_container.index < len(s.current_container.c) {
		e := s.current_container.c[s.current_container.index]

		if c, ok := e.(Container); ok {
			p := new(Detailed_Container)
			p.parent = s.current_container.parent
			p.c = s.current_container.c
			p.index = s.current_container.index + 1

			s.current_container.parent = p
			s.current_container.c = c
			s.current_container.index = 0

			return story_continue(s)
		}

		strings.write_string(&b, e.(string))
		s.current_container.index += 1

		if e.(string) == "\n" {
			break
		}
	}

	return strings.to_string(b)
}


can_continue :: proc(s: Story) -> bool {
	c := s.current_container.c if s.current_container.c != nil else s.root
	return s.current_container.index < len(c)
}
