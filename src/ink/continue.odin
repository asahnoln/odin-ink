package ink

has_next_str :: proc(c: Container, idx_path: []int) -> bool {
	if len(idx_path) == 0 {
		return false
	}

	idx_path_dyn := make([dynamic]int)
	defer delete(idx_path_dyn)

	for i in idx_path {
		append(&idx_path_dyn, i)
	}

	return(
		!traverse_container(
			c,
			&idx_path_dyn,
			0,
			struct{}{},
			proc(e: Element, data: struct{}) -> (cont: bool) {
				str, ok := e.(string)
				return !ok
			},
		) \
	)
}
