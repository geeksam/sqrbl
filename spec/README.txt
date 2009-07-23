Spec notes:

- When you see "foo.should_receive(:bar).with(self)" inside a block, it's probably a hack that takes advantage of the fact that the block is being instance_eval'd somewhere else.
- When you see "foo.should_receive(:bar).with(some_args).and_yield", the and_yield means that the #bar method on foo must be sent a block parameter.
