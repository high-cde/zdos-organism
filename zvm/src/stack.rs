use thiserror::Error;

#[derive(Debug, Error, PartialEq)]
pub enum StackError {
    #[error("stack underflow: expected {expected} values, found {available}")]
    Underflow { expected: usize, available: usize },
}

#[derive(Debug, Default)]
pub struct Stack {
    inner: Vec<f64>,
}

impl Stack {
    pub fn new() -> Self {
        Self::default()
    }
    pub fn push(&mut self, value: f64) {
        self.inner.push(value);
    }
    pub fn pop(&mut self) -> Result<f64, StackError> {
        self.inner.pop().ok_or(StackError::Underflow {
            expected: 1,
            available: 0,
        })
    }
    pub fn pop_pair(&mut self) -> Result<(f64, f64), StackError> {
        if self.inner.len() < 2 {
            return Err(StackError::Underflow {
                expected: 2,
                available: self.inner.len(),
            });
        }
        let right = self.inner.pop().expect("length checked");
        let left = self.inner.pop().expect("length checked");
        Ok((left, right))
    }
    pub fn len(&self) -> usize {
        self.inner.len()
    }
    pub fn is_empty(&self) -> bool {
        self.inner.is_empty()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn reports_underflow() {
        assert_eq!(
            Stack::new().pop(),
            Err(StackError::Underflow {
                expected: 1,
                available: 0
            })
        );
    }
    #[test]
    fn pops_in_lifo_order() {
        let mut stack = Stack::new();
        stack.push(2.0);
        stack.push(3.0);
        assert_eq!(stack.pop().unwrap(), 3.0);
        assert_eq!(stack.pop().unwrap(), 2.0);
    }
}
