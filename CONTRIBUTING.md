# Contributing to Rectify

:sparkling_heart: Thank you for taking the time to contribute! :sparkling_heart:

Here is a quick guide to contributing to Rectify that will hopefully help save
you some time and increase the chance that your change will be merged.

## Before you make a change

Firstly, you should fork the repository and clone that down to your machine. You
should check that the specs run green. You can do this as follows:

```
bundle exec rspec
```

If you plan to make a large change or addition we suggest first opening an issue
in the [GitHub issue tracker](https://github.com/andypike/rectify/issues) to
discuss the change before you start work. This is to make sure that the change
you would like to make is inline with the project vision. This will save you
from spending time on a change that may not be merged later.

Please install [Rubocop](https://github.com/bbatsov/rubocop) as we use it to
enforce our style guide. Please review `.rubocop.yml` before making any change
to ensure you match the project's style guide.

Please create an appropriately named branch to hold your changes. Do not make
changes to `master`.

## Submitting your change

Please send a GitHub Pull Request upstream to the main project repository. Your
change should include the following:

* A clear description of the change
* A clean git commit history (see [How to Write a Git Commit Message](http://chris.beams.io/posts/git-commit/))
* Specs that cover your change
* All specs should pass
* No Rubocop style violations

Once we receive the Pull Request we will review it and may suggest changes.
After the changes have been made (if required) we will merge the change into
master.

We reserve the right to reject Pull Requests that we feel do not follow the
guide above.
