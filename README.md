# ba.sh

Bash Additional SHell scripts.

Bash framework that includes a collection of reusable shell scripts (bash-compatible) that utilise existing bash capabilities as much as possible, prioritising them over other command line tools.

## System requirements

The original platform is Debian stable (and whatever bash version it provides), so if something doesn't work as you expect, feel free to raise an issue or just fix it yourself.

No Mac support expected, unless you buy me an Apple device. I'm not buying one myself, that's for sure.

## Q&A

### Q: Why don't you want to support Mac?

A: It's not like I hate it or something, it's because by default it uses bash version 3, which is very old, and it might require extra code to do the same things later versions can do out of the box.
I will probably consider it later on, just not right away.

### Q: Why are you doing this?

A: Well, bash is not the simplest thing to learn to the level where you solve most of your problems with it, so it's mostly to make it easier for other people so they could learn some use cases and what bash is capable of.
And it's also to make scripts more self-sufficient, avioding external calls where possible and practical to do so. For example, filtering out a string by a specific substring when you don't have a lot of them.
You could just grep'em out, but you could also use bash process that is already working to do the same. The main issue here is that it takes more code in bash, unless you already have it.

Another reason is that you don't really need much if you want to run scripts in an isolated minimised environment.
There is a lot of examples in some languages where people use one function to write a script, but it requires a library that depends on some other libraries, and then it just becomes unnecessarily complex for the purpose, and just blows up.
More vulnerabilities, more maintenance, more everything. Ba.sh is expected to be an example of "Less is more" approach and still expected to work years after implementation (special hello to node.js and python).

And it's also a lot of fun for me.

### Q: Is ba.sh production ready?

A: Oh, God no. It won't be probably ready for production purposes until bundling implementation, security measures and linter integration (this one is a good problem to solve if you consider that we can generate some code before executing it).
And even then I can't say anything about it's readiness, it just makes some things a bit easier, but using it is completely your responsibility. It's provided as is with no guarantees.

### Q: There is something that I think would be nice to have. How do I request a feature?

A: Create an issue with a feature request or create a pull request if you feel like it. This repo comes with no promises.

