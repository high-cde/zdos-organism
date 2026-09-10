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
            .map(|token| token.to_string())
            .collect();
        Self { tokens, pos: 0 }
    }

    fn next(&mut self) -> Option<String> {
        let token = self.tokens.get(self.pos).cloned();
        self.pos += usize::from(token.is_some());
        token
    }

    fn peek(&self) -> Option<&str> {
        self.tokens.get(self.pos).map(String::as_str)
    }

    fn expect(&mut self, expected: &str) -> Result<(), ParseError> {
        match self.next().as_deref() {
            Some(token) if token == expected => Ok(()),
            Some(token) => Err(ParseError::InvalidToken(token.to_string())),
            None => Err(ParseError::Eof),
        }
    }

    pub fn parse(&mut self) -> Result<Program, ParseError> {
        Ok(Program {
            statements: self.parse_statements(false)?,
        })
    }

    fn parse_statements(&mut self, in_block: bool) -> Result<Vec<Statement>, ParseError> {
        let mut statements = Vec::new();
        while let Some(token) = self.peek() {
            if token == "}" {
                if in_block {
                    break;
                }
                return Err(ParseError::InvalidToken(token.to_string()));
            }
            statements.push(self.parse_statement()?);
        }
        if in_block {
            self.expect("}")?;
        }
        Ok(statements)
    }

    fn parse_statement(&mut self) -> Result<Statement, ParseError> {
        match self.next().ok_or(ParseError::Eof)?.as_str() {
            "let" => {
                let name = self.next().ok_or(ParseError::Eof)?;
                self.expect("=")?;
                Ok(Statement::Let {
                    name,
                    value: self.parse_expr()?,
                })
            }
            "if" => self.parse_if(),
            _ => {
                self.pos -= 1;
                Ok(Statement::Expr(self.parse_expr()?))
            }
        }
    }

    fn parse_if(&mut self) -> Result<Statement, ParseError> {
        let mut branches = Vec::new();
        let condition = self.parse_expr()?;
        self.expect("{")?;
        branches.push((condition, self.parse_statements(true)?));
        let otherwise = if self.peek() == Some("else") {
            self.next();
            if self.peek() == Some("if") {
                self.next();
                let nested = self.parse_if()?;
                match nested {
                    Statement::If {
                        branches: nested_branches,
                        otherwise,
                    } => {
                        branches.extend(nested_branches);
                        otherwise
                    }
                    _ => unreachable!(),
                }
            } else {
                self.expect("{")?;
                self.parse_statements(true)?
            }
        } else {
            Vec::new()
        };
        Ok(Statement::If {
            branches,
            otherwise,
        })
    }

    fn parse_expr(&mut self) -> Result<Expr, ParseError> {
        let token = self.next().ok_or(ParseError::Eof)?;
        if let Ok(number) = token.parse::<f64>() {
            return Ok(Expr::Number(number));
        }
        if matches!(
            token.as_str(),
            "+" | "-" | "*" | "/" | ">" | "<" | ">=" | "<="
        ) {
            let left = self.parse_expr()?;
            let right = self.parse_expr()?;
            return Ok(Expr::Binary {
                op: token,
                left: Box::new(left),
                right: Box::new(right),
            });
        }
        Ok(Expr::Ident(token))
    }
}
