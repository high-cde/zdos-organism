use crate::ast::{Expr, Program, Statement};

pub fn mutate_ast(program: &mut Program) {
    for stmt in &mut program.statements {
        if let Statement::Let {
            value: Expr::Number(n),
            ..
        } = stmt
        {
            *n += 1.0; // mutazione semantica semplice
        }
    }
}
