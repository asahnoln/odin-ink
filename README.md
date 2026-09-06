# Odin port of Ink

> [!WARNING]
> Work in progress!

## API

Adapt original Ink API

```odin
// 1) Load story
story := ink.story_make(source_json_string);

// 2) Game content, line by line
for story.can_continue {
    fmt.print(ink.story_continue(&story));
}

// 3) Display story.current_choices list, allow player to choose one
fmt.println(story.current_choices[0].text);
ink.choose_choice_index(&story, 0);
```

## TODO

- [ ] Compare how can_continue works in original - should it be able to predict no content ahead?
- [ ] Implement json conversion and story application for:
  - [ ] variable pointer
  - [ ] void
  - [ ] Control commands
    - [x] ev
    - [x] /ev
    - [ ] out
    - [ ] pop
    - [ ] ->->, ~ret
    - [ ] du
    - [x] str
    - [ ] /str
    - [ ] nop
    - [ ] choiceCnt
    - [ ] turn
    - [ ] turns
    - [ ] visit
    - [ ] seq
    - [ ] thread
    - [ ] done
    - [ ] end
  - [ ] Native functions
    - [ ] `"+"`
    - [ ] `"-"`
    - [ ] `"/"`
    - [ ] `"*"`
    - [ ] `"%"` (mod)
    - [ ] `"_"` (unary negate)
    - [ ] `"=="`
    - [ ] `">"`
    - [ ] `"<"`
    - [ ] `">="`
    - [ ] `"<="`
    - [ ] `"!="`
    - [ ] `"!"` (unary 'not')
    - [ ] `"&&"`
    - [ ] `"||"`
    - [ ] `"MIN"`
    - [ ] `"MAX"`
  - [ ] Divert
    - [x] `{"->": "path.to.target"}`
    - [x] `{"->": "variableTarget", "var": true}`
    - [ ] `{"f()": "path.to.func"}`
    - [ ] `{"->t->": "path.tunnel"}`
    - [ ] `{"x()": "externalFuncName", "exArgs": 5}`
    - [ ] `c` property for conditional divert
  - [ ] Var assignment
    - [ ] `{"VAR=": "money", "re": true}`
    - [x] `{"temp=": "x"}`
  - [ ] Var reference
    - [ ] `{"VAR?": "danger"}`
  - [ ] Read count
    - [ ] `{"CNT?": "the_hall.light_switch"}`
  - [x] Choice point
  - [x] Paths
- [ ] Refactor TODOs in code
