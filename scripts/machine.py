"""
This script contains a `Machine` class with methods for interpreting an assembly lines
and updating its state accordingly.

Should be used in conjunction with emulate.py to visualise the state of the machine
after each instruction.

The methods of the machine are to be called from emulate.py, and are not
intended to be run directly.
"""

import numpy as np
import re

import array_manip as am
import utils
from section import Section, use_sections
from macros import use_macros
from instruction_decoding import parse_operation, parse_register_and_address


class Machine:
    """
    Represent the state of the machine:
    - memory
    - registers
    - flags
    """

    MEMORY_HEIGHT = 4096

    def __init__(self, assembly_lines):
        self.init_memory(assembly_lines)
        self.find_all_breakpoints()
        self.init_registers()
        self.init_flags()

    def init_memory(self, assembly_lines):
        """
        Expand the assembly lines into the full memory.
        - Macros are expanded,
        - Sections are used
        """

        self.sections = {}  # section name -> Section object
        macros = {}  # macro name -> macro value

        # init empty memory
        self.memory = [""] * self.MEMORY_HEIGHT

        # remove lines that are empty or only contain comments
        clean_lines = utils.remove_empty_or_only_comments(assembly_lines)

        # begin by finding all sections
        for i, line in enumerate(clean_lines):
            if not line.startswith("%"):
                continue  # not a section declaration
            new_section = Section(line)
            self.sections[new_section.name] = new_section  # store section

        current_section = None
        self.labels = {}  # label name -> line number
        for i, line in enumerate(clean_lines):
            # macro declaration
            if line.startswith("_"):
                parts = re.match(r"(_\w+)\s*=\s*(.+)", line).groups()
                macro_name, macro_value = parts
                macros[macro_name] = macro_value  # store macro value
                continue
            # section declaration
            if line.startswith("%"):
                current_section = self.sections[line.replace("%", "").split()[0]]
                continue
            if line.endswith(":\n"):
                new_label = line.replace(":", "").strip()
                label_linenum = len(current_section.lines) + current_section.start
                self.labels[new_label] = label_linenum
                continue

            # replace macros with their values
            line = use_macros(line, macros)
            # replace section names with their start line number
            line = use_sections(line, self.sections)

            current_section.lines.append(line)

        # now that all macros and sections have been expanded, we can
        # fill the memory
        for section in self.sections.values():
            for i, line in enumerate(section.lines):
                self.memory[section.start + i] = line.strip()

    def init_registers(self):
        self.registers = {
            "GR0": 0,
            "GR1": 0,
            "GR2": 0,
            "GR3": 0,
            "GR4": 0,
            "GR5": 0,
            "GR6": 0,
            "GR7": 0,
            "PC": 0,
            "SP": 0,
        }

    def init_flags(self):
        self.flags = {"Z": 0, "N": 0, "C": 0, "V": 0}

    def execute_next_instruction(self):
        """
        Perform the next instruction in the memory
        """

        # Fetch the next instruction
        instruction = self.get_from_memory(self.registers["PC"])
        self.registers["PC"] += 1

        # Interpret the instruction
        self.execute_instruction(instruction)

    def get_from_memory(self, address):
        """
        Get the value at the given address in memory
        """

        address = utils.parse_value(address)

        return self.memory[address]

    def at_breakpoint(self):
        """
        Check if the current instruction is at a breakpoint
        """
        current_line = self.registers["PC"]
        return current_line in self.breakpoints

    def continue_to_breakpoint(self):
        """
        Continue executing instructions until a breakpoint is reached
        """

        while True:
            self.execute_next_instruction()
            if self.at_breakpoint():
                break

    def find_all_breakpoints(self):
        """
        Find all breakpoints in the memory
        """

        self.breakpoints = []
        for i, line in enumerate(self.memory):
            if re.match(r".*;b.*", line):
                self.breakpoints.append(i)

    def execute_instruction(self, assembly_line):
        """
        Perform a single instruction
        """

        parts = re.split(r"\s*,\s*|\s+", assembly_line)
        mnemonic, address_mode = parse_operation(parts)

        if mnemonic in {"BRA", "JSR", "BNE", "BEQ"}:
            destination = parts[1]
            self.branch(mnemonic, destination)
            return

        reg, adr = parse_register_and_address(mnemonic, parts)

        if mnemonic == "LD":
            self.load_value(reg, adr, address_mode)
        elif mnemonic == "ST":
            self.store_value(reg, adr, address_mode)
        elif mnemonic in {"ADD", "SUB", "AND", "OR", "MUL"}:
            self.perform_alu_operation(mnemonic, reg, adr, address_mode)
        else:
            utils.ERROR(f"Unknown instruction {mnemonic}")

    def branch(self, mnemonic, destination):
        """
        Perform a branch instruction
        """

        if re.match(r"\d+", destination):
            adr = int(destination)
        elif destination in self.labels:
            adr = self.labels[destination]
        else:
            utils.ERROR(f"Unknown destination {destination}")

        if mnemonic == "BRA":
            self.registers["PC"] = adr
        # TODO: implement JSR
        elif mnemonic == "BNE":
            if self.flags["Z"] == 0:
                self.registers["PC"] = adr
        elif mnemonic == "BEQ":
            if self.flags["Z"] == 1:
                self.registers["PC"] = adr
        else:
            utils.ERROR(f"Unknown branch mnemonic {mnemonic}")

    def load_value(self, reg, adr, address_mode):
        """
        Load value into register. If address_mode == '', then load
        from memory[adr]. If address_mode == 'I', load the literal `adr` into
        the register.
        """
        if address_mode == "":
            value = self.memory[adr]
        elif address_mode == "I":
            value = adr
        else:
            utils.ERROR(f"Unknown address mode {address_mode}")

        self.registers[reg] = utils.parse_value(value)

    def store_value(self, reg, adr, address_mode):
        """
        Store the value of register into memory[adr]
        """
        # format as 24 bit binary string
        data = f"0b{self.registers[reg]:024b}"
        self.memory[adr] = data

    def perform_alu_operation(
        self, mnemonic: str, reg: str, adr: int, address_mode: str
    ):
        """
        Perform the ALU operation
        """

        if address_mode == "":
            value = utils.parse_value(self.memory[adr])
        elif address_mode == "I":
            value = adr

        if mnemonic == "ADD":
            result = self.registers[reg] + value
        elif mnemonic == "SUB":
            result = self.registers[reg] - value
        elif mnemonic == "AND":
            result = self.registers[reg] & value
        elif mnemonic == "OR":
            result = self.registers[reg] | value
        elif mnemonic == "MUL":
            result = self.registers[reg] * value
        else:
            utils.ERROR(f"Unknown mnemonic {mnemonic}")

        # TODO: set other flags
        self.flags["Z"] = 1 if result == 0 else 0

        self.registers[reg] = result
