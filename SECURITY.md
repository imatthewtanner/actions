# Security policy

## Supported versions

Security fixes target the current `master` branch of this private downstream. No downstream binary release is currently supported.

## Reporting a vulnerability

Use GitHub's private vulnerability reporting flow if it is enabled for this repository. Otherwise, email `admin@tannerpress.onmicrosoft.com` with subject `llm_wiki security report`. Do not include credentials, tokens, private documents, personal data, or a working exploit in an issue or pull request.

Include the affected commit, platform, prerequisite configuration, impact, reproduction outline, and any known mitigation. Allow maintainers time to validate and coordinate a fix before disclosure.

## Sensitive surfaces

Changes involving imported documents, Markdown/Mermaid rendering, filesystem paths, the loopback HTTP API, MCP clients, provider credentials, web retrieval, agent tools, shell execution, generated files, native permissions, signing, or updates require explicit threat and regression review.

Never commit application data, provider keys, signing material, or GitHub secrets. Use least-privilege test credentials and non-sensitive fixtures.
