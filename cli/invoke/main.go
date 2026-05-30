// Command invoke is the Invoke extension developer CLI (PLAN.md §5.6).
//
// A Go binary that (Phase 3) embeds esbuild as a library for sub-second TS→JS
// bundling and hot reload. This skeleton wires up the command surface and the
// `import` codemod entry point (PLAN.md §5.0) using only the standard library,
// so it builds offline today; the bundler/codegen internals land in Phase 3.
package main

import (
	"flag"
	"fmt"
	"os"
)

const version = "0.0.0"

type command struct {
	name string
	help string
	run  func(args []string) error
}

var commands = []command{
	{"develop", "Watch + rebuild the extension and hot-reload it into the running app", cmdDevelop},
	{"build", "Type-check and bundle the extension to ./dist", cmdBuild},
	{"lint", "Lint the manifest, assets, and source against store rules", cmdLint},
	{"import", "Codemod a Raycast extension to Invoke (rewrites @raycast/api → shim, fixes manifest)", cmdImport},
	{"publish", "Publish the extension to the registry", cmdPublish},
	{"create", "Scaffold a new extension from a template", cmdCreate},
}

func main() {
	if len(os.Args) < 2 {
		usage()
		os.Exit(2)
	}
	switch os.Args[1] {
	case "-h", "--help", "help":
		usage()
		return
	case "-v", "--version", "version":
		fmt.Println("invoke", version)
		return
	}
	for _, c := range commands {
		if c.name == os.Args[1] {
			if err := c.run(os.Args[2:]); err != nil {
				fmt.Fprintln(os.Stderr, "error:", err)
				os.Exit(1)
			}
			return
		}
	}
	fmt.Fprintf(os.Stderr, "unknown command %q\n\n", os.Args[1])
	usage()
	os.Exit(2)
}

func usage() {
	fmt.Println("invoke — Invoke extension developer CLI")
	fmt.Println("\nUsage: invoke <command> [flags]\n")
	fmt.Println("Commands:")
	for _, c := range commands {
		fmt.Printf("  %-9s %s\n", c.name, c.help)
	}
	fmt.Println("\nFlags: -h/--help, -v/--version")
}

func cmdDevelop(args []string) error {
	fs := flag.NewFlagSet("develop", flag.ExitOnError)
	dir := fs.String("dir", ".", "extension directory")
	_ = fs.Parse(args)
	// Phase 3: esbuild context watch → rebuild → POST to invoke://develop pid socket.
	return notImplemented("develop", *dir)
}

func cmdBuild(args []string) error {
	fs := flag.NewFlagSet("build", flag.ExitOnError)
	dir := fs.String("dir", ".", "extension directory")
	_ = fs.Parse(args)
	return notImplemented("build", *dir)
}

func cmdLint(args []string) error  { return notImplemented("lint", ".") }
func cmdImport(args []string) error {
	fs := flag.NewFlagSet("import", flag.ExitOnError)
	src := fs.String("src", "", "path to a Raycast extension to codemod")
	_ = fs.Parse(args)
	if *src == "" {
		return fmt.Errorf("usage: invoke import --src <path-to-raycast-extension>")
	}
	// Phase 3: rewrite imports to @raycast/api shim, reconcile manifest key deltas,
	// validate against the top-200 corpus (PLAN.md §5.0).
	return notImplemented("import", *src)
}
func cmdPublish(args []string) error { return notImplemented("publish", ".") }
func cmdCreate(args []string) error  { return notImplemented("create", ".") }

func notImplemented(name, target string) error {
	fmt.Printf("invoke %s [%s] — scaffolded; implementation lands in Phase 3 (see PLAN.md §5.6/§8.2).\n", name, target)
	return nil
}
