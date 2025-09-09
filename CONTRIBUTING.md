# Contributing to Chattingo

We love your input! We want to make contributing to Chattingo as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## Development Process

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

## Pull Requests

Pull requests are the best way to propose changes to the codebase. We actively welcome your pull requests:

1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes.
5. Make sure your code lints.
6. Issue that pull request!

## Any contributions you make will be under the MIT Software License

In short, when you submit code changes, your submissions are understood to be under the same [MIT License](http://choosealicense.com/licenses/mit/) that covers the project. Feel free to contact the maintainers if that's a concern.

## Report bugs using GitHub's [issue tracker](https://github.com/Iwill01/chattingo/issues)

We use GitHub issues to track public bugs. Report a bug by [opening a new issue](https://github.com/Iwill01/chattingo/issues/new); it's that easy!

## Write bug reports with detail, background, and sample code

**Great Bug Reports** tend to have:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample code if you can
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

## Development Setup

### Prerequisites
- Docker & Docker Compose
- Node.js 18+
- Java 17+
- Maven 3.8+

### Local Development

1. **Clone your fork**
```bash
git clone https://github.com/Iwill01/chattingo.git
cd chattingo
```

2. **Start the development environment**
```bash
docker-compose up -d
```

3. **Run tests**
```bash
# Backend tests
cd backend && ./mvnw test

# Frontend tests
cd frontend && npm test
```

### Code Style

#### Backend (Java)
- Follow standard Java conventions
- Use meaningful variable and method names
- Add JavaDoc comments for public methods
- Keep methods small and focused

#### Frontend (JavaScript/React)
- Use ESLint and Prettier for code formatting
- Follow React best practices
- Use functional components with hooks
- Write meaningful component and variable names

### Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

### Testing

- Write tests for new features
- Ensure all tests pass before submitting PR
- Maintain or improve code coverage

### Documentation

- Update README.md if needed
- Add inline comments for complex logic
- Update API documentation for backend changes

## License

By contributing, you agree that your contributions will be licensed under its MIT License.

## References

This document was adapted from the open-source contribution guidelines for [Facebook's Draft](https://github.com/facebook/draft-js/blob/a9316a723f9e918afde44dea68b5f9f39b7d9b00/CONTRIBUTING.md)
