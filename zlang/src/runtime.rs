use crate::ast::*;
use serde_json::json;
use std::collections::HashMap;

pub struct Runtime {
    pub vars: HashMap<String, f64>,
}

impl Runtime {
    pub fn new() -> Self {
        Self { vars: HashMap::new() }
    }

    pub fn eval_program(&mut self, program: &Program) -> serde_json::Value {
        let mut last = json!(null);

        for stmt in &program.statements {
            last = self.eval_statement(stmt);
        }

        last
    }

    fn eval_statement(&mut self, stmt: &Statement) -> serde_json::Value {
        match stmt {
            Statement::Let { name, value } => {
                let v = self.eval_expr(value);
                self.vars.insert(name.clone(), v);
                json!({ "let": name, "value": v })
            }
            Statement::Expr(expr) => {
                let v = self.eval_expr(expr);
                json!({ "expr": v })
            }
        }
    }

    fn eval_expr(&mut self, expr: &Expr) -> f64 {
        match expr {
            Expr::Number(n) => *n,
            Expr::Ident(name) => *self.vars.get(name).unwrap_or(&0.0),
            Expr::Binary { op, left, right } => {
                let l = self.eval_expr(left);
                let r = self.eval_expr(right);
                match op.as_str() {
                    "+" => l + r,
                    "-" => l - r,
                    "*" => l * r,
                    "/" => l / r,
                    _ => 0.0,
                }
            }
        }
    }
}
