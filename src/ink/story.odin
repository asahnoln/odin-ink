package ink

Mode :: enum {
	Default,
	Evaluation,
	Content,
}

Cmd :: enum {
	Ev,
	EvEnd,
	Str,
	StrEnd,
}

Story :: struct {
	mode: Mode,
}

story_make :: proc() -> Story {
	return Story{}
}

story_destroy :: proc(s: ^Story) {
}

apply_elem :: proc(s: ^Story, c: Cmd) {
	switch c {
	case .Ev:
		s.mode = .Evaluation
	case .EvEnd:
		s.mode = .Default
	case .Str:
		s.mode = .Content
	case .StrEnd:
		s.mode = .Evaluation
	}
}
