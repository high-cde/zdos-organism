#[derive(Debug)]
pub struct Stack {
    inner: Vec<f64>,
}

impl Stack {
    pub fn new() -> Self {
        Self { inner: Vec::new() }
    }

    pub fn push(&mut self, v: f64) {
        self.inner.push(v);
    }

    pub fn pop(&mut self) -> f64 {
        self.inner.pop().unwrap_or(0.0)
    }
}
