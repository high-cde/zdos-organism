use crate::ast::*;
use zdos_zvm::bytecode::BytecodeProgram;
use zdos_zvm::opcode::Opcode;

pub fn compile(program: &Program) -> BytecodeProgram {
    let mut code = Vec::new();
    compile_statements(&program.statements, &mut code);
    code.push(Opcode::Halt);
    BytecodeProgram { code }
}

fn compile_statements(statements: &[Statement], out: &mut Vec<Opcode>) {
    for statement in statements {
        match statement {
            Statement::Let { name, value } => {
                compile_expr(value, out);
                out.push(Opcode::Store(name.clone()));
            }
            Statement::Expr(expr) => compile_expr(expr, out),
            Statement::If {
                branches,
                otherwise,
            } => compile_if(branches, otherwise, out),
        }
    }
}

fn compile_if(branches: &[(Expr, Vec<Statement>)], otherwise: &[Statement], out: &mut Vec<Opcode>) {
    let mut end_jumps = Vec::new();
    for (condition, body) in branches {
        compile_expr(condition, out);
        let false_jump = out.len();
        out.push(Opcode::JumpIfFalse(usize::MAX));
        compile_statements(body, out);
        end_jumps.push(out.len());
        out.push(Opcode::Jump(usize::MAX));
        let next_branch = out.len();
        out[false_jump] = Opcode::JumpIfFalse(next_branch);
    }
    compile_statements(otherwise, out);
    let end = out.len();
    for jump in end_jumps {
        out[jump] = Opcode::Jump(end);
    }
}

fn compile_expr(expr: &Expr, out: &mut Vec<Opcode>) {
    match expr {
        Expr::Number(number) => out.push(Opcode::Push(*number)),
        Expr::Ident(name) => out.push(Opcode::Load(name.clone())),
        Expr::Binary { op, left, right } => {
            compile_expr(left, out);
            compile_expr(right, out);
            out.push(match op.as_str() {
                "+" => Opcode::Add,
                "-" => Opcode::Sub,
                "*" => Opcode::Mul,
                "/" => Opcode::Div,
                ">" => Opcode::Greater,
                "<" => Opcode::Less,
                ">=" => Opcode::GreaterEqual,
                "<=" => Opcode::LessEqual,
                _ => Opcode::Halt,
            });
        }
    }
}
