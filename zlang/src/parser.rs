use crate::ast::*;
use thiserror::Error;

#[derive(Debug, Error)]
pub enum ParseError {
    #[error("unexpected end of input")]
    Eof,
    #[error("invalid token: {0}")]
    InvalidToken(String),
}

pub struct Parser {
    tokens: Vec<String>,
    pos: usize,
}

impl Parser {
    pub fn new(input: &str) -> Self {
        let tokens = input
            .split_whitespace()
            .map(|s| s.to_string())
            .collect::<Vec<_>>();

        Self { tokens, pos: 0 }
    }

    fn next(&mut self) -> Option<String> {
        if self.pos >= self.tokens.len() {
            None
        } else {
            let t = self.tokens[self.pos].clone();
            self.pos += 1;
            Some(t)
        }
    }

    fn peek(&self) -> Option<&String> {
        self.tokens.get(self.pos)
    }

    pub fn parse(&mut self) -> Result<Program, ParseError> {
        let mut statements = Vec::new();

        // Programma vuoto → valido
        if self.tokens.is_empty() {
            return Ok(Program { statements });
        }

        while let Some(tok) = self.next() {
            if tok == "let" {
                // let <name> = <expr>
                let name = self.next().ok_or(ParseError::Eof)?;
                let eq = self.next().ok_or(ParseError::Eof)?;
                if eq != "=" {
                    return Err(ParseError::InvalidToken(eq));
                }

                let value = self.parse_expr()?;
                statements.push(Statement::Let { name, value });
            } else {
                // Non è "let" → è un'espressione
                self.pos -= 1;
                let expr = self.parse_expr()?;
                statements.push(Statement::Expr(expr));
            }
        }

        Ok(Program { statements })
    }

    fn parse_expr(&mut self) -> Result<Expr, ParseError> {
        let tok = self.next().ok_or(ParseError::Eof)?;

        // Numero
        if let Ok(n) = tok.parse::<f64>() {
            return Ok(Expr::Number(n));
        }

        // Operatore binario prefix-style
        if tok == "+" || tok == "-" || tok == "*" || tok == "/" {
            let left = self.parse_expr()?;
            let right = self.parse_expr()?;
            return Ok(Expr::Binary {
                op: tok,
                left: Box::new(left),
                right: Box::new(right),
            });
        }

        // Identificatore
        Ok(Expr::Ident(tok))
    }
}
