## TODO

- <strike>Add FPS option</strike>
- If negative FPS is supplied, use a different function which evolves the
system backwards.

### Known Bugs

- If you press Ctrl-C at the precise moment between styling the console bold,
printing to screen, and unstyling the console, you can style your entire console
bold. As a precaution, create a new handler for quitting the game with Ctrl-C,
I feel like this is one of potentially many issues related with Ctrl-C unless
it's handled explicitly.

### Squashed Bugs

- Nonpositive FPS handled explicitly
