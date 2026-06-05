use crate::ast::{Program, Statement, Expr};

pub fn mutate_ast(program: &mut Program) {
    for stmt in &mut program.statements {
        if let Statement::Let { value, .. } = stmt {
            if let Expr::Number(n) = value {
                *n += 1.0; // mutazione semantica semplice
            }
        }
    }
}
