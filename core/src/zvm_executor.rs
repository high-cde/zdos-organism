use serde_json::Value;
use zdos_zlang::{parser::Parser, compiler::compile};
use zdos_zvm::vm::ZVM;

pub fn exec_zlang_in_core(src: &str) -> Value {
    let mut parser = Parser::new(src);
    let program = match parser.parse() {
        Ok(p) => p,
        Err(e) => return Value::String(format!("parse error: {e}")),
    };

    let bytecode = compile(&program);

    let mut vm = ZVM::new();
    let result = vm.run(&bytecode);

    serde_json::json!({
        "result": result,
        "vars": vm.vars
    })
}
