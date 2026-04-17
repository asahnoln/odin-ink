# Odin port of Ink

## API

Adapt original Ink API

```odin
// 1) Load story
story := ink.load(source_json_string);

// 2) Game content, line by line
for story.can_continue {
    fmt.println(ink.continue(&story));
}

// 3) Display story.current_choices list, allow player to choose one
fmt.println(story.current_choices[0].text);
ink.choose_choice_index(&story, 0);
```

## TODO

- [ ] Figure out story structure in code
- [ ] Parse choices
