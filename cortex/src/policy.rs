use serde_json::Value;
use zdos_zlang::runtime;

/// Policy minimale espressa in ZLang.
///
/// Il valore `block` viene normalizzato a 1.0/0.0 prima dell'esecuzione:
/// la policy conserva quindi il comportamento storico (un blocco non nullo
/// abilita la mutazione), ma la decisione viene ora valutata dalla ZVM.
const ALLOW_MUTATION_POLICY: &str = "let block = {block} block";

#[derive(Debug, thiserror::Error)]
pub enum PolicyError {
    #[error("policy ZLang non valida: {0}")]
    Runtime(#[from] zdos_zlang::runtime::RuntimeError),
}

pub fn allow_mutation(signal: &Value) -> Result<bool, PolicyError> {
    let block = signal
        .get("block")
        .map(|value| !value.is_null())
        .unwrap_or(false);
    let source = ALLOW_MUTATION_POLICY.replace("{block}", if block { "1" } else { "0" });
    let result = runtime::execute(&source)?;
    Ok(result["result"].as_f64().unwrap_or(0.0) != 0.0)
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn zlang_policy_allows_non_null_block() {
        assert!(allow_mutation(&json!({"block": 42})).unwrap());
    }

    #[test]
    fn zlang_policy_rejects_missing_or_null_block() {
        assert!(!allow_mutation(&json!({})).unwrap());
        assert!(!allow_mutation(&json!({"block": null})).unwrap());
    }
}
