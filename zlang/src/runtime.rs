use crate::compiler::compile;
use crate::parser::{ParseError, Parser};
use serde_json::{json, Value};
use thiserror::Error;
use zdos_zvm::vm::{VmError, ZVM};

#[derive(Debug, Error)]
pub enum RuntimeError {
    #[error("parse error: {0}")]
    Parse(#[from] ParseError),
    #[error("VM error: {0}")]
    Vm(#[from] VmError),
}

pub fn execute(code: &str) -> Result<Value, RuntimeError> {
    let mut parser = Parser::new(code);
    let program = parser.parse()?;
    let bytecode = compile(&program);
    let mut vm = ZVM::new();
    let result = vm.run(&bytecode)?;
    Ok(json!({ "status": "ok", "result": result, "statements": program.statements.len() }))
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn executes_real_zlang() {
        let output = execute("+ 2 3").unwrap();
        assert_eq!(output["result"], 5.0);
        assert_eq!(output["status"], "ok");
    }
    #[test]
    fn propagates_vm_errors() {
        assert!(matches!(
            execute("/ 1 0"),
            Err(RuntimeError::Vm(VmError::DivisionByZero))
        ));
    }
}
