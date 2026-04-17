package ink_test

import "core:testing"

@(test)
api :: proc(t: ^testing.T) {
	testing.expect(t, 1 != 1, "implement API")
}
