use zdos_zvm::bytecode::BytecodeProgram;
use zdos_zvm::opcode::Opcode;

pub fn mutate_bytecode(program: &mut BytecodeProgram) {
    if let Some(last) = program.code.last_mut() {
        *last = Opcode::Add;
    }
}
