use algo_rust_sdk::AlgodClient;
use std::env;

fn main() {
    let mut algod_address: String = String::new();
    let mut algod_token: String = String::new();
    for (k, v) in env::vars() {
        if k == "ALGOD_ADDRESS" {
            algod_address = v.clone();
        }

        if k == "ALGOD_TOKEN" {
            algod_token = v.clone();
        }
    }

    let algod_client = AlgodClient::new(&algod_address, &algod_token);

    // Print algod status
    let node_status = algod_client.status().unwrap();
    println!("algod last round: {}", node_status.last_round);
    println!(
        "algod time since last round: {}",
        node_status.time_since_last_round
    );
    println!("algod catchup: {}", node_status.catchup_time);
    println!("algod latest version: {}", node_status.last_version);

    // Fetch block information
    let last_block = algod_client.block(node_status.last_round).unwrap();
    println!("{:#?}", last_block);
}
