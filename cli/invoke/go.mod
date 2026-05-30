module github.com/your-handle/invoke/cli

go 1.25

// Phase 3 will add the bundler dependency:
//   require github.com/evanw/esbuild v0.24.0
// esbuild is embedded as a library (not shelled out) for sub-second dev rebuilds.
