# rust

We need to be able to compile a teal program as part of our process.

In particular, the function we need is similar to this example from the go sdk: https://github.com/algorand/go-algorand-sdk/blob/bfd9fd3e15d8a5ac7e705ae64a985949644102e3/client/v2/algod/tealCompile.go#L21-L24

```go
func (s *TealCompile) Do(ctx context.Context, headers ...*common.Header) (response models.CompileResponse, err error) {
	err = s.c.post(ctx, &response, "/v2/teal/compile", s.source, headers)
	return
}
```

# SDK review

|SDK|Can Compile teal|
|---|---|
|[algo_rust_sdk v1.0.3](https://docs.rs/algo_rust_sdk/1.0.3/algo_rust_sdk/algod/struct.AlgodClient.html)|No
|[algonaut_client v0.2.0](https://docs.rs/algonaut_client/0.2.0/algonaut_client/algod/v2/struct.Client.html#method.compile_teal)|Yes

This example uses `algonaut_client` in order to avoid calling out to `goal`

# Using goal

For reference, this function can be used to call out to `goal` to do the compilation:

```rust
use std::env;
use std::io::Error;
use std::process::{Command, Output};

fn compile(fname: &str) -> Result<Output, Error> {
    // note that `goal` needs to be available on the system path since
    // using `goal` from within sandbox can be tricky because files
    // need to be copied to/from the algod container
    let binpath: String = env::var("ALGORAND_BIN").unwrap();
    Command::new("goal")
        .args(&["clerk", "compile", fname])
        .env("PATH", binpath)
        .output()
}

fn main() {
    let contract_address = match compile("passphrase.teal") {
        Ok(o) => {
            let stdout = o.stdout.clone();
            String::from_utf8(stdout)
                .unwrap()
                .split_whitespace()
                .last()
                .unwrap()
                .to_owned()
        }
        Err(e) => {
            println!("error compiling teal contract: {}", e);
            std::process::exit(1)
        }
    };
}
```

