# Contributing

Thanks for your interest in contributing to lpx_links!

## Getting started

1. Fork and clone the repo
2. Install dependencies: `bundle install`
3. Run tests: `bundle exec rake test`
4. Run lint: `rubocop`

You'll need **Logic Pro**, **MainStage**, or **GarageBand** installed for end-to-end testing. Unit tests work without any apps installed.

## Making changes

1. Create a branch from `main` (`feature/your-thing`, `fix/the-bug`, etc.)
2. Make your changes
3. Add or update tests — we maintain 90%+ coverage
4. Make sure `rubocop` and `bundle exec rake test` both pass
5. Push and open a PR

## Code style

- RuboCop enforces style (see `.rubocop.yml`)
- Target Ruby 3.2+
- `frozen_string_literal: true` in all files
- Keep methods small, raise clear errors

## Commit messages

Write clear messages that explain *why*, not just what. Format:

```
fix: correct input handling for uppercase app names

Replace mutating upcase! with non-mutating upcase to avoid nil returns.

Resolves #46
```

## Technical reference

See [AGENTS.md](../AGENTS.md) for detailed project architecture, app detection paths, CI configuration, conventions, and content size data.

## Need help?

[Open an issue](https://github.com/davidteren/lpx_links/issues) and we'll help you out.
