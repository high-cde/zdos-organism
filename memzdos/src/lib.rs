pub struct MemZdosV2 {
    pub short: Vec<String>,
    pub long: Vec<String>,
}
impl Default for MemZdosV2 {
    fn default() -> Self {
        Self::new()
    }
}

impl MemZdosV2 {
    pub fn new() -> Self {
        Self {
            short: vec![],
            long: vec![],
        }
    }
    pub fn push_short(&mut self, x: String) {
        self.short.push(x);
    }
    pub fn push_long(&mut self, x: String) {
        self.long.push(x);
    }
}
