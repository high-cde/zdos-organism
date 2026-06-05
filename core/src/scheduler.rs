use serde_json::Value;

pub fn schedule_biosignal(signal: &Value) {
    println!("[CORE][SCHEDULER] received signal: {signal}");
}
