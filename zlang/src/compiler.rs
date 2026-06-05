use crate::ast::*;
use zdos_zvm::opcode::Opcode;
use zdos_zvm::bytecode::BytecodeProgram;

pub fn compile(program: &Program) -> BytecodeProgram {
    let mut code = Vec::new();

    for stmt in &program.statements {
        match stmt {
            Statement::Let { name, value } => {
                compile_expr(value, &mut code);
                code.push(Opcode::Store(name.clone()));
            }
            Statement::Expr(expr) => {
                compile_expr(expr, &mut code);
            }
        }
    }

    code.push(Opcode::Halt);

    BytecodeProgram { code }
}

fn compile_expr(expr: &Expr, out: &mut Vec<Opcode>) {
    match expr {
        Expr::Number(n) => out.push(Opcode::Push(*n)),
        Expr::Ident(name) => out.push(Opcode::Load(name.clone())),
        Expr::Binary { op, left, right } => {
            compile_expr(left, out);
            compile_expr(right, out);
            match op.as_str() {
                "+" => out.push(Opcode::Add),
                "-" => out.push(Opcode::Sub),
                "*" => out.push(Opcode::Mul),
                "/" => out.push(Opcode::Div),
                _ => {}
            }
        }
    }
}
