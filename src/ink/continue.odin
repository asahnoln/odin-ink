package ink

has_next_str :: proc(c: Container, idx_path: []int) -> bool {
	idx_path_dyn := make([dynamic]int)
	defer delete(idx_path_dyn)

	for i in idx_path {
		append(&idx_path_dyn, i)
	}

	return(
		!traverse_container(c, &idx_path_dyn, 0, proc(e: Element, data: struct{}) -> (cont: bool) {
			str, ok := e.(string)
			return !ok
		}, struct{}{}) \
	)
}

traverse_container :: proc(
	c: Container,
	idx_path: ^[dynamic]int,
	deep_idx: int,
	callback: proc(e: Element, data: $T) -> (cont: bool),
	data: T,
) -> (
	cont: bool,
) {
	defer if idx_path[deep_idx] == len(c) {
		pop_safe(idx_path)

		if deep_idx > 0 {
			idx_path[deep_idx - 1] += 1
		}
	}

	if len(idx_path) > deep_idx + 1 {
		traverse_container(
			c[idx_path[deep_idx]].(Container),
			idx_path,
			deep_idx + 1,
			callback,
			data,
		) or_return
	}

	base := idx_path[deep_idx]
	for e, i in c[base:] {
		if cntr, ok := e.(Container); ok {
			append(idx_path, 0)
			traverse_container(cntr, idx_path, len(idx_path) - 1, callback, data)
			continue
		}

		idx_path[deep_idx] = base + i + 1

		callback(e, data) or_return
	}

	return true
}
